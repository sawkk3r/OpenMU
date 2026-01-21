# Guia de Conexão - Servidor OpenMU

Este guia contém todas as informações necessárias para conectar e usar seu servidor MU Online OpenMU.

## 📋 Índice

- [Informações do Servidor](#informações-do-servidor)
- [Formas de Conexão](#formas-de-conexão)
- [Scripts de Conexão](#scripts-de-conexão)
- [Contas de Teste](#contas-de-teste)
- [Painel Administrativo](#painel-administrativo)
- [Comandos Úteis](#comandos-úteis)
- [Troubleshooting](#troubleshooting)

---

## 🖥️ Informações do Servidor

### Status Atual

O servidor está rodando via Docker e está ativo!

### IP e Portas

#### Para Conexão LOCAL (mesma máquina):
- **IP:** `127.127.127.127`
- **Porta ConnectServer:** `44405` (Cliente Original) ou `44406` (Cliente Open Source)
- ⚠️ **IMPORTANTE:** Não use `127.0.0.1` pois o cliente bloqueia este IP!

#### Para Conexão na REDE LOCAL:
- **IP:** Use o IP local da máquina do servidor (ex: `192.168.x.x`)
- **Porta:** `44405` ou `44406`

#### Para Conexão pela INTERNET:
- **IP:** `149.102.234.78` (IP público detectado)
- **Porta:** `44405` ou `44406`

### Portas Disponíveis

| Porta | Serviço | Descrição |
|-------|---------|-----------|
| 80 | Painel Administrativo | http://localhost/ |
| 44405 | Connect Server | Cliente Original |
| 44406 | Connect Server | Cliente Open Source |
| 55901-55906 | Game Servers | 3 servidores de jogo |
| 55980 | Chat Server | Servidor de chat |

---

## 🎮 Formas de Conexão

Existem três formas principais de conectar ao servidor:

### 1. Linha de Comando

Execute o cliente diretamente com parâmetros:

```cmd
main.exe connect /u127.127.127.127 /p44405
```

**Parâmetros:**
- `/u` seguido do IP do servidor
- `/p` seguido da porta do servidor

**Exemplos:**

```cmd
# Cliente Original (porta 44405)
main.exe connect /u127.127.127.127 /p44405

# Cliente Open Source (porta 44406)
main.exe connect /u127.127.127.127 /p44406

# Conexão em rede local
main.exe connect /u192.168.0.20 /p44405
```

### 2. OpenMU Client Launcher

O launcher oficial facilita a conexão:

1. **Baixar o Launcher:**
   - Link: [MUnique.OpenMU.ClientLauncher v0.9.6.zip](https://github.com/MUnique/OpenMU/releases/download/v0.9.0/MUnique.OpenMU.ClientLauncher_0.9.6.zip)
   - Requisito: [.NET 10 Runtime](https://dotnet.microsoft.com/download/dotnet/10.0) ou superior

2. **Configurar o Launcher:**
   - Abra o launcher
   - Clique em "Add Server" ou configure o servidor padrão
   - Configure:
     - **IP:** `127.127.127.127` (ou IP do seu servidor)
     - **Porta:** `44405` ou `44406`
     - **Caminho do main.exe:** Selecione o executável do cliente MU
   - Clique em "Launch"

3. **Vantagens:**
   - Interface gráfica amigável
   - Configurações salvas
   - Múltiplos servidores
   - Configuração automática do registro (Windows)

### 3. Conexão Padrão (Localhost)

Alguns clientes podem conectar diretamente ao localhost na porta `44406` se o servidor estiver configurado para isso.

---

## 📝 Scripts de Conexão

Foram criados scripts para facilitar a conexão:

### Scripts Disponíveis

#### 1. `conectar-mu-local.bat`
Script para conexão local (Cliente Original - Porta 44405)

**Como usar:**
1. Edite o arquivo e configure o caminho do `main.exe`
2. Execute o script

```batch
set MAIN_EXE=C:\Caminho\Para\Seu\MU\main.exe
```

#### 2. `conectar-mu-local-opensource.bat`
Script para conexão local (Cliente Open Source - Porta 44406)

**Como usar:**
1. Edite o arquivo e configure o caminho do `main.exe`
2. Execute o script

#### 3. `conectar-mu-rede.ps1`
Script PowerShell para conexão em rede local

**Como usar:**
1. Edite o arquivo e configure:
   ```powershell
   $MainExePath = "C:\Caminho\Para\Seu\MU\main.exe"
   $ServerIP = "192.168.0.20"  # IP do servidor na rede
   $Port = 44405  # ou 44406
   ```
2. Execute: `powershell -ExecutionPolicy Bypass -File conectar-mu-rede.ps1`

---

## 👤 Contas de Teste

O servidor cria automaticamente contas de teste durante a inicialização:

| Usuário | Senha | Nível | Descrição |
|---------|-------|-------|-----------|
| `test0` a `test9` | Mesmo que usuário | 1 a 90 | Contas gerais com níveis variados |
| `test300` | `test300` | 300 | Conta nível 300 |
| `test400` | `test400` | 400 | Conta nível 400 com personagens master |
| `testgm` | `testgm` | - | Conta de Game Master |
| `testgm2` | `testgm2` | - | Game Master com summoner e rage fighter |
| `testunlock` | `testunlock` | - | Sem personagens, mas com classes desbloqueadas |
| `quest1` | `quest1` | - | Para quests nível 150 |
| `quest2` | `quest2` | - | Para quests nível 220 |
| `quest3` | `quest3` | - | Para quests nível 400 |
| `ancient` | `ancient` | 330 | Com sets ancient |
| `socket` | `socket` | 380 | Com sets socket |

**Nota:** A senha é sempre igual ao nome de usuário para essas contas.

---

## 🔧 Painel Administrativo

### Acesso

- **URL:** http://localhost/
- **Usuário:** `admin`
- **Senha:** `openmu`

### Funcionalidades

No painel administrativo você pode:

- ✅ Ver status dos servidores
- ✅ Iniciar/parar servidores
- ✅ Ver jogadores conectados
- ✅ Gerenciar contas e personagens
- ✅ Configurar o sistema
- ✅ Ver estatísticas do servidor
- ✅ Configurar Auto Start dos servidores
- ✅ Configurar resolução de IP
- ✅ Alterar versão do jogo
- ✅ Criar novas contas

### Configurações Importantes

#### Auto Start
Ative o Auto Start para que os servidores iniciem automaticamente:
- Vá em `Configuration -> System`
- Ative "Auto Start"
- Ou use o parâmetro: `-autostart`

#### IP Resolver
Se encontrar desconexões ao selecionar servidor:
- Vá em `Configuration -> System`
- Ajuste o "IP Resolver Type"
- Opções disponíveis:
  - **Auto:** Detecção automática
  - **Public:** IP público (internet)
  - **Local:** IP local da rede
  - **Loopback:** `127.127.127.127` (local)
  - **Custom:** IP personalizado

---

## 🛠️ Comandos Úteis

### Docker Compose

```bash
# Ver status dos containers
docker compose -f deploy/all-in-one/docker-compose.yml ps

# Ver logs do servidor
docker compose -f deploy/all-in-one/docker-compose.yml logs -f openmu-startup

# Parar o servidor
docker compose -f deploy/all-in-one/docker-compose.yml down

# Iniciar o servidor
docker compose -f deploy/all-in-one/docker-compose.yml up -d --no-build

# Reiniciar o servidor
docker compose -f deploy/all-in-one/docker-compose.yml restart

# Ver logs apenas dos últimos 50 linhas
docker compose -f deploy/all-in-one/docker-compose.yml logs --tail 50 openmu-startup
```

### Verificar Portas

```bash
# Windows PowerShell
netstat -an | findstr "44405 44406 55901 55980"

# Verificar se as portas estão abertas
Test-NetConnection -ComputerName localhost -Port 44405
Test-NetConnection -ComputerName localhost -Port 44406
```

---

## 🔍 Troubleshooting

### Problema: Cliente não conecta

**Soluções:**
1. Verifique se o servidor está rodando:
   ```bash
   docker compose -f deploy/all-in-one/docker-compose.yml ps
   ```

2. Verifique se está usando o IP correto:
   - Local: Use `127.127.127.127` (NÃO `127.0.0.1`)
   - Rede: Use o IP correto da máquina servidor

3. Verifique as portas no firewall:
   - Certifique-se que as portas 44405, 44406, 55901-55906 estão liberadas

4. Verifique os logs do servidor:
   ```bash
   docker compose -f deploy/all-in-one/docker-compose.yml logs openmu-startup
   ```

### Problema: Desconexão ao selecionar servidor

**Solução:**
- Ajuste o "IP Resolver" no painel administrativo
- Vá em `Configuration -> System`
- Escolha a opção adequada (Loopback para local, Local para rede, etc.)

### Problema: Erro ao iniciar cliente

**Soluções:**
1. Verifique se o caminho do `main.exe` está correto
2. Verifique se o cliente é compatível (Season 6 Episode 3)
3. Tente executar como Administrador

### Problema: Servidor não inicia

**Soluções:**
1. Verifique se as portas estão livres:
   ```bash
   netstat -an | findstr "80 44405 44406 55901"
   ```

2. Verifique os logs:
   ```bash
   docker compose -f deploy/all-in-one/docker-compose.yml logs
   ```

3. Verifique se o PostgreSQL está rodando no container

### Problema: Não consigo acessar o painel administrativo

**Soluções:**
1. Verifique se está acessando: http://localhost/
2. Verifique se o container nginx-80 está rodando
3. Tente: http://127.0.0.1/

---

## 📚 Informações Adicionais

### Versão do Cliente

- **Versão Suportada:** Season 6 Episode 3
- **Protocolo:** ENG (English)
- **Serial do Cliente:** `k1Pk2jcET48mxL3b` (para clientes open source)
- **Versão Identificada:** 2.04d

### Requisitos do Cliente

- Cliente MU Online compatível com Season 6 Episode 3
- Sistema operacional: Windows
- Recomendado: Cliente oficial ou [MuMain (open source)](https://github.com/sven-n/MuMain)

### Recursos do Servidor

- ✅ Suporte a múltiplos clientes
- ✅ Painel administrativo web
- ✅ Sistema de contas e personagens
- ✅ Chat server
- ✅ Guild system
- ✅ Quest system
- ✅ Master system (Season 6)
- ✅ Ancient items
- ✅ Socket items

---

## 📞 Suporte

Para mais informações e suporte:

- **Discord:** https://discord.gg/2u5Agkd
- **GitHub:** https://github.com/MUnique/OpenMU
- **Blog:** https://munique.net
- **Quick Start Guide:** [QuickStart.md](QuickStart.md)

---

## 📝 Notas Finais

- ⚠️ O servidor está em desenvolvimento contínuo
- ⚠️ Sempre use `127.127.127.127` para conexão local (não `127.0.0.1`)
- ⚠️ Certifique-se de alterar a senha padrão do painel administrativo
- ⚠️ Para produção, configure HTTPS e use senhas fortes
- ✅ O servidor inicializa automaticamente com contas de teste
- ✅ O banco de dados é criado automaticamente na primeira execução

---

**Última atualização:** Baseado na configuração do servidor atual via Docker Compose
