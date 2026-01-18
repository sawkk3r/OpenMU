#!/bin/bash

# Script para verificar portas em uso e identificar conflitos potenciais

echo "🔍 Verificando Portas em Uso"
echo "=============================="
echo ""

# Portas usadas pelo OpenMU
OPENMU_PORTS=(80 443 44405 44406 55901 55902 55903 55904 55905 55906 55980 5432)

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📋 Portas usadas pelo OpenMU:"
echo "   HTTP: 80"
echo "   HTTPS: 443"
echo "   Connect Servers: 44405, 44406"
echo "   Game Servers: 55901-55906"
echo "   Chat Server: 55980"
echo "   PostgreSQL: 5432 (se exposto)"
echo ""

# Verificar sistema operacional
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "🔎 Verificando portas em uso (macOS)..."
    echo ""
    
    for port in "${OPENMU_PORTS[@]}"; do
        result=$(lsof -i :$port 2>/dev/null)
        if [ -n "$result" ]; then
            echo -e "${RED}❌ Porta $port está em uso:${NC}"
            echo "$result" | head -2
            echo ""
        else
            echo -e "${GREEN}✅ Porta $port está livre${NC}"
        fi
    done
else
    # Linux
    echo "🔎 Verificando portas em uso (Linux)..."
    echo ""
    
    for port in "${OPENMU_PORTS[@]}"; do
        result=$(netstat -tuln 2>/dev/null | grep ":$port ")
        if [ -n "$result" ]; then
            echo -e "${RED}❌ Porta $port está em uso:${NC}"
            echo "$result"
            echo ""
        else
            echo -e "${GREEN}✅ Porta $port está livre${NC}"
        fi
    done
fi

echo ""
echo "🐳 Containers Docker rodando:"
echo "=============================="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker não está rodando ou não está instalado"

echo ""
echo "📊 Portas mapeadas pelos containers Docker:"
echo "============================================"
docker ps --format "{{.Names}}: {{.Ports}}" 2>/dev/null | grep -E ":[0-9]+->" || echo "Nenhum container com portas mapeadas"

echo ""
echo "💡 Dica: Se alguma porta estiver em uso, você pode:"
echo "   1. Parar o processo/container que está usando"
echo "   2. Alterar a porta no docker-compose.yml"
echo "   3. Usar docker-compose.override.yml para personalizar portas"
