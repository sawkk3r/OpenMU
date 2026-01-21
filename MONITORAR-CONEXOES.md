# 📊 Como Monitorar Tentativas de Conexão ao Servidor

Este guia mostra todas as formas de monitorar conexões e tentativas de conexão ao servidor OpenMU.

## 🎯 Métodos de Monitoramento

### 1. Painel Administrativo (Mais Fácil)

O painel web oferece monitoramento em tempo real.

**Acesse:**
- URL: http://localhost/
- Login: `admin` / Senha: `openmu`

**O que você pode ver:**

1. **Página Principal (Servers):**
   - Lista de servidores com status
   - **Current Connections** - Conexões ativas de cada servidor
   - **Maximum Connections** - Limite de conexões
   - Estado do servidor (Started/Stopped)
   - Total de jogadores online

2. **Atualização em Tempo Real:**
   - O painel atualiza automaticamente as conexões
   - Veja aumentos/diminuições de jogadores conectados
   - Monitore status dos servidores

**Navegação:**
- Vá em **"Servers"** no menu lateral para ver todos os servidores
- Cada servidor mostra: `X / Y` conexões (atuais / máximo)

---

### 2. Logs do Servidor em Tempo Real

Veja todas as tentativas de conexão através dos logs do Docker.

#### Comando Básico

```powershell
cd deploy\all-in-one
docker compose logs -f openmu-startup
```

Isso mostra todos os logs em tempo real. Pressione `Ctrl+C` para parar.

#### Filtrar Apenas Conexões

**Ver apenas conexões de clientes:**

```powershell
docker compose logs -f openmu-startup | Select-String -Pattern "connected|disconnected|Client|connection"
```

**Ver tentativas de conexão ao ConnectServer:**

```powershell
docker compose logs -f openmu-startup | Select-String -Pattern "Client connected|Client disconnected|Address|Port"
```

**Ver conexões aos GameServers:**

```powershell
docker compose logs -f openmu-startup | Select-String -Pattern "Game Client connected|Player connected|Address"
```

**Ver requisições de lista de servidores:**

```powershell
docker compose logs -f openmu-startup | Select-String -Pattern "requested Server List|Server List|Connection Info"
```

#### Exemplos de Mensagens nos Logs

Quando um cliente conecta, você verá mensagens como:

```
[Information] Client connected: 127.127.127.127:54321, current client count: 1
[Information] Client 127.127.127.127:54321 requested Server List
[Information] Game Client connected, Address 127.127.127.127:54322
[Information] Connection to Client 127.127.127.127:54321 disconnected.
```

---

### 3. Script de Monitoramento Automático

Crie um script PowerShell para monitorar conexões:

```powershell
# monitorar-conexoes.ps1
while ($true) {
    Clear-Host
    Write-Host "=== Monitoramento de Conexões OpenMU ===" -ForegroundColor Cyan
    Write-Host "Data/Hora: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Yellow
    Write-Host ""
    
    # Verificar conexões recentes
    $logs = docker compose -f deploy/all-in-one/docker-compose.yml logs --tail 20 openmu-startup 2>$null
    $connections = $logs | Select-String -Pattern "connected|disconnected" | Select-Object -Last 10
    
    if ($connections) {
        Write-Host "Últimas conexões/desconexões:" -ForegroundColor Green
        $connections | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "Nenhuma conexão recente" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Pressione Ctrl+C para sair" -ForegroundColor Gray
    Start-Sleep -Seconds 5
}
```

**Salve como `monitorar-conexoes.ps1` e execute:**

```powershell
powershell -ExecutionPolicy Bypass -File monitorar-conexoes.ps1
```

---

### 4. Ver Logs Específicos por Servidor

#### Connect Server (Porta 44405/44406)

```powershell
docker compose logs -f openmu-startup | Select-String -Pattern "ConnectServer|ClientListener"
```

#### Game Server (Portas 55901-55906)

```powershell
docker compose logs -f openmu-startup | Select-String -Pattern "GameServer|Game Client|Player"
```

#### Chat Server (Porta 55980)

```powershell
docker compose logs -f openmu-startup | Select-String -Pattern "ChatServer|Chat"
```

---

### 5. Logs com Timestamp e Filtros Avançados

#### Ver logs com timestamps

```powershell
docker compose logs -f --timestamps openmu-startup
```

#### Salvar logs em arquivo

```powershell
docker compose logs --tail 1000 openmu-startup > conexoes-$(Get-Date -Format 'yyyyMMdd-HHmmss').log
```

#### Buscar por IP específico

```powershell
docker compose logs openmu-startup | Select-String -Pattern "127.127.127.127"
```

#### Ver apenas erros de conexão

```powershell
docker compose logs openmu-startup | Select-String -Pattern "Error|Failed|Timeout|disconnected"
```

---

### 6. Usando Docker Stats (Uso de Recursos)

Monitore uso de recursos durante conexões:

```powershell
docker stats openmu-startup
```

Isso mostra:
- CPU usage
- Memory usage
- Network I/O
- Útil para detectar sobrecarga quando muitos jogadores conectam

