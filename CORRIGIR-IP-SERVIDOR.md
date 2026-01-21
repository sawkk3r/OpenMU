# 🔧 Como Corrigir o IP do Servidor Enviado ao Cliente

## Problema

O servidor está enviando o IP interno do Docker (`172.20.0.3`) ao cliente, que não consegue conectar porque esse IP só existe dentro da rede Docker.

## Solução: Configurar IP Resolver

### Passo 1: Acessar o Painel Administrativo

1. Abra seu navegador
2. Acesse: **http://localhost/**
3. Faça login:
   - **Usuário:** `admin`
   - **Senha:** `openmu`

### Passo 2: Configurar IP Resolver

1. No menu lateral, clique em **"Configuration"**
2. Clique em **"System"**
3. Encontre a opção **"IP Resolver Type"**
4. Selecione **"Loopback"**
   - Isso força o IP `127.127.127.127` para conexão local
5. Clique em **"Save"** ou **"Salvar"**

### Passo 3: Reiniciar o Connect Server

1. Volte para a página principal (menu **"Servers"**)
2. Encontre o **Connect Server** na lista
3. Clique no botão **"Restart"** (ou pare e inicie novamente)
4. Aguarde alguns segundos para o servidor reiniciar

### Passo 4: Testar Conexão

1. Tente conectar novamente com o cliente
2. Verifique nos logs se o IP agora está como `127.127.127.127`

## Verificar se Funcionou

Execute para ver os logs:

```powershell
docker compose -f deploy/all-in-one/docker-compose.yml logs -f openmu-startup | Select-String -Pattern "endpoint\|172.20\|127.127"
```

Se configurado corretamente, você verá `127.127.127.127` ao invés de `172.20.0.3`.

## Outras Opções de IP Resolver

- **Loopback:** `127.127.127.127` - Para conexão local (mesma máquina)
- **Local:** IP local da máquina - Para rede local (LAN)
- **Public:** IP público - Para conexão via internet
- **Custom:** IP personalizado - Para configuração manual

## Compatibilidade do Cliente

O cliente versão **1.3.34.0** pode não ser totalmente compatível com OpenMU.

O OpenMU foi projetado principalmente para:
- **Season 6 Episode 3**
- Protocolo **ENG (English)**

Se continuar com problemas após corrigir o IP, pode ser necessário usar um cliente compatível.
