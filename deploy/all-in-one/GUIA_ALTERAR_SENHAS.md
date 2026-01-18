# 🔐 Guia Prático: Alterar Senhas para Produção

Este guia mostra passo a passo como alterar todas as senhas padrão do OpenMU.

## ⚠️ IMPORTANTE

**NUNCA use senhas padrão em produção!** Este guia ajuda você a configurar senhas seguras.

## 📋 Senhas que Precisam ser Alteradas

1. ✅ **PostgreSQL Admin** (padrão: `admin`)
2. ✅ **Admin Panel HTTP Basic Auth** (padrão: `admin`/`openmu`)
3. ✅ **Usuários do Banco de Dados** (config, account, friend, guild)

---

## 🚀 Passo a Passo

### Passo 1: Gerar Senhas Seguras

Primeiro, vamos gerar senhas seguras. Você pode usar um dos métodos abaixo:

**Opção A: Usando OpenSSL (recomendado)**
```bash
# Gera uma senha aleatória de 32 caracteres
openssl rand -base64 24
```

**Opção B: Usando Python**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(24))"
```

**Opção C: Usar um gerenciador de senhas**
- Use um gerenciador como LastPass, 1Password, ou Bitwarden
- Gere senhas com pelo menos 20 caracteres
- Inclua letras maiúsculas, minúsculas, números e símbolos

**Anote as senhas geradas em um local seguro!**

---

### Passo 2: Configurar Variáveis de Ambiente

1. **Copie o arquivo de exemplo:**
```bash
cd deploy/all-in-one
cp .env.example .env
```

2. **Edite o arquivo `.env` e preencha com suas senhas:**
```bash
nano .env
# ou
vim .env
# ou use seu editor preferido
```

3. **Exemplo de `.env` preenchido:**
```bash
DB_HOST=database
DB_ADMIN_USER=postgres
DB_ADMIN_PW=SuaSenhaSeguraAqui123!@#
DOMAIN_NAME=seu-dominio.com
RESOLVE_IP=public
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://+:8080
```

⚠️ **IMPORTANTE**: Adicione `.env` ao `.gitignore` se ainda não estiver!

---

### Passo 3: Atualizar docker-compose.yml

Vamos atualizar o `docker-compose.yml` para usar as variáveis de ambiente:

**Antes:**
```yaml
database:
  environment:
    POSTGRES_PASSWORD: admin  # ❌ Senha padrão
```

**Depois:**
```yaml
database:
  environment:
    POSTGRES_PASSWORD: ${DB_ADMIN_PW}  # ✅ Usa variável de ambiente
```

E também adicionar as variáveis ao `openmu-startup`:
```yaml
openmu-startup:
  environment:
    DB_HOST: ${DB_HOST}
    DB_ADMIN_USER: ${DB_ADMIN_USER}
    DB_ADMIN_PW: ${DB_ADMIN_PW}
    ASPNETCORE_URLS: http://+:8080
```

---

### Passo 4: Criar/Atualizar arquivo .htpasswd

O arquivo `.htpasswd` contém as credenciais para o Admin Panel.

**Opção A: Usando htpasswd (se instalado)**
```bash
cd deploy/all-in-one

# Criar novo arquivo (substitui o existente)
htpasswd -c .htpasswd admin
# Digite a senha quando solicitado

# OU adicionar outro usuário (sem -c)
htpasswd .htpasswd outro-usuario
```

**Opção B: Usando Docker (se htpasswd não estiver instalado)**
```bash
cd deploy/all-in-one

# Criar novo arquivo
docker run --rm -v $(pwd):/data httpd:alpine htpasswd -c -B /data/.htpasswd admin
# Digite a senha quando solicitado

