# ⚡ Aplicar Correção do IP do Servidor

## Problema
O servidor está enviando o IP interno do Docker (`172.20.0.3`) ao cliente, impedindo conexão.

## Solução Rápida Aplicada

Foi adicionada a variável de ambiente `RESOLVE_IP=loopback` no `docker-compose.yml` para forçar o IP `127.127.127.127`.

## Como Aplicar

### Passo 1: Reiniciar o Servidor

```powershell
cd deploy\all-in-one
docker compose restart openmu-startup
```

**OU** se precisar reiniciar completamente:

```powershell
cd deploy\all-in-one
docker compose down
docker compose up -d --no-build
```

## Verificar se Funcionou

Após reiniciar, verifique os logs:

```powershell
docker compose -f deploy/all-in-one/docker-compose.yml logs openmu-startup | Select-String -Pattern "has registered with endpoint" | Select-Object -Last 10
```

Todos devem mostrar `127.127.127.127` agora.

Se ainda mostrar `172.20.0.3`, force o re-registro dos Game Servers pelo painel admin:
1. Acesse `http://localhost/admin`
2. Vá em **Servers** → **Game Servers**
3. Pare TODOS os Game Servers
4. Aguarde 5 segundos
5. Inicie TODOS os Game Servers novamente

### Passo 2: Aguardar Inicialização

Aguarde 30-60 segundos para o servidor inicializar completamente.

### Passo 3: Verificar

Execute para verificar se os Game Servers se registraram com o IP correto:

```powershell
docker compose logs openmu-startup | Select-String -Pattern "has registered with endpoint"
```

Você deve ver:
```
GameServer "..." has registered with endpoint "127.127.127.127:55901"
GameServer "..." has registered with endpoint "127.127.127.127:55902"
...
```

Ao invés de:
```
GameServer "..." has registered with endpoint "172.20.0.3:55901"
```

### Passo 4: Testar Conexão

1. Conecte o cliente ao servidor
2. Selecione um servidor da lista
3. Agora deve receber `127.127.127.127:55901` ao invés de `172.20.0.3:55901`

## Alternativa: Configurar no Painel Admin

Se preferir usar o painel admin:

1. Acesse http://localhost/
2. Login: `admin` / Senha: `openmu`
3. Vá em **Configuration → System**
4. Configure **IP Resolver Type** para **"Loopback"**
5. **Salve**
6. **Pare e reinicie TODOS os Game Servers** pelo painel (não só o Connect Server)

## O Que Foi Feito

O arquivo `deploy/all-in-one/docker-compose.yml` foi modificado para incluir:
```yaml
RESOLVE_IP: loopback
```

Isso força o servidor a usar `127.127.127.127` desde o início, evitando o problema do IP interno do Docker.
