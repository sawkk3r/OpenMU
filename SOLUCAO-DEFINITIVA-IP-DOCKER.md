# 🔧 Solução Definitiva: IP Interno do Docker (172.20.0.3)

## Problema

Os Game Servers estão se registrando no Connect Server com o IP interno do Docker (`172.20.0.3`) ao invés de `127.127.127.127`, impedindo que clientes se conectem.

## Causa

Os Game Servers se registram quando são iniciados. Se o IP Resolver não estiver configurado como "Loopback" naquele momento, eles usam o IP detectado automaticamente (que é o IP interno do Docker).

## Soluções

### Solução 1: Configurar IP Resolver + Reiniciar Game Servers

#### Passo 1: Configurar IP Resolver

1. Acesse o painel admin: http://localhost/
2. Login: `admin` / Senha: `openmu`
3. Vá em **Configuration → System**
4. Configure **IP Resolver Type** para **"Loopback"**
5. **Salve** as alterações

#### Passo 2: Reiniciar TODOS os Servidores

1. Volte para a página **"Servers"**
2. Para cada **Game Server** na lista:
   - Clique em **"Stop"**
   - Aguarde alguns segundos
   - Clique em **"Start"**
3. Reinicie também o **Connect Server**

#### Passo 3: Verificar

Execute para ver os logs:

```powershell
docker compose -f deploy/all-in-one/docker-compose.yml logs -f openmu-startup | Select-String -Pattern "has registered with endpoint"
```

Você deve ver `127.127.127.127` ao invés de `172.20.0.3`.

---

### Solução 2: Usar Variável de Ambiente (Mais Permanente)

Configure o IP Resolver via variável de ambiente para que seja aplicado desde o início.

#### Editar docker-compose.yml

1. Edite o arquivo `deploy/all-in-one/docker-compose.yml`
2. Adicione a variável de ambiente `RESOLVE_IP` na seção `openmu-startup`:

```yaml
openmu-startup:
  image: munique/openmu
  container_name: openmu-startup
  ports:
    # ... (portas existentes)
  environment:
    DB_HOST: database
    ASPNETCORE_URLS: http://+:8080
    RESOLVE_IP: loopback  # ← ADICIONE ESTA LINHA
  # ... (resto da configuração)
```

#### Reiniciar o Container

```powershell
cd deploy/all-in-one
docker compose down
docker compose up -d --no-build
```

#### Verificar

Aguarde alguns segundos e verifique os logs:

```powershell
docker compose logs openmu-startup | Select-String -Pattern "has registered with endpoint"
```

---

### Solução 3: Verificar Configuração Atual

Verifique se a configuração do IP Resolver foi salva corretamente:

1. No painel admin, vá em **Configuration → System**
2. Verifique o valor de **IP Resolver Type**
3. Se não estiver como "Loopback", altere e salve
4. Verifique o **IP Parameter** (deve estar vazio para Loopback)

---

## Por Que Isso Acontece?

1. **No Docker**: O servidor detecta automaticamente o IP da interface de rede do container (`172.20.0.3`)
2. **Registro Inicial**: Os Game Servers se registram quando são iniciados
3. **IP Errado**: Se o IP Resolver não está configurado, usam o IP detectado automaticamente
4. **Cliente não alcança**: O IP `172.20.0.3` só existe dentro da rede Docker

## Verificação Final

Após aplicar a solução, verifique:

1. **Logs do registro:**
   ```powershell
   docker compose logs openmu-startup | Select-String "has registered with endpoint"
   ```
   Deve mostrar: `127.127.127.127:55901` (ou outras portas)

2. **Tentar conectar:**
   - Conecte o cliente ao Connect Server
   - Selecione um servidor
   - Verifique se agora recebe `127.127.127.127:55901` ao invés de `172.20.0.3:55901`

## Se Ainda Não Funcionar

1. **Verifique se salvou a configuração** no painel admin
2. **Verifique se reiniciou os Game Servers** (não só o Connect Server)
3. **Verifique os logs** para ver qual IP está sendo usado
4. **Tente usar a variável de ambiente** (Solução 2) para garantir que seja aplicado desde o início
