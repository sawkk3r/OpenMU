# 🚀 Como Iniciar o Servidor OpenMU

Guia passo a passo para iniciar o servidor MU Online.

## 📋 Pré-requisitos

✅ Docker Desktop instalado e rodando  
✅ Portas livres: 80, 44405-44406, 55901-55906, 55980

## 🎯 Passo a Passo

### Passo 1: Verificar Docker Desktop

Certifique-se de que o **Docker Desktop** está rodando:
- Procure pelo ícone do Docker na bandeja do sistema
- Se não estiver rodando, inicie o Docker Desktop
- Aguarde até aparecer "Docker Desktop is running"

### Passo 2: Abrir Terminal

Abra o PowerShell ou Prompt de Comando no diretório do projeto:
```
C:\GitHub\OpenMU
```

### Passo 3: Navegar para a Pasta de Deploy

```powershell
cd deploy\all-in-one
```

### Passo 4: Iniciar o Servidor

Execute o comando:

```powershell
docker compose up -d --no-build
```

### Passo 5: Aguardar Inicialização

Aguarde alguns segundos enquanto:
- As imagens Docker são baixadas (primeira vez)
- O banco de dados é criado e inicializado
- Os servidores são iniciados

### Passo 6: Verificar se Está Funcionando

Verifique o status:

```powershell
docker compose ps
```

Você deve ver 3 containers rodando:
- ✅ `database` (PostgreSQL)
- ✅ `openmu-startup` (Servidor OpenMU)
- ✅ `nginx-80` (Proxy reverso)

### Passo 7: Acessar o Painel Administrativo

Abra seu navegador e acesse:

**http://localhost/**

- Usuário: `admin`
- Senha: `openmu`

## 📝 Comandos Rápidos

### Ver Logs do Servidor
```powershell
docker compose logs -f openmu-startup
```

### Parar o Servidor
```powershell
docker compose down
```

### Reiniciar o Servidor
```powershell
docker compose restart
```

### Ver Status
```powershell
docker compose ps
```

## ⚠️ Problemas Comuns

### Docker não está rodando
**Solução:** Inicie o Docker Desktop

### Erro de portas ocupadas
**Solução:** Verifique se nenhum outro programa está usando as portas:
- 80 (HTTP)
- 44405, 44406 (Connect Servers)
- 55901-55906 (Game Servers)
- 55980 (Chat Server)

### Containers não iniciam
**Solução:** Verifique os logs:
```powershell
docker compose logs
```

## ✅ Pronto!

Quando ver os 3 containers rodando, o servidor está ativo e pronto para conexão!

Para conectar ao jogo, consulte o [GUIA-CONEXAO.md](GUIA-CONEXAO.md)
