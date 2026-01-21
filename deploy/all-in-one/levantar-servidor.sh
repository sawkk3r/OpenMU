#!/bin/bash

# Script interativo para levantar o servidor OpenMU

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Script para Levantar Servidor OpenMU${NC}"
echo "=========================================="
echo ""

# Verificar se está no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Erro: Execute este script no diretório deploy/all-in-one${NC}"
    exit 1
fi

# Verificar Docker
echo -e "${YELLOW}📋 Verificando pré-requisitos...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não está instalado!${NC}"
    echo "Instale Docker: https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose não está instalado!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker encontrado${NC}"

# Verificar se Docker está rodando
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker não está rodando!${NC}"
    echo "Inicie o Docker Desktop e tente novamente"
    exit 1
fi

echo -e "${GREEN}✅ Docker está rodando${NC}"
echo ""

# Verificar arquivo .env
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Arquivo .env não encontrado${NC}"
    read -p "Deseja criar agora? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        if [ -f "env.example" ]; then
            cp env.example .env
            echo -e "${GREEN}✅ Arquivo .env criado a partir de env.example${NC}"
            echo -e "${YELLOW}⚠️  IMPORTANTE: Edite o arquivo .env e configure as senhas!${NC}"
            read -p "Pressione Enter para continuar após editar o .env..."
        else
            echo -e "${RED}❌ Arquivo env.example não encontrado${NC}"
            exit 1
        fi
    else
        echo "Cancelado. Crie o arquivo .env manualmente antes de continuar."
        exit 0
    fi
else
    echo -e "${GREEN}✅ Arquivo .env encontrado${NC}"
fi

# Verificar .htpasswd
if [ ! -f ".htpasswd" ]; then
    echo -e "${YELLOW}⚠️  Arquivo .htpasswd não encontrado${NC}"
    read -p "Deseja criar agora? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        if command -v htpasswd &> /dev/null; then
            htpasswd -c -B .htpasswd admin
            echo -e "${GREEN}✅ Arquivo .htpasswd criado${NC}"
        else
            echo "Usando Docker para criar .htpasswd..."
            docker run --rm -v "$(pwd):/data" httpd:alpine htpasswd -c -B /data/.htpasswd admin
            echo -e "${GREEN}✅ Arquivo .htpasswd criado${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Você precisará criar .htpasswd antes de acessar o Admin Panel${NC}"
    fi
else
    echo -e "${GREEN}✅ Arquivo .htpasswd encontrado${NC}"
fi

echo ""
echo -e "${BLUE}🎯 Escolha o modo de deploy:${NC}"
echo "1) Local/Teste (HTTP apenas, sem domínio)"
echo "2) Produção (HTTPS com domínio)"
echo ""
read -p "Escolha (1 ou 2): " -n 1 -r
echo

if [[ $REPLY == "1" ]]; then
    echo -e "${GREEN}🚀 Iniciando servidor em modo Local/Teste...${NC}"
    docker compose up -d
    
    echo ""
    echo -e "${GREEN}✅ Servidor iniciado!${NC}"
    echo ""
    echo "📋 Informações:"
    echo "  • Admin Panel: http://localhost/"
    echo "  • Para ver logs: docker compose logs -f openmu-startup"
    echo "  • Para parar: docker compose down"
    echo ""
    
elif [[ $REPLY == "2" ]]; then
    # Verificar se DOMAIN_NAME está configurado
    if ! grep -q "DOMAIN_NAME=" .env || grep -q "DOMAIN_NAME=$" .env || grep -q "^DOMAIN_NAME=$" .env; then
        echo -e "${YELLOW}⚠️  DOMAIN_NAME não está configurado no .env${NC}"
        read -p "Digite seu domínio (ex: muonline.exemplo.com): " domain
        if [ -n "$domain" ]; then
            if grep -q "^DOMAIN_NAME=" .env; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "s/^DOMAIN_NAME=.*/DOMAIN_NAME=$domain/" .env
                else
                    sed -i "s/^DOMAIN_NAME=.*/DOMAIN_NAME=$domain/" .env
                fi
            else
                echo "DOMAIN_NAME=$domain" >> .env
            fi
            echo -e "${GREEN}✅ DOMAIN_NAME configurado${NC}"
        else
            echo -e "${RED}❌ Domínio é obrigatório para modo produção${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}🚀 Iniciando servidor em modo Produção...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
    
    echo ""
    echo -e "${GREEN}✅ Servidor iniciado!${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Próximos passos:${NC}"
    echo "  1. Obter certificado SSL (primeira vez):"
    DOMAIN=$(grep "^DOMAIN_NAME=" .env | cut -d '=' -f2)
    echo "     docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d $DOMAIN"
    echo ""
    echo "  2. Reiniciar nginx:"
    echo "     docker compose -f docker-compose.yml -f docker-compose.prod.yml restart nginx-443"
    echo ""
    echo "  3. Acessar Admin Panel:"
    echo "     https://$DOMAIN/"
    echo ""
    
else
    echo -e "${RED}❌ Opção inválida${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📊 Verificando status dos containers...${NC}"
docker compose ps

echo ""
echo -e "${GREEN}🎉 Pronto!${NC}"
echo ""
echo "Para ver logs em tempo real:"
echo "  docker compose logs -f openmu-startup"
echo ""
