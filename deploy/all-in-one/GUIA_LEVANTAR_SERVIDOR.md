# 🚀 Guia Completo: Levantar o Servidor OpenMU

Este guia mostra **exatamente** o que você precisa fazer para colocar o servidor no ar, passo a passo.

---

## 📋 Pré-requisitos

### 1. Software Necessário

#### ✅ Docker e Docker Compose

**Verificar se está instalado:**
```bash
docker --version
docker compose version
```

**Se não estiver instalado:**

**macOS:**
```bash
# Instalar Docker Desktop
brew install --cask docker
# Ou baixar de: https://www.docker.com/products/docker-desktop
```

**Linux (Ubuntu/Debian):**
```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

**Windows:**
- Baixar Docker Desktop: https://www.docker.com/products/docker-desktop

#### ✅ Git (opcional, se ainda não tiver o código)

**Verificar:**
```bash
git --version
```

**Instalar (se necessário):**
- macOS: `brew install git`
- Linux: `sudo apt-get install git`
- Windows: https://git-scm.com/download/win

### 2. Recursos do Sistema

- **CPU**: Mínimo 2 cores (recomendado 4+)
- **RAM**: Mínimo 4GB (recomendado 8GB+)
- **Disco**: Mínimo 20GB livre
- **Portas livres**: 80, 443, 44405, 44406, 55901-55906, 55980

### 3. Verificar Portas

Execute o script que criamos:
```bash
cd deploy/all-in-one
./verificar-portas.sh
```

Ou verifique manualmente:
```bash
# macOS
lsof -i :80

# Linux
netstat -tuln | grep :80
```

---

## 🎯 Passo a Passo Completo

### Passo 1: Navegar até o Diretório

```bash
cd /Users/vcr/Documents/GitHub/OpenMU/deploy/all-in-one
```

### Passo 2: Verificar Pré-requisitos

```bash
# Verificar Docker
docker --version
docker compose version

# Verificar portas
./verificar-portas.sh
```

### Passo 3: Configurar Senhas (IMPORTANTE!)

**Opção A: Usar o script automatizado (Recomendado)**
```bash
./alterar-senhas.sh
```

**Opção B: Manual**
```bash
# 1. Copiar arquivo de exemplo
cp env.example .env

# 2. Editar .env e preencher senhas
nano .env  # ou use seu editor preferido

# 3. Criar .htpasswd para Admin Panel
htpasswd -c -B .htpasswd admin
# OU usando Docker:
docker run --rm -v $(pwd):/data httpd:alpine htpasswd -c -B /data/.htpasswd admin
```

### Passo 4: Configurar Variáveis de Ambiente

Edite o arquivo `.env` (se ainda não fez):

```bash
nano .env
```

**Configuração mínima necessária:**
```bash
DB_HOST=database
DB_ADMIN_USER=postgres
DB_ADMIN_PW=SUA_SENHA_SEGURA_AQUI
RESOLVE_IP=public  # ou 'local' ou 'loopback' para testes
ASPNETCORE_ENVIRONMENT=Production
```

**Para produção com domínio:**
```bash
DOMAIN_NAME=seu-dominio.com
```

### Passo 5: Escolher Modo de Deploy

#### 🏠 Opção A: Deploy Local/Teste (Mais Simples)

Ideal para:
- Testes locais
- Desenvolvimento
- Não precisa de domínio

```bash
# Iniciar servidor
docker compose up -d

# Ver logs
docker compose logs -f openmu-startup
```

**Acessar Admin Panel:**
- URL: `http://localhost/`
- Usuário: `admin` (ou o que você configurou no .htpasswd)
- Senha: a que você criou no .htpasswd

#### 🌐 Opção B: Deploy em Produção com HTTPS

Ideal para:
- Servidor público
- Acesso pela internet
- Segurança com SSL

**5.1. Configurar domínio no .env:**
```bash
DOMAIN_NAME=seu-dominio.com
```

**5.2. Iniciar serviços:**
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

**5.3. Obter certificado SSL (primeira vez):**
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d seu-dominio.com
```

**5.4. Reiniciar nginx para aplicar HTTPS:**
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart nginx-443
```

**5.5. Configurar renovação automática de certificados:**
```bash
# Adicionar ao crontab (executar semanalmente)
0 0 * * 0 cd /caminho/para/OpenMU/deploy/all-in-one && docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot renew
```

**Acessar Admin Panel:**
- URL: `https://seu-dominio.com/`
- Usuário: `admin` (ou o que você configurou no .htpasswd)
- Senha: a que você criou no .htpasswd

### Passo 6: Verificar se Está Funcionando

```bash
# Ver status dos containers
docker compose ps

# Ver logs do servidor
docker compose logs -f openmu-startup

# Ver logs do banco de dados
docker compose logs -f database

# Ver todos os logs
docker compose logs -f
```

