# 🔍 Análise Detalhada: Problema do IP Interno do Docker

## Situação Atual

### ✅ O que está funcionando:
- Game Servers estão se registrando com `127.127.127.127` ✅
- Variável `RESOLVE_IP=loopback` está configurada ✅
- Logs mostram registros corretos: `has registered with endpoint "127.127.127.127:55901"` ✅

### ❌ O problema que persiste:
- Cliente ainda recebe `172.20.0.3` ao selecionar servidor ❌

## Investigação do Código

### Como o IP é enviado ao cliente:

1. **Game Server se registra** (linha 90 de `DefaultTcpGameServerListener.cs`):
   ```csharp
   this._stateObserver.RegisterGameServer(this._gameServerInfo, 
       new IPEndPoint(await this._addressResolver.ResolveIPv4Async().ConfigureAwait(false), port));
   ```
   ✅ **Isso está funcionando** - registra com `127.127.127.127`

2. **Cliente solicita lista de servidores** (`ServerListRequestHandler`):
   - Envia apenas ServerId e LoadPercentage
   - **NÃO envia IP** nessa etapa

3. **Cliente clica no servidor** (`ServerInfoRequestHandler` - linha 32):
   - Aqui o IP é enviado ao cliente
   - **PROBLEMA POTENCIAL AQUI!**

### Lógica no ServerInfoRequestHandler (linhas 42-78):

```csharp
var localIpEndPoint = client.Connection.LocalEndPoint as IPEndPoint;
var serverItem = this._connectServer.ServerList.GetItem(serverId);
var isGameServerOnSameMachineAsConnectServer = (serverItem?.EndPoint.Address).IsOnSameHost();
var isClientConnectedOnNonRegisteredAddress = !object.Equals(serverItem?.EndPoint.Address, localIpEndPoint?.Address);
bool.TryParse(Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER"), out var isRunningOnDocker);

if (isGameServerOnSameMachineAsConnectServer
    && !isRunningOnDocker
    && isClientConnectedOnNonRegisteredAddress)
{
    // Usa IP do local endpoint
    IpAddress = localIpEndPoint!.Address.ToString();
}
else if (this._connectServer.ConnectInfos.TryGetValue(serverId, out var connectInfo))
{
    // Usa o ConnectInfo cached (DEVE SER 127.127.127.127)
    connectInfo.CopyTo(span);
}
```

## Possíveis Problemas Identificados

### Problema 1: IsOnSameHost() no Docker

A função `IsOnSameHost()` (linha 36 de `IpAddressExtensions.cs`):
```csharp
_localIpAddresses ??= Dns.GetHostAddresses(Dns.GetHostName()).ToHashSet();
return _localIpAddresses.Contains(address);
```

**No Docker, `Dns.GetHostName()` pode retornar o hostname do container, e os IPs podem incluir `172.20.0.3`!**

Se `127.127.127.127` não estiver na lista de IPs locais retornada por `Dns.GetHostAddresses()`, `IsOnSameHost()` retornará `false`.

### Problema 2: ConnectInfos Cache

O `ConnectInfos` é preenchido quando o Game Server se registra (linha 184 de `ConnectServer.cs`):
```csharp
if (this.ConnectInfos.TryAdd(serverListItem.ServerId, serverListItem.ConnectInfo))
```

Se os Game Servers se registraram ANTES da configuração do IP Resolver ser aplicada, o cache pode ter IPs errados.

### Problema 3: LocalEndPoint no Docker

Quando o cliente se conecta, `localIpEndPoint` pode ser o IP interno do Docker (`172.20.0.3`), não o IP externo.

## Soluções Propostas

### Solução 1: Forçar re-registro dos Game Servers

Depois de configurar o IP Resolver:

1. **No painel admin:**
   - Pare TODOS os Game Servers
   - Aguarde 5 segundos
   - Inicie TODOS os Game Servers novamente

2. **Ou via código:** Verifique se há um método para limpar o cache de ConnectInfos

### Solução 2: Verificar IsOnSameHost()

O problema pode ser que `127.127.127.127` não é detectado como loopback ou como IP local no Docker.

**Verificar:** `IPAddress.IsLoopback()` deve retornar `true` para `127.127.127.127`, mas o código usa `IsOnSameHost()` que verifica IPs locais via DNS.

### Solução 3: Configurar DOTNET_RUNNING_IN_CONTAINER

A variável `DOTNET_RUNNING_IN_CONTAINER` pode não estar definida, fazendo com que a lógica de fallback não funcione corretamente.

## Verificações Necessárias

1. **Verificar o ConnectInfos atual:**
   - O que está armazenado em `ConnectInfos`?
   - Está com `127.127.127.127` ou `172.20.0.3`?

2. **Verificar IsOnSameHost():**
   - `127.127.127.127.IsOnSameHost()` retorna `true` ou `false`?
   - Quais IPs `Dns.GetHostAddresses()` retorna no Docker?

3. **Verificar LocalEndPoint:**
   - Quando o cliente se conecta, qual é o `LocalEndPoint`?
   - É `127.127.127.127` ou `172.20.0.3`?

## Problema Identificado ✅

### Causa Raiz:

O problema está na linha 184 de `ConnectServer.cs`:

```csharp
if (this.ConnectInfos.TryAdd(serverListItem.ServerId, serverListItem.ConnectInfo))
{
    this._serverList.Add(serverListItem);
}
```

**`TryAdd()` só adiciona se a chave NÃO existir!** Se o Game Server já estiver registrado com um IP antigo (`172.20.0.3`), o novo registro com `127.127.127.127` será **IGNORADO**!

### Por que isso acontece?

1. Game Servers podem ter se registrado ANTES da configuração do `RESOLVE_IP=loopback`
2. Ou o servidor foi reiniciado mas os registros antigos não foram limpos
3. O cache `ConnectInfos` mantém o IP antigo (`172.20.0.3`)

## Solução ✅

### Opção 1: Reiniciar o Container (Recomendado)

```powershell
cd deploy\all-in-one
docker compose restart openmu-startup
```

Isso força todos os Game Servers a se re-registrarem com o IP correto.

### Opção 2: Parar e Iniciar Game Servers no Painel Admin

1. Acesse `http://localhost/admin`
2. Vá em **Servers** → **Game Servers**
3. Pare TODOS os Game Servers
4. Aguarde 5 segundos
5. Inicie TODOS os Game Servers novamente

Isso força o re-registro e limpa os registros antigos.

### Opção 3: Verificar se o Problema Persiste

Após reiniciar, verifique os logs:

```powershell
docker compose -f deploy/all-in-one/docker-compose.yml logs openmu-startup | Select-String -Pattern "has registered with endpoint" | Select-Object -Last 10
```

Todos devem mostrar `127.127.127.127` agora.

## Próximos Passos

1. ✅ Reiniciar o container para forçar re-registro
2. ✅ Verificar logs para confirmar que todos os registros estão com `127.127.127.127`
3. ✅ Testar conexão do cliente novamente
