# ✅ Checklist Rápido - Deploy em Produção

## 🔴 Ações Críticas (OBRIGATÓRIAS)

- [ ] **Alterar senha do PostgreSQL**
  - Padrão: `admin` → Alterar via `DB_ADMIN_PW` ou `ConnectionSettings.xml`
  
- [ ] **Criar arquivo `.htpasswd` com credenciais seguras**
  ```bash
  cd deploy/all-in-one
  htpasswd -c .htpasswd admin
  ```
  - Remover credenciais padrão: `admin`/`openmu`
  
- [ ] **Configurar variável DOMAIN_NAME**
  ```bash
  export DOMAIN_NAME=seu-dominio.com
  ```
  
- [ ] **Configurar variáveis de ambiente do banco**
  ```bash
  export DB_ADMIN_PW=senha-segura
  export DB_HOST=database
  ```
  
- [ ] **Obter certificados SSL**
  ```bash
  docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d seu-dominio.com
  ```
  
- [ ] **Alterar senha do Admin Panel após primeiro login**
  - URL: `https://seu-dominio.com/`
  - Padrão: `admin`/`openmu` → Alterar imediatamente

## 🟡 Configurações Recomendadas

- [ ] **Configurar firewall**
  - Permitir: 80, 443, 44405, 44406, 55901-55906, 55980
  - Bloquear: 5432 (PostgreSQL) de acesso externo
  
- [ ] **Configurar backup automático do banco**
  ```bash
  # Adicionar ao crontab
  0 2 * * * docker exec database pg_dump -U postgres openmu > /backups/backup_$(date +\%Y\%m\%d).sql
  ```
  
- [ ] **Configurar renovação automática de certificados**
  ```bash
  # Adicionar ao crontab (semanal)
  0 0 * * 0 cd /caminho/para/OpenMU/deploy/all-in-one && docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot renew
  ```
  
- [ ] **Configurar rotação de logs**
  - Verificar `appsettings.json` (já configurado por padrão)
  
- [ ] **Configurar monitoramento** (opcional)
  - Logs, métricas, alertas

## 🟢 Verificações Pós-Deploy

- [ ] Admin Panel acessível via HTTPS
- [ ] Connect Servers iniciados
- [ ] Game Servers iniciados
- [ ] Banco de dados conectado
- [ ] Logs sendo gerados
- [ ] Cliente consegue conectar
- [ ] Certificados SSL válidos

## 📋 Comandos Úteis

### Iniciar em Produção
```bash
cd deploy/all-in-one
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Ver logs
```bash
docker compose logs -f openmu-startup
```

### Parar serviços
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
```

### Backup manual
```bash
docker exec database pg_dump -U postgres openmu > backup_$(date +%Y%m%d).sql
```

### Restore
```bash
docker exec -i database psql -U postgres openmu < backup_YYYYMMDD.sql
```

---

**⚠️ IMPORTANTE**: Nunca use senhas padrão em produção!