**Verificar se os serviços estão rodando:**
- ✅ `openmu-startup` - Status: Up
- ✅ `database` - Status: Up
- ✅ `nginx-80` - Status: Up (e `nginx-443` se usar HTTPS)

### Passo 7: Configurar no Admin Panel

1. **Acessar Admin Panel**
   - Local: `http://localhost/`
   - Produção: `https://seu-dominio.com/`

2. **Fazer Login**
   - Usuário: `admin` (ou o configurado no .htpasswd)
   - Senha: a que você criou

3. **Alterar Senha do Admin** (IMPORTANTE!)
   - Ir em configurações e alterar a senha padrão

4. **Configurar Auto Start** (Opcional)
   - Ir em `Configuration -> System`
   - Ativar "Auto Start" se quiser que os servidores iniciem automaticamente

5. **Configurar IP Resolver** (Se necessário)
   - Ir em `Configuration -> System`
   - Ajustar conforme sua infraestrutura

6. **Iniciar Servidores**
   - Na página inicial do Admin Panel
   - Clicar em "Start" nos Connect Servers
   - Clicar em "Start" nos Game Servers que deseja usar

### Passo 8: Testar Conexão do Cliente

1. **Baixar Launcher:**
   - [MUnique.OpenMU.ClientLauncher v0.9.6](https://github.com/MUnique/OpenMU/releases/download/v0.9.0/MUnique.OpenMU.ClientLauncher_0.9.6.zip)

2. **Configurar IP do Servidor:**
   - Se local: usar `127.127.127.127` (não use `127.0.0.1`)
   - Se produção: usar seu IP público ou domínio

3. **Conectar:**
   - Usar uma das contas de teste (veja QuickStart.md)
   - Ou criar nova conta pelo Admin Panel

---

## 🔧 Comandos Úteis

### Gerenciar Servidor

```bash
# Iniciar
docker compose up -d

# Parar
docker compose down

# Reiniciar
docker compose restart

# Ver status
docker compose ps

# Ver logs
docker compose logs -f [nome-do-servico]

# Parar e remover volumes (⚠️ apaga dados!)
docker compose down -v
```

### Troubleshooting

```bash
# Ver logs de erro
docker compose logs | grep -i error

# Reiniciar um serviço específico
docker compose restart openmu-startup

# Ver uso de recursos
docker stats

# Acessar shell do container
docker exec -it openmu-startup sh
```

---

## ✅ Checklist Final

Antes de considerar o servidor "no ar":

- [ ] Docker e Docker Compose instalados
- [ ] Portas necessárias estão livres
- [ ] Arquivo `.env` criado e configurado
- [ ] Arquivo `.htpasswd` criado
- [ ] Containers iniciados e rodando
- [ ] Admin Panel acessível
- [ ] Senha do admin alterada
- [ ] Connect Servers iniciados
- [ ] Game Servers iniciados
- [ ] Cliente consegue conectar
- [ ] (Produção) HTTPS configurado
- [ ] (Produção) Certificados SSL válidos

---

## 🆘 Problemas Comuns

### Erro: "port is already allocated"

**Solução:**
```bash
# Ver qual processo está usando a porta
lsof -i :80

# Parar o processo ou alterar porta no docker-compose.yml
```

### Erro: "Cannot connect to database"

**Solução:**
```bash
# Verificar se o container do banco está rodando
docker compose ps database

# Ver logs do banco
docker compose logs database

# Reiniciar banco
docker compose restart database
```

### Erro: "403 Forbidden" no Admin Panel

**Solução:**
```bash
# Verificar se .htpasswd existe
ls -la .htpasswd

# Recriar .htpasswd
htpasswd -c -B .htpasswd admin
```

### Containers não iniciam

**Solução:**
```bash
# Ver logs detalhados
docker compose logs

# Verificar recursos do sistema
docker stats

# Limpar e reiniciar
docker compose down
docker compose up -d
```

---

## 📚 Próximos Passos

Após o servidor estar rodando:

1. **Configurar Backup do Banco de Dados**
   - Ver seção de backup em `ANALISE_PRODUCAO.md`

2. **Configurar Monitoramento**
   - Logs, métricas, alertas

3. **Otimizar Performance**
   - Ajustar recursos conforme necessário

4. **Configurar Firewall**
   - Permitir apenas portas necessárias

---

## 🎉 Pronto!

Seu servidor OpenMU está no ar! 🚀

**Ainda com dúvidas?** Consulte:
- `GUIA_ALTERAR_SENHAS.md` - Para questões de senhas
- `ANALISE_PRODUCAO.md` - Para detalhes de produção
- `CHECKLIST_PRODUCAO.md` - Checklist rápido
- `GUIA_MULTIPLOS_DOCKER.md` - Para rodar múltiplos projetos
