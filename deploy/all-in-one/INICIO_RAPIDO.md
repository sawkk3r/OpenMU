# ⚡ Início Rápido - OpenMU

## 🎯 Para Levantar o Servidor AGORA

### Opção 1: Script Automatizado (Mais Fácil) 🚀

```bash
cd deploy/all-in-one
./levantar-servidor.sh
```

O script vai:
- ✅ Verificar pré-requisitos
- ✅ Criar arquivos necessários
- ✅ Guiar você pelo processo
- ✅ Iniciar o servidor

### Opção 2: Manual (3 Comandos) 📝

```bash
# 1. Configurar senhas
./alterar-senhas.sh

# 2. Iniciar servidor (local)
docker compose up -d

# 3. Ver logs
docker compose logs -f openmu-startup
```

**Acessar:** http://localhost/

---

## 📋 Pré-requisitos Mínimos

- ✅ Docker instalado e rodando
- ✅ Portas livres: 80, 44405, 44406, 55901-55906, 55980
- ✅ 4GB RAM, 20GB disco

**Verificar:**
```bash
docker --version
./verificar-portas.sh
```

---

## 🔐 Configuração de Senhas

**IMPORTANTE:** Antes de colocar em produção, altere as senhas!

```bash
./alterar-senhas.sh
```

Ou manualmente:
1. `cp env.example .env` e edite
2. Crie `.htpasswd` com `htpasswd -c -B .htpasswd admin`

---

## 🌐 Modos de Deploy

### 🏠 Local/Teste
```bash
docker compose up -d
```
- Acesso: `http://localhost/`
- Sem domínio necessário
- Sem HTTPS

### 🌍 Produção
```bash
# 1. Configure DOMAIN_NAME no .env
# 2. Iniciar
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 3. Obter certificado SSL (primeira vez)
docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d seu-dominio.com
```
- Acesso: `https://seu-dominio.com/`
- Requer domínio
- Com HTTPS

---

## 🎮 Após Iniciar

1. **Acessar Admin Panel**
   - Local: http://localhost/
   - Produção: https://seu-dominio.com/
   - Login: `admin` / senha do `.htpasswd`

2. **Iniciar Servidores**
   - No Admin Panel, clique em "Start" nos:
     - Connect Servers
     - Game Servers

3. **Conectar Cliente**
   - Baixar launcher: [MUnique.OpenMU.ClientLauncher](https://github.com/MUnique/OpenMU/releases/download/v0.9.0/MUnique.OpenMU.ClientLauncher_0.9.6.zip)
   - Configurar IP: `127.127.127.127` (local) ou seu IP/domínio

---

## 🆘 Comandos Úteis

```bash
# Ver status
docker compose ps

# Ver logs
docker compose logs -f openmu-startup

# Parar
docker compose down

# Reiniciar
docker compose restart
```

---

## 📚 Documentação Completa

- 📖 [GUIA_LEVANTAR_SERVIDOR.md](GUIA_LEVANTAR_SERVIDOR.md) - Guia completo passo a passo
- 🔐 [GUIA_ALTERAR_SENHAS.md](GUIA_ALTERAR_SENHAS.md) - Configurar senhas
- 🐳 [GUIA_MULTIPLOS_DOCKER.md](../../GUIA_MULTIPLOS_DOCKER.md) - Rodar múltiplos projetos
- ✅ [CHECKLIST_PRODUCAO.md](../../CHECKLIST_PRODUCAO.md) - Checklist de produção

---

**Pronto para começar?** Execute `./levantar-servidor.sh` 🚀
