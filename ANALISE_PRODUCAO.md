# Análise: Requisitos para Colocar o Servidor OpenMU em Produção

## 📋 Resumo Executivo

Este documento analisa o código do servidor OpenMU e identifica todos os requisitos e configurações necessárias para colocar o servidor em produção.

## 🎯 Opções de Deploy

O projeto oferece três opções principais de deploy:

1. **All-in-one** (Recomendado para pequenos servidores)
2. **All-in-one com Traefik** (Para múltiplos sites/domínios)
3. **Distributed** (Atualmente quebrado e não suportado)

## ✅ Requisitos de Infraestrutura

### Portas TCP Necessárias

| Porta | Serviço | Descrição |
|-------|---------|-----------|
| 80 | HTTP | Admin Panel (redireciona para HTTPS em produção) |
| 443 | HTTPS | Admin Panel (produção) |
| 44405 | Connect Server | Porta padrão para cliente original |
| 44406 | Connect Server | Porta para cliente open source |
| 55901-55906 | Game Servers | Servidores de jogo (até 6 servidores) |
| 55980 | Chat Server | Servidor de chat |
| 5432 | PostgreSQL | Banco de dados (interno ao Docker) |

### Recursos de Sistema

- **CPU**: Mínimo 2 cores (recomendado 4+)
- **RAM**: Mínimo 4GB (recomendado 8GB+)
- **Disco**: Mínimo 20GB (recomendado 50GB+ para logs e dados)
- **Rede**: Conexão estável com IP público (se for acessível externamente)

## 🔧 Configurações Necessárias

### 1. Banco de Dados PostgreSQL

**Configuração Atual (padrão):**
- Host: `localhost` (ou `database` no Docker)
- Porta: `5432`
- Database: `openmu`
- Usuário Admin: `postgres`
- Senha Admin: `admin` ⚠️ **DEVE SER ALTERADA EM PRODUÇÃO**

**Variáveis de Ambiente para Produção:**
```bash
DB_HOST=seu-host-postgres
DB_ADMIN_USER=seu-usuario-admin
DB_ADMIN_PW=senha-segura-forte
```

**Usuários do Banco (criados automaticamente):**
- `postgres` (admin) - cria/atualiza database e roles
- `config` - acesso apenas ao schema de configuração
- `account` - acesso a dados de conta e trade
- `friend` - acesso a dados de amigos
- `guild` - acesso a dados de guild

⚠️ **AÇÃO NECESSÁRIA**: Alterar senhas padrão no `ConnectionSettings.xml` ou usar variáveis de ambiente.

### 2. Configuração de Domínio (Produção com HTTPS)

**Variável de Ambiente:**
```bash
DOMAIN_NAME=seu-dominio.com
```