# OU adicionar outro usuário
docker run --rm -v $(pwd):/data httpd:alpine htpasswd -B /data/.htpasswd outro-usuario
```

**Opção C: Gerar hash manualmente (Python)**
```bash
python3 -c "import bcrypt; import getpass; pw = getpass.getpass('Senha: '); print('admin:' + bcrypt.hashpw(pw.encode(), bcrypt.gensalt()).decode())" >> .htpasswd
```

**Verificar o arquivo criado:**
```bash
cat .htpasswd
# Deve mostrar algo como: admin:$2y$10$...
```

⚠️ **IMPORTANTE**: O arquivo `.htpasswd` já existe com credenciais padrão. Você precisa substituí-lo!

---

### Passo 5: Atualizar ConnectionSettings.xml (Opcional)

O arquivo `ConnectionSettings.xml` contém senhas hardcoded. Se você usar variáveis de ambiente (`DB_ADMIN_PW`, `DB_ADMIN_USER`, `DB_HOST`), o sistema irá substituir automaticamente as senhas do admin.

**As senhas dos outros usuários (config, account, friend, guild) são criadas automaticamente pelo sistema** quando o banco é inicializado, então você não precisa alterá-las manualmente no XML se estiver usando Docker.

**Se quiser alterar manualmente**, edite:
```bash
src/Persistence/EntityFramework/ConnectionSettings.xml
```

⚠️ **Recomendação**: Use variáveis de ambiente ao invés de editar o XML diretamente.

---

### Passo 6: Verificar .gitignore

Certifique-se de que os arquivos sensíveis não sejam commitados:

```bash
# Verificar se .gitignore existe e contém:
cat .gitignore
```

**Deve conter:**
```
.env
.htpasswd
certbot/
*.log
```

Se não existir, crie:
```bash
cd deploy/all-in-one
cat > .gitignore << EOF
.env
.htpasswd
certbot/
*.log
EOF
```

---

### Passo 7: Testar as Configurações

1. **Parar containers existentes (se estiverem rodando):**
```bash
cd deploy/all-in-one
docker compose down
```

2. **Remover volume do banco (se já existir com senha antiga):**
```bash
# ⚠️ CUIDADO: Isso apaga todos os dados!
docker volume rm all-in-one_dbdata
```

3. **Iniciar com novas configurações:**
```bash
# Carregar variáveis do .env
export $(cat .env | grep -v '^#' | xargs)

# Iniciar serviços
docker compose up -d
```

4. **Verificar logs:**
```bash
docker compose logs -f openmu-startup
```

5. **Testar conexão ao Admin Panel:**
- Acesse: `http://localhost/` (ou seu domínio)
- Use as credenciais do `.htpasswd` que você criou
- Se conseguir acessar, está funcionando! ✅

---

## ✅ Checklist Final

- [ ] Senha do PostgreSQL alterada no `.env`
- [ ] Arquivo `.env` criado e preenchido
- [ ] `docker-compose.yml` atualizado para usar variáveis
- [ ] Arquivo `.htpasswd` recriado com nova senha
- [ ] `.gitignore` configurado para não commitar arquivos sensíveis
- [ ] Containers testados e funcionando
- [ ] Admin Panel acessível com novas credenciais

---

## 🔧 Comandos Úteis

### Verificar se variáveis estão sendo carregadas
```bash
docker compose config | grep POSTGRES_PASSWORD
```

### Verificar hash do .htpasswd
```bash
cat deploy/all-in-one/.htpasswd
```

### Testar senha do .htpasswd
```bash
docker run --rm -v $(pwd)/deploy/all-in-one:/data httpd:alpine htpasswd -v /data/.htpasswd admin
```

### Reiniciar serviços após alterações
```bash
cd deploy/all-in-one
docker compose restart
```

---

## 🆘 Problemas Comuns

### Erro: "password authentication failed"
- Verifique se a senha no `.env` está correta
- Verifique se o volume do banco foi recriado (senha antiga ainda está em cache)

### Erro: "403 Forbidden" no Admin Panel
- Verifique se o arquivo `.htpasswd` existe e está correto
- Verifique se o arquivo tem permissões corretas: `chmod 644 .htpasswd`

### Variáveis de ambiente não estão sendo carregadas
- Certifique-se de que o arquivo `.env` está no mesmo diretório do `docker-compose.yml`
- Verifique se não há espaços ao redor do `=` no `.env`
- Use `docker compose config` para verificar as variáveis carregadas

---

## 📝 Notas Importantes

1. **Backup**: Sempre faça backup antes de alterar senhas em produção
2. **Downtime**: Haverá um breve downtime ao alterar senhas
3. **Teste**: Teste em ambiente de desenvolvimento primeiro
4. **Documentação**: Mantenha as senhas documentadas em local seguro (gerenciador de senhas)

---

**Pronto!** Agora você tem todas as senhas configuradas de forma segura. 🎉
