# 🚀 Guia Rápido - Alterar Senhas

## Opção 1: Usar o Script Automatizado (Recomendado)

Execute o script que criamos para você:

```bash
cd deploy/all-in-one
./alterar-senhas.sh
```

O script irá:
- ✅ Gerar uma senha segura para PostgreSQL
- ✅ Criar o arquivo `.env` automaticamente
- ✅ Criar o arquivo `.htpasswd` para o Admin Panel
- ✅ Verificar e atualizar o `.gitignore`

## Opção 2: Fazer Manualmente

Se preferir fazer manualmente, siga o guia completo:
- 📖 [GUIA_ALTERAR_SENHAS.md](GUIA_ALTERAR_SENHAS.md)

## ⚡ Passos Rápidos Após Alterar Senhas

1. **Parar containers existentes** (se estiverem rodando):
```bash
docker compose down
```

2. **Remover volume do banco** (⚠️ apaga dados!):
```bash
docker volume rm all-in-one_dbdata
```

3. **Iniciar com novas configurações**:
```bash
docker compose up -d
```

4. **Verificar logs**:
```bash
docker compose logs -f openmu-startup
```

5. **Acessar Admin Panel**:
- URL: `http://localhost/`
- Use as credenciais do `.htpasswd` que você criou

## 📝 Arquivos Criados/Modificados

- ✅ `docker-compose.yml` - Atualizado para usar variáveis de ambiente
- ✅ `env.example` - Arquivo de exemplo com todas as variáveis
- ✅ `alterar-senhas.sh` - Script automatizado
- ✅ `GUIA_ALTERAR_SENHAS.md` - Guia completo passo a passo
- ✅ `.gitignore` - Atualizado para proteger arquivos sensíveis

## ⚠️ Importante

- **NUNCA** commite o arquivo `.env` ou `.htpasswd`
- Anote as senhas em um local seguro (gerenciador de senhas)
- Teste em ambiente de desenvolvimento antes de produção

---

**Pronto para começar?** Execute `./alterar-senhas.sh` agora! 🎉
