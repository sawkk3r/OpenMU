# 🐳 Guia: Rodar Múltiplos Projetos Docker Simultaneamente

## ✅ Resposta Rápida

**Sim, você pode rodar múltiplos projetos Docker ao mesmo tempo!** Mas precisa ter cuidado com:

1. **Conflitos de portas** - Cada projeto precisa usar portas diferentes
2. **Recursos do sistema** - CPU, RAM e disco são compartilhados
3. **Nomes de containers** - Cada container precisa ter um nome único

---

## 🔌 Portas Usadas pelo OpenMU

O OpenMU usa as seguintes portas (que podem conflitar com outros projetos):

| Porta | Serviço | Pode Conflitar? |
|-------|---------|-----------------|
| **80** | HTTP (Admin Panel) | ⚠️ **SIM** - Muito comum |
| **443** | HTTPS (Admin Panel) | ⚠️ **SIM** - Muito comum |
| **44405** | Connect Server (cliente original) | ❌ Raro |
| **44406** | Connect Server (cliente open source) | ❌ Raro |
| **55901-55906** | Game Servers (6 servidores) | ❌ Raro |
| **55980** | Chat Server | ❌ Raro |
| **5432** | PostgreSQL | ⚠️ **SIM** - Se exposto |

**Nota**: No `docker-compose.yml` atual, a porta 5432 do PostgreSQL **não está exposta** (sem mapeamento `HOST:CONTAINER`), então não há conflito externo.

---

## 🛠️ Soluções para Conflitos de Portas

### Opção 1: Alterar Portas no docker-compose.yml (Recomendado)

Você pode alterar as portas do OpenMU para evitar conflitos:

**Exemplo: Alterar porta HTTP de 80 para 8080**

```yaml
nginx-80:
  ports:
    - "8080:80"  # Acessa via localhost:8080
```

**Exemplo: Alterar portas dos Game Servers**

```yaml
openmu-startup:
  ports:
    - "56001:55901"  # Game Server 1
    - "56002:55902"  # Game Server 2
    # etc...
```

### Opção 2: Usar docker-compose.override.yml

Crie um arquivo `docker-compose.override.yml` para alterar portas sem modificar o arquivo original:

```yaml
services:
  nginx-80:
    ports:
      - "8080:80"  # Muda porta HTTP para 8080
  
  openmu-startup:
    ports:
      - "56001:55901"
      - "56002:55902"
      # etc...
```

### Opção 3: Usar Redes Docker Separadas

Cada projeto pode usar uma rede Docker diferente, mas as portas do host ainda precisam ser únicas.

---

## 📊 Recursos do Sistema

### Verificar Recursos Disponíveis

```bash
# Ver uso de CPU e RAM
docker stats

# Ver espaço em disco
df -h

# Ver containers rodando
docker ps
```

### Limites Recomendados

| Recurso | OpenMU Mínimo | Para 2 Projetos |
|---------|---------------|------------------|
| **CPU** | 2 cores | 4+ cores |
| **RAM** | 4GB | 8GB+ |
| **Disco** | 20GB | 40GB+ |

---

## 🔍 Verificar Portas em Uso

### Ver quais portas estão sendo usadas:

```bash
# macOS/Linux
lsof -i -P -n | grep LISTEN
# ou
netstat -an | grep LISTEN

# Ver portas usadas pelo Docker
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

### Verificar se uma porta específica está livre:

```bash
# Testar porta 80
lsof -i :80

# Se não retornar nada, a porta está livre
```

---

## 💡 Exemplos Práticos

### Exemplo 1: OpenMU + Outro Servidor Web

**Problema**: Ambos querem usar porta 80

**Solução**: 
- OpenMU: usar porta 8080
- Outro servidor: usar porta 80

```yaml
# docker-compose.override.yml do OpenMU
services:
  nginx-80:
    ports:
      - "8080:80"
```

### Exemplo 2: OpenMU + Outro PostgreSQL

**Problema**: Ambos querem expor PostgreSQL na porta 5432

**Solução**:
- OpenMU: manter PostgreSQL interno (sem expor)
- Outro projeto: usar porta 5432 ou 5433

```yaml
# OpenMU já está configurado assim (sem expor):
database:
  ports:
    - "5432"  # Sem mapeamento = não expõe externamente
```

### Exemplo 3: Dois OpenMU na Mesma Máquina

**Problema**: Quer rodar 2 instâncias do OpenMU

**Solução**: Alterar TODAS as portas de uma instância

```yaml
# docker-compose.override.yml para segunda instância
services:
  nginx-80:
    container_name: nginx-80-openmu2
    ports:
      - "8080:80"
  
  openmu-startup:
    container_name: openmu-startup-2
    ports:
      - "56001:55901"
      - "56002:55902"
      - "56003:55903"
      - "56004:55904"
      - "56005:55905"
      - "56006:55906"
      - "44505:44405"
      - "44506:44406"
      - "56080:55980"
  
  database:
    container_name: database-openmu2
    # PostgreSQL não precisa expor porta
```

---

## 🚀 Comandos Úteis

### Gerenciar Múltiplos Projetos

```bash
# Iniciar projeto específico
cd projeto1 && docker compose up -d
cd projeto2 && docker compose up -d

# Parar projeto específico
cd projeto1 && docker compose down

# Ver logs de todos os containers
docker compose logs -f

# Ver apenas containers de um projeto
cd projeto1 && docker compose ps
```

### Verificar Conflitos

```bash
# Ver todos os containers rodando
docker ps -a

# Ver portas mapeadas
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Verificar se porta está em uso
lsof -i :PORTA
```

---

## ⚠️ Problemas Comuns

### Erro: "port is already allocated"

**Causa**: Outro container já está usando a porta

**Solução**:
1. Identificar qual container está usando: `docker ps`
2. Parar o container conflitante ou alterar a porta

### Erro: "container name already exists"

**Causa**: Container com mesmo nome já existe

**Solução**:
1. Remover container antigo: `docker rm nome-container`
2. Ou alterar nome no `docker-compose.yml`:
```yaml
services:
  openmu-startup:
    container_name: openmu-startup-unico
```

### Performance Lenta

**Causa**: Múltiplos projetos consumindo muitos recursos

**Solução**:
1. Limitar recursos por container:
```yaml
services:
  openmu-startup:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```
2. Ou parar projetos não essenciais

---

## 📝 Checklist para Rodar Múltiplos Projetos

- [ ] Verificar portas em uso: `lsof -i -P -n | grep LISTEN`
- [ ] Alterar portas conflitantes no `docker-compose.yml`
- [ ] Verificar recursos disponíveis: `docker stats`
- [ ] Usar nomes únicos de containers
- [ ] Testar cada projeto individualmente primeiro
- [ ] Monitorar logs: `docker compose logs -f`

---

## 🎯 Resumo

✅ **Sim, pode rodar múltiplos projetos Docker simultaneamente**

⚠️ **Atenção a**:
- Conflitos de portas (especialmente 80, 443, 5432)
- Recursos do sistema (CPU, RAM, disco)
- Nomes únicos de containers

💡 **Dica**: Use `docker-compose.override.yml` para personalizar portas sem modificar arquivos originais.

---

**Precisa de ajuda com algum conflito específico?** Me diga quais projetos você quer rodar juntos e eu ajudo a configurar! 🚀
