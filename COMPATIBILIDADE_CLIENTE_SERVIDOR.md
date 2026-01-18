# 🔌 Compatibilidade Cliente-Servidor OpenMU
## Documento Técnico para Agentes de IA

Este documento fornece informações técnicas completas sobre como o cliente MU Online se conecta ao servidor OpenMU, incluindo versões suportadas, protocolos, portas e configurações necessárias.

---

## 📋 Informações Gerais do Servidor

### Tecnologia Base
- **Linguagem**: C# (.NET 10.0)
- **Banco de Dados**: PostgreSQL
- **Arquitetura**: All-in-one (recomendado) ou Distributed (não suportado atualmente)
- **Protocolo Principal**: Season 6 Episode 3 (ENG - English)

### Foco Principal
- **Versão Principal**: Season 6 Episode 3 (S6E3) - Protocolo Inglês
- **Cliente Open Source**: Suporte para [MuMain](https://github.com/sven-n/MuMain) com protocolo estendido

---

## 🎮 Versões de Cliente Suportadas

### Versões Oficialmente Suportadas

| Versão | Season | Episode | Idioma | Status | Porta Connect Server |
|--------|--------|---------|--------|--------|---------------------|
| **Extended S6E3** | 106 | 3 | English | ✅ Principal | 44406 |
| **S6E3 (1.04d)** | 6 | 3 | English | ✅ Principal | 44405 |
| **Season 1-6** | 1-6 | 0 | Invariant | ✅ Suportado | 44405 |
| **0.97** | 0 | 97 | Invariant | ✅ Suportado | 44405 |
| **0.95d** | 0 | 95 | English | ✅ Suportado | 44405 |
| **0.75** | 0 | 75 | Invariant | ✅ Suportado | 44405 |

### Idiomas de Cliente Suportados

O servidor suporta diferentes idiomas de cliente através do enum `ClientLanguage`:
- `English` (GMO) - Principal
- `Japanese`
- `Vietnamese`
- `Filipino`
- `Chinese`
- `Korean`
- `Thai`
- `Invariant` - Compatível com qualquer idioma

**Nota**: A versão principal é **Season 6 Episode 3 (English)**. Outras versões podem ter funcionalidades limitadas.

---

## 🔌 Configuração de Conexão

### Portas do Servidor

| Porta | Serviço | Descrição | Cliente |
|-------|---------|-----------|---------|
| **44405** | Connect Server | Cliente original (padrão) | Original MU Online |
| **44406** | Connect Server | Cliente open source | MuMain (extended protocol) |
| **55901-55906** | Game Servers | Servidores de jogo (até 6) | Ambos |
| **55980** | Chat Server | Servidor de chat | Ambos |
| **80/443** | Admin Panel | Interface web | Navegador |

### Fluxo de Conexão

```
Cliente → Connect Server (44405/44406) → Seleção de Servidor → Game Server (55901-55906)
                                                              → Chat Server (55980)
```

### Configuração de IP

**IMPORTANTE**: O cliente MU Online bloqueia conexões para `127.0.0.1`. Use:
- **Local**: `127.127.127.127` ou qualquer outro IP 127.x.x.x (exceto 127.0.0.1)
- **Rede Local**: IP da máquina (ex: `192.168.1.100`)
- **Internet**: IP público ou domínio

### Configuração via Launcher

O servidor fornece um launcher oficial:
- **Download**: [MUnique.OpenMU.ClientLauncher v0.9.6](https://github.com/MUnique/OpenMU/releases/download/v0.9.0/MUnique.OpenMU.ClientLauncher_0.9.6.zip)
- **Requisitos**: .NET 10 runtime ou superior
- **Funcionalidade**: Configura automaticamente o IP e porta no registro do Windows

**Como funciona o Launcher:**
1. Usuário informa IP e porta do servidor
2. Launcher escreve no registro: `HKEY_LOCAL_MACHINE\SOFTWARE\WebZen\Mu\Connection`
   - `Key`: Environment.TickCount
   - `ParameterA`: IP codificado
   - `ParameterB`: Porta codificada
3. Executa `main.exe` com parâmetros: `connect /u{ip} /p{porta}`

---

## 📡 Protocolo de Rede

### Características do Protocolo

- **Tipo**: TCP/IP
- **Criptografia**: Sim (depende da versão do cliente)
- **Formato de Pacotes**: Binário
- **Tamanho Máximo**: Configurável (padrão definido em `IConnectServerSettings.MaximumReceiveSize`)

### Versões e Criptografia

Cada versão de cliente usa métodos de criptografia diferentes:
- **S6E3**: Criptografia moderna com chaves específicas
- **0.97/0.95d/0.75**: Criptografia mais antiga
- **Extended S6E3 (MuMain)**: Protocolo estendido com recursos adicionais

### Estrutura de Pacotes

Os pacotes seguem a estrutura padrão MU Online:
- **Header**: Contém tipo e tamanho do pacote
- **Body**: Dados específicos do comando
- **Criptografia**: Aplicada após montagem do pacote

### Análise de Pacotes

O servidor inclui um **Network Analyzer** para debug:
- Localização: `src/Network/Analyzer/`
- Funcionalidade: Proxy que intercepta e decodifica pacotes
- Uso: Análise de tráfego entre cliente e servidor

---

## 🔧 Configuração do Cliente

### Método 1: Usando o Launcher (Recomendado)

1. Baixar e executar o launcher
2. Configurar:
   - **Host Address**: IP do servidor (ex: `127.127.127.127` ou IP público)
   - **Port**: `44405` (cliente original) ou `44406` (MuMain)
   - **Main.exe Path**: Caminho para o executável do cliente
3. Clicar em "Launch"

### Método 2: Configuração Manual (Windows)

**Via Registro:**
```
HKEY_LOCAL_MACHINE\SOFTWARE\WebZen\Mu\Connection
  Key: [DWORD] - Valor aleatório
  ParameterA: [STRING] - IP codificado
  ParameterB: [DWORD] - Porta codificada
```

**Via Linha de Comando:**
```bash
main.exe connect /u{IP} /p{PORTA}
```

### Método 3: Modificação de Arquivos

Alguns clientes permitem configuração via arquivos de configuração (depende da versão do cliente).

---

## 🎯 Compatibilidade por Versão

### Season 6 Episode 3 (Principal)

**Cliente Original:**
- ✅ Totalmente suportado
- ✅ Todas as funcionalidades
- ✅ Porta: 44405
- ✅ Idioma: English (GMO)

**Cliente MuMain (Open Source):**
- ✅ Totalmente suportado
- ✅ Protocolo estendido
- ✅ Porta: 44406
- ✅ Recursos adicionais

### Versões Antigas (0.75, 0.95d, 0.97)

- ⚠️ Suporte limitado
- ⚠️ Algumas funcionalidades podem não estar disponíveis
- ✅ Porta: 44405
- ⚠️ Teste antes de usar em produção

### Versões Season 1-6 (Invariant)

- ✅ Suporte básico
- ⚠️ Funcionalidades variam por season
- ✅ Porta: 44405

---

## 🛠️ Desenvolvimento de Cliente

### Requisitos para Compatibilidade

1. **Protocolo de Conexão**
   - Conectar via TCP/IP
   - Usar porta 44405 (original) ou 44406 (extended)
   - Implementar handshake inicial

2. **Criptografia**
   - Implementar criptografia conforme versão do cliente
   - Chaves de criptografia específicas por versão
   - Suportar diferentes métodos (SimpleModulus, etc.)

3. **Pacotes**
   - Seguir estrutura de pacotes MU Online
   - Implementar todos os pacotes necessários
   - Suportar diferentes tamanhos de pacote

4. **Versão do Cliente**
   - Enviar versão correta no handshake
   - Usar formato: `ClientVersion(Season, Episode, Language)`
   - Exemplo S6E3: `ClientVersion(6, 3, ClientLanguage.English)`

### Bibliotecas Úteis

O servidor fornece pacotes NuGet:
- **MUnique.OpenMU.Network**: Biblioteca de rede
- **MUnique.OpenMU.Network.Packets**: Definições de pacotes

### Exemplo de Conexão

```csharp
// Pseudocódigo
var socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
await socket.ConnectAsync(serverIP, 44405);

// Enviar handshake com versão do cliente
var version = new ClientVersion(6, 3, ClientLanguage.English);
// ... implementar envio de pacotes ...
```

---

## 🐛 Troubleshooting de Conexão

### Problema: Cliente não conecta

**Possíveis causas:**
1. **Porta bloqueada**: Verificar firewall
2. **IP incorreto**: Não usar `127.0.0.1` (bloqueado pelo cliente)
3. **Versão incompatível**: Verificar versão do cliente
4. **Connect Server não iniciado**: Verificar no Admin Panel

**Soluções:**
- Usar `127.127.127.127` para testes locais
- Verificar se Connect Server está rodando (Admin Panel)
- Verificar logs do servidor: `docker compose logs -f openmu-startup`
- Testar com launcher oficial primeiro

### Problema: Desconexão após selecionar servidor

**Possíveis causas:**
1. **IP Resolver incorreto**: Servidor retornando IP errado
2. **Game Server não iniciado**: Servidor de jogo não está rodando
3. **Firewall bloqueando**: Portas 55901-55906 bloqueadas

**Soluções:**
- Configurar IP Resolver no Admin Panel: `Configuration -> System`
- Iniciar Game Server no Admin Panel
- Verificar firewall e portas abertas

### Problema: Erro de versão

**Possíveis causas:**
1. **Versão do cliente não suportada**
2. **Idioma do cliente incompatível**
3. **Protocolo diferente**

**Soluções:**
- Usar cliente Season 6 Episode 3 (English)
- Ou usar cliente MuMain (extended protocol)
- Verificar logs para mensagens de erro específicas

---

## 📊 Estrutura de Dados

### ClientVersion

```csharp
public record struct ClientVersion(
    byte Season,        // Ex: 6 para Season 6
    byte Episode,       // Ex: 3 para Episode 3
    ClientLanguage Language  // Ex: ClientLanguage.English
)
```

### Exemplos de Versões

```csharp
// Season 6 Episode 3 (English) - Principal
new ClientVersion(6, 3, ClientLanguage.English)

// Extended S6E3 (MuMain)
new ClientVersion(106, 3, ClientLanguage.English)

// 0.95d
new ClientVersion(0, 95, ClientLanguage.English)

// 0.75
new ClientVersion(0, 75, ClientLanguage.Invariant)
```

---

## 🔐 Segurança e Autenticação

### Login

- **Método**: Username/Password
- **Criptografia**: Senha hash no banco de dados
- **Sessão**: Mantida durante conexão

### Contas de Teste

O servidor cria automaticamente contas de teste:
- **Usuários**: `test0` a `test9` (níveis 1-90)
- **Senha**: Mesmo que o usuário
- **Outras**: `test300`, `test400`, `testgm`, etc.

**⚠️ IMPORTANTE**: Remover contas de teste em produção!

---

## 📝 Checklist para Compatibilidade

Para garantir que um cliente seja compatível com OpenMU:

- [ ] Conecta na porta correta (44405 ou 44406)
- [ ] Implementa handshake inicial
- [ ] Envia versão do cliente corretamente
- [ ] Usa criptografia compatível com a versão
- [ ] Segue estrutura de pacotes MU Online
- [ ] Implementa todos os pacotes necessários
- [ ] Testa com servidor local primeiro
- [ ] Verifica logs do servidor para erros

---

## 🚀 Iniciar Servidor para Testes

### Quick Start

```bash
# 1. Navegar até diretório
cd deploy/all-in-one

# 2. Configurar senhas (primeira vez)
./alterar-senhas.sh

# 3. Iniciar servidor
docker compose up -d

# 4. Ver logs
docker compose logs -f openmu-startup
```

### Acessar Admin Panel

- **URL**: `http://localhost/`
- **Login**: `admin` / senha configurada no `.htpasswd`
- **Ações**: Iniciar Connect Servers e Game Servers

### Testar Conexão

1. Usar launcher oficial
2. Configurar IP: `127.127.127.127` (local)
3. Porta: `44405` (original) ou `44406` (MuMain)
4. Conectar e testar

---

## 📚 Recursos Adicionais

### Documentação do Projeto
- **README**: Informações gerais
- **QuickStart**: Guia rápido
- **Network Analyzer**: Ferramenta de análise de pacotes

### Comunidade
- **Discord**: https://discord.gg/2u5Agkd
- **Blog**: https://munique.net
- **GitHub**: https://github.com/MUnique/OpenMU

### Cliente Open Source
- **MuMain**: https://github.com/sven-n/MuMain
- **Protocolo Estendido**: Suportado na porta 44406

---

## 🎯 Resumo para Agentes de IA

**Informações Críticas:**
1. **Versão Principal**: Season 6 Episode 3 (English) - Porta 44405
2. **Cliente Open Source**: MuMain - Porta 44406 (protocolo estendido)
3. **IP Local**: Usar `127.127.127.127` (NÃO `127.0.0.1`)
4. **Protocolo**: TCP/IP com criptografia específica por versão
5. **Launcher**: Disponível para configuração automática

**Para Desenvolver Cliente Compatível:**
- Implementar conexão TCP na porta 44405 ou 44406
- Enviar versão do cliente no formato `ClientVersion(Season, Episode, Language)`
- Implementar criptografia conforme versão
- Seguir estrutura de pacotes MU Online
- Testar com servidor local primeiro

**Para Configurar Cliente Existente:**
- Usar launcher oficial (recomendado)
- Ou configurar registro do Windows manualmente
- Ou usar linha de comando: `main.exe connect /u{IP} /p{PORTA}`

---

**Última Atualização**: Baseado na análise do código OpenMU