---

### 7. Verificar Portas Abertas

Verifique se as portas estão escutando conexões:

```powershell
# Windows PowerShell
netstat -an | findstr "44405 44406 55901 55980"

# Ver conexões estabelecidas
netstat -an | findstr "ESTABLISHED" | findstr "44405 44406 55901"
```

---

### 8. Monitorar através do Admin Panel (Log View)

O painel administrativo tem uma página de logs:

1. Acesse http://localhost/
2. Vá em **"Log View"** no menu
3. Configure filtros:
   - Por servidor
   - Por logger
   - Por player
   - Nível de log (Debug, Information, Warning, Error)
4. Veja logs em tempo real

---

## 📝 O que Procurar nos Logs

### Conexão Bem-Sucedida

```
✅ Client connected: [IP]:[Port], current client count: X
✅ Client [IP]:[Port] requested Server List
✅ Connection Info sent
✅ Game Client connected, Address [IP]
✅ Player connected: [Nome]
```

### Problemas de Conexão

```
❌ Connection Timeout: Address [IP]:[Port] will be disconnected
❌ Client [IP]:[Port] will be disconnected because it sent a packet which was too big
❌ Error when disconnecting client
❌ The server is full... disconnecting the game client
```

### Tentativas de Conexão

```
📡 Client Listener started, Port 44405
📡 Server listener started, port 55901
```

---

## 🔧 Scripts Úteis

### Script: Monitorar Conexões em Tempo Real

Crie o arquivo `monitor-conexoes.bat`:

```batch
@echo off
echo Monitorando conexoes ao servidor OpenMU...
echo Pressione Ctrl+C para parar
echo.
cd /d "%~dp0"
cd deploy\all-in-one
docker compose logs -f openmu-startup | findstr /i "connected disconnected Client Address"
```

### Script: Verificar Status de Conexões

Crie o arquivo `verificar-conexoes.ps1`:

```powershell
Write-Host "=== Status de Conexões OpenMU ===" -ForegroundColor Cyan
Write-Host ""

# Ver conexões ativas nas portas
$portas = @(44405, 44406, 55901, 55902, 55903, 55980)

foreach ($porta in $portas) {
    $conexoes = netstat -an | Select-String ":$porta" | Select-String "ESTABLISHED"
    $count = ($conexoes | Measure-Object).Count
    Write-Host "Porta $porta : $count conexoes estabelecidas" -ForegroundColor $(if ($count -gt 0) { "Green" } else { "Gray" })
}

Write-Host ""
Write-Host "Ver logs recentes:" -ForegroundColor Yellow
docker compose -f deploy/all-in-one/docker-compose.yml logs --tail 10 openmu-startup | Select-String -Pattern "connected|disconnected"
```

---

## 🎯 Exemplos Práticos

### Exemplo 1: Ver todas as conexões de hoje

```powershell
docker compose logs --since 24h openmu-startup | Select-String -Pattern "connected"
```

### Exemplo 2: Monitorar apenas erros

```powershell
docker compose logs -f openmu-startup | Select-String -Pattern "Error|Failed|Exception"
```

### Exemplo 3: Ver quantas conexões cada IP fez

```powershell
docker compose logs openmu-startup | Select-String -Pattern "Client connected" | Group-Object | Sort-Object Count -Descending
```

---

## 📊 Dashboard Rápido

Combine várias informações:

```powershell
Write-Host "=== Dashboard OpenMU ===" -ForegroundColor Cyan
Write-Host ""

# Status dos containers
Write-Host "Status dos Containers:" -ForegroundColor Yellow
docker compose -f deploy/all-in-one/docker-compose.yml ps

Write-Host ""
Write-Host "Últimas 5 Conexões:" -ForegroundColor Yellow
docker compose -f deploy/all-in-one/docker-compose.yml logs --tail 50 openmu-startup | Select-String -Pattern "connected|disconnected" | Select-Object -Last 5

Write-Host ""
Write-Host "Conexões Ativas (Portas):" -ForegroundColor Yellow
netstat -an | Select-String "ESTABLISHED" | Select-String "44405|44406|55901|55902|55903"
```

---

## 💡 Dicas

1. **Use o Painel Admin** para monitoramento visual e fácil
2. **Use logs** para investigar problemas específicos
3. **Filtre logs** para encontrar informações relevantes rapidamente
4. **Salve logs importantes** para análise posterior
5. **Monitore recursos** durante picos de conexão

---

## 🔍 Troubleshooting

### Não vejo conexões nos logs?

- Verifique se o servidor está rodando: `docker compose ps`
- Verifique se as portas estão abertas: `netstat -an | findstr "44405"`
- Verifique o firewall

### Logs não aparecem em tempo real?

- Use `-f` (follow) para acompanhar em tempo real
- Verifique se não há filtros muito restritivos

### Muitas informações nos logs?

- Use filtros específicos com `Select-String`
- Use `--tail N` para ver apenas últimas N linhas
- Filtre por nível: `Select-String -Pattern "Information|Error"`

---

**Última atualização:** Guia completo de monitoramento de conexões