**Requisitos:**
- Domínio apontando para o IP do servidor
- Certificados SSL (Let's Encrypt via Certbot)
- Configuração de renovação automática de certificados

### 3. Autenticação do Admin Panel

**Arquivo Necessário**: `.htpasswd`

**Credenciais Padrão:**
- Usuário: `admin`
- Senha: `openmu` ⚠️ **DEVE SER ALTERADA EM PRODUÇÃO**

**Como criar o arquivo:**
```bash
htpasswd -c .htpasswd admin
```

⚠️ **AÇÃO NECESSÁRIA**: Criar arquivo `.htpasswd` com credenciais seguras.

### 4. Configuração de IP Resolver

**Para servidor local/teste:**
```bash
RESOLVE_IP=loopback  # ou 127.127.127.127
```

**Para servidor público:**
```bash
RESOLVE_IP=public  # ou IP específico
```

**Ou via parâmetro:**
```bash
-resolveIP:public
```

### 5. Variáveis de Ambiente do .NET

```bash
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://+:8080
```

## 📦 Deploy com Docker (Recomendado)

### Opção A: Deploy Local/Teste

```bash
cd deploy/all-in-one
docker compose up -d --no-build
```

### Opção B: Deploy em Produção com HTTPS

1. **Configurar variável de ambiente:**
```bash
export DOMAIN_NAME=seu-dominio.com
```

2. **Iniciar serviços:**
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

3. **Obter certificado SSL (primeira vez):**
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d seu-dominio.com
```

4. **Configurar renovação automática:**
Adicionar ao crontab:
```bash
0 0 * * 0 docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot renew
```

## 🔒 Checklist de Segurança

### ⚠️ Ações Críticas Antes de Colocar em Produção:

- [ ] **Alterar senha do PostgreSQL** (padrão: `admin`)
  - Via variável `DB_ADMIN_PW` ou editar `ConnectionSettings.xml`
  
- [ ] **Criar arquivo `.htpasswd`** com credenciais seguras
  - Remover credenciais padrão (`admin`/`openmu`)
  
- [ ] **Configurar HTTPS** com certificados válidos
  - Não expor admin panel sem HTTPS em produção
  
- [ ] **Alterar credenciais do Admin Panel** após primeiro login
  - Acessar: `http://seu-dominio.com/` ou `https://seu-dominio.com/`
  - Usuário padrão: `admin`, senha: `openmu`
  
- [ ] **Configurar firewall** para permitir apenas portas necessárias
  - Bloquear acesso direto ao PostgreSQL (porta 5432) de fora
  
- [ ] **Configurar backup do banco de dados**
  - PostgreSQL precisa de backup regular
  
- [ ] **Configurar logs** adequadamente
  - Logs são salvos em `/app/logs/` dentro do container
  - Configurar rotação de logs
  
- [ ] **Revisar configurações de auto-start**
  - Verificar se `-autostart` está configurado corretamente
  
- [ ] **Configurar monitoramento** (opcional mas recomendado)
  - Logs, métricas, alertas

## 📝 Arquivos de Configuração Importantes

### Arquivos que DEVEM ser revisados/alterados:

1. **`deploy/all-in-one/docker-compose.yml`**
   - Verificar variáveis de ambiente
   - Verificar mapeamento de portas

2. **`deploy/all-in-one/docker-compose.prod.yml`**
   - Configurar `DOMAIN_NAME`
   - Verificar configurações de restart

3. **`src/Persistence/EntityFramework/ConnectionSettings.xml`**
   - ⚠️ Contém senhas padrão - deve ser alterado ou usar variáveis de ambiente

4. **`.htpasswd`** (criar se não existir)
   - Arquivo de autenticação HTTP básica para admin panel

5. **`src/Startup/appsettings.json`**
   - Configuração de logging
   - Pode ser ajustado para produção

### Arquivos que NÃO devem ser commitados:

- `.htpasswd` (contém senhas)
- Certificados SSL (`certbot/conf/`)
- Volumes do banco de dados

## 🚀 Passos para Deploy em Produção

### 1. Preparação do Ambiente

```bash
# Clonar repositório
git clone https://github.com/MUnique/OpenMU.git
cd OpenMU/deploy/all-in-one

# Criar arquivo .htpasswd
htpasswd -c .htpasswd admin
# Digite uma senha segura quando solicitado
```

### 2. Configurar Variáveis de Ambiente

Criar arquivo `.env` ou exportar variáveis:

```bash
export DOMAIN_NAME=seu-dominio.com
export DB_ADMIN_PW=senha-super-segura-aqui
export DB_HOST=database
export RESOLVE_IP=public
export ASPNETCORE_ENVIRONMENT=Production
```

### 3. Iniciar Serviços

```bash
# Primeira vez (sem HTTPS ainda)
docker compose up -d

# Após configurar domínio, usar produção
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 4. Obter Certificados SSL

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d seu-dominio.com
```

### 5. Reiniciar Nginx para aplicar HTTPS

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart nginx-443
```

### 6. Acessar Admin Panel

- URL: `https://seu-dominio.com/`
- Usuário: `admin`
- Senha: `openmu` (alterar imediatamente)

### 7. Configurar no Admin Panel

1. Acessar `Configuration -> System`
2. Configurar "Auto Start" se necessário
3. Configurar "IP Resolver" se necessário
4. Alterar senha do admin
5. Iniciar Connect Servers e Game Servers

## 🔍 Verificações Pós-Deploy

- [ ] Admin Panel acessível via HTTPS
- [ ] Connect Servers iniciados e escutando nas portas corretas
- [ ] Game Servers iniciados
- [ ] Banco de dados conectado e funcionando
- [ ] Logs sendo gerados corretamente
- [ ] Cliente consegue conectar ao servidor
- [ ] Certificados SSL válidos e renovação configurada

## 📊 Monitoramento e Manutenção

### Logs

Os logs são salvos em:
- Container: `/app/logs/log.txt`
- Host: Pode ser mapeado via volume Docker

### Backup do Banco de Dados

```bash
# Backup
docker exec database pg_dump -U postgres openmu > backup_$(date +%Y%m%d).sql

# Restore
docker exec -i database psql -U postgres openmu < backup_YYYYMMDD.sql
```

### Renovação de Certificados

Configurar cron job semanal:
```bash
0 0 * * 0 cd /caminho/para/OpenMU/deploy/all-in-one && docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot renew
```

## ⚠️ Problemas Conhecidos

1. **Deploy Distribuído**: Atualmente quebrado e não suportado
2. **Senhas Padrão**: Todas as senhas padrão devem ser alteradas
3. **Certificados SSL**: Requerem configuração manual na primeira vez
4. **IP Resolver**: Pode precisar de ajuste dependendo da infraestrutura

## 📚 Recursos Adicionais

- [Quick Start Guide](QuickStart.md)
- [Deploy README](deploy/README.md)
- [All-in-one README](deploy/all-in-one/README.md)
- [Documentação do Projeto](docs/Readme.md)

## 🎮 Cliente do Jogo

**Importante**: Você precisará de um cliente MU Online compatível:
- Cliente original Season 6 Episode 3 (porta 44405)
- Cliente open source MuMain (porta 44406)
- Launcher: [MUnique.OpenMU.ClientLauncher v0.9.6](https://github.com/MUnique/OpenMU/releases/download/v0.9.0/MUnique.OpenMU.ClientLauncher_0.9.6.zip)

## 📞 Suporte

- Discord: https://discord.gg/2u5Agkd
- Issues: https://github.com/MUnique/OpenMU/issues
- Blog: https://munique.net

---

**Última atualização**: Baseado na análise do código em $(date)
