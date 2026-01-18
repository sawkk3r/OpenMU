#!/bin/bash

# Script para ajudar a alterar senhas do OpenMU
# Este script guia você através do processo de alteração de senhas

set -e

echo "🔐 Script de Alteração de Senhas - OpenMU"
echo "=========================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar se estamos no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Erro: Este script deve ser executado no diretório deploy/all-in-one${NC}"
    exit 1
fi

echo -e "${YELLOW}Este script irá ajudá-lo a:${NC}"
echo "  1. Gerar senhas seguras"
echo "  2. Criar arquivo .env"
echo "  3. Criar arquivo .htpasswd"
echo ""

read -p "Deseja continuar? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# Passo 1: Gerar senha para PostgreSQL
echo ""
echo -e "${GREEN}Passo 1: Gerando senha segura para PostgreSQL...${NC}"
POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-25)
echo "Senha gerada: ${POSTGRES_PASSWORD}"
echo ""

# Passo 2: Criar arquivo .env
echo -e "${GREEN}Passo 2: Criando arquivo .env...${NC}"
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Arquivo .env já existe.${NC}"
    read -p "Deseja sobrescrever? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Pulando criação do .env"
    else
        cp env.example .env
        # Substituir a senha no arquivo
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/DB_ADMIN_PW=.*/DB_ADMIN_PW=${POSTGRES_PASSWORD}/" .env
        else
            # Linux
            sed -i "s/DB_ADMIN_PW=.*/DB_ADMIN_PW=${POSTGRES_PASSWORD}/" .env
        fi
        echo "✅ Arquivo .env criado/atualizado"
    fi
else
    cp env.example .env
    # Substituir a senha no arquivo
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/DB_ADMIN_PW=.*/DB_ADMIN_PW=${POSTGRES_PASSWORD}/" .env
    else
        # Linux
        sed -i "s/DB_ADMIN_PW=.*/DB_ADMIN_PW=${POSTGRES_PASSWORD}/" .env
    fi
    echo "✅ Arquivo .env criado"
fi

# Passo 3: Criar .htpasswd
echo ""
echo -e "${GREEN}Passo 3: Criando arquivo .htpasswd para Admin Panel...${NC}"
echo "Você precisará digitar uma senha para o usuário 'admin' do Admin Panel"
echo ""

# Verificar se htpasswd está instalado
if command -v htpasswd &> /dev/null; then
    if [ -f ".htpasswd" ]; then
        echo -e "${YELLOW}⚠️  Arquivo .htpasswd já existe.${NC}"
        read -p "Deseja criar um novo? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            htpasswd -c -B .htpasswd admin
            echo "✅ Arquivo .htpasswd criado"
        else
            echo "Pulando criação do .htpasswd"
        fi
    else
        htpasswd -c -B .htpasswd admin
        echo "✅ Arquivo .htpasswd criado"
    fi
else
    echo -e "${YELLOW}htpasswd não está instalado. Usando Docker...${NC}"
    if [ -f ".htpasswd" ]; then
        echo -e "${YELLOW}⚠️  Arquivo .htpasswd já existe.${NC}"
        read -p "Deseja criar um novo? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            docker run --rm -v "$(pwd):/data" httpd:alpine htpasswd -c -B /data/.htpasswd admin
            echo "✅ Arquivo .htpasswd criado"
        else
            echo "Pulando criação do .htpasswd"
        fi
    else
        docker run --rm -v "$(pwd):/data" httpd:alpine htpasswd -c -B /data/.htpasswd admin
        echo "✅ Arquivo .htpasswd criado"
    fi
fi

# Passo 4: Verificar .gitignore
echo ""
echo -e "${GREEN}Passo 4: Verificando .gitignore...${NC}"
if [ -f "../.gitignore" ] || [ -f "../../.gitignore" ]; then
    GITIGNORE_FILE=""
    if [ -f "../../.gitignore" ]; then
        GITIGNORE_FILE="../../.gitignore"
    elif [ -f "../.gitignore" ]; then
        GITIGNORE_FILE="../.gitignore"
    fi
    
    if [ -n "$GITIGNORE_FILE" ]; then
        if grep -q "^\.env$" "$GITIGNORE_FILE" 2>/dev/null || grep -q "\.env" "$GITIGNORE_FILE" 2>/dev/null; then
            echo "✅ .env está no .gitignore"
        else
            echo -e "${YELLOW}⚠️  .env não está no .gitignore. Adicionando...${NC}"
            echo "" >> "$GITIGNORE_FILE"
            echo "# OpenMU - Arquivos sensíveis" >> "$GITIGNORE_FILE"
            echo ".env" >> "$GITIGNORE_FILE"
            echo ".htpasswd" >> "$GITIGNORE_FILE"
            echo "✅ Adicionado ao .gitignore"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  Arquivo .gitignore não encontrado. Criando local...${NC}"
    cat > .gitignore << EOF
# Arquivos sensíveis - NUNCA commitar
.env
.htpasswd
certbot/
*.log
EOF
    echo "✅ .gitignore criado localmente"
fi

# Resumo
echo ""
echo -e "${GREEN}=========================================="
echo "✅ Configuração concluída!"
echo "==========================================${NC}"
echo ""
echo "📝 Resumo:"
echo "  • Arquivo .env criado/atualizado"
echo "  • Senha do PostgreSQL: ${POSTGRES_PASSWORD}"
echo "  • Arquivo .htpasswd criado/atualizado"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo "  1. Anote a senha do PostgreSQL em local seguro!"
echo "  2. A senha está salva no arquivo .env"
echo "  3. Se você já tinha containers rodando, será necessário:"
echo "     - docker compose down"
echo "     - docker volume rm all-in-one_dbdata  (⚠️ apaga dados!)"
echo "     - docker compose up -d"
echo ""
echo "Próximos passos:"
echo "  1. Edite o arquivo .env e configure DOMAIN_NAME se necessário"
echo "  2. Inicie os containers: docker compose up -d"
echo "  3. Acesse o Admin Panel e altere a senha padrão"
echo ""
