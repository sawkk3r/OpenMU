# 🔧 Solução: Access Violation (0xc0000005) no Select Server

Este erro ocorre quando o cliente MU Online trava ao tentar selecionar um servidor da lista. Aqui estão as soluções mais comuns:

## 🔍 Principais Causas

1. **IP incorreto sendo enviado pelo servidor**
2. **Incompatibilidade de versão do cliente**
3. **Falta de dependências (Visual C++ Redistributable)**
4. **Problemas com DEP (Data Execution Prevention)**
5. **Antivírus interferindo**

## ✅ Soluções (Teste uma por vez)

### Solução 1: Verificar e Ajustar o IP Resolver no Painel Admin

O problema mais comum é o servidor enviando um IP incorreto ao cliente.

1. **Acesse o Painel Administrativo:**
   - URL: http://localhost/
   - Login: `admin` / Senha: `openmu`

2. **Vá em Configuration → System**

3. **Configure o IP Resolver Type:**
   - Para conexão **LOCAL** (mesma máquina):
     - Selecione: **"Loopback"**
     - Isso força o IP `127.127.127.127`
   
   - Para conexão em **REDE LOCAL**:
     - Selecione: **"Local"**
     - Isso usa o IP local da máquina servidor
   
   - Para conexão via **INTERNET**:
     - Selecione: **"Public"**
     - Isso detecta o IP público automaticamente

4. **Salve as alterações**

5. **Reinicie o Connect Server** (pelo painel admin)

### Solução 2: Instalar Visual C++ Redistributable

O cliente MU Online precisa das bibliotecas C++ para funcionar corretamente.

**Baixe e instale:**
- [Visual C++ Redistributable 2010 x86](https://www.microsoft.com/pt-br/download/details.aspx?id=5555)
- [Visual C++ Redistributable 2015-2022 x86](https://aka.ms/vs/17/release/vc_redist.x86.exe)
- [Visual C++ Redistributable 2015-2022 x64](https://aka.ms/vs/17/release/vc_redist.x64.exe)

**Instale todas as versões**, especialmente as x86.

### Solução 3: Configurar DEP (Data Execution Prevention)

1. Abra o **Painel de Controle**
2. Vá em **Sistema → Configurações Avançadas do Sistema**
3. Em **Desempenho**, clique em **Configurações**
4. Vá na aba **Prevenção de Execução de Dados**
5. Selecione: **"Ativar DEP para todos os programas e serviços, exceto os que eu selecionar"**
6. Clique em **Adicionar**
7. Selecione o `main.exe` do seu cliente MU
8. Clique em **OK** e reinicie o computador

### Solução 4: Executar como Administrador

1. Clique com botão direito no `main.exe`
2. Selecione **"Executar como administrador"**
3. Ou configure para sempre executar como admin:
   - Propriedades → Compatibilidade → Marque "Executar este programa como administrador"

### Solução 5: Verificar Compatibilidade do Cliente

Certifique-se de que está usando:
- **Cliente compatível:** Season 6 Episode 3
- **Protocolo:** ENG (English)
- **Versão:** Compatível com OpenMU

**Clientes recomendados:**
- Cliente oficial Season 6
- [MuMain (Cliente Open Source)](https://github.com/sven-n/MuMain)

### Solução 6: Desabilitar Antivírus Temporariamente

1. Desative o antivírus temporariamente
2. Tente conectar novamente
3. Se funcionar, adicione exceções para:
   - Pasta do cliente MU
   - `main.exe`

### Solução 7: Verificar Logs do Servidor

Verifique se o servidor está recebendo a conexão corretamente:

```powershell
cd deploy\all-in-one
docker compose logs openmu-startup | Select-String -Pattern "Server List\|Connection Info\|Select"
```

Procure por erros ou mensagens relacionadas ao IP.

### Solução 8: Usar IP Manualmente Configurado

Se nada funcionar, tente configurar um IP específico:

1. No painel admin, vá em **Configuration → System**
2. Selecione **IP Resolver Type: "Custom"**
3. Configure o **IP Parameter**:
   - Para local: `127.127.127.127`
   - Para rede: `192.168.x.x` (IP do servidor na rede)
4. Salve e reinicie o Connect Server

### Solução 9: Verificar Configuração do Cliente

Se estiver usando o launcher:

1. Verifique se o IP está correto no launcher
2. Para local: Use `127.127.127.127` (não `127.0.0.1`)
3. Verifique se a porta está correta: `44405` ou `44406`

## 🧪 Ordem Recomendada de Teste

Teste nesta ordem:

1. ✅ **Primeiro:** Ajuste o IP Resolver no painel admin (Solução 1)
2. ✅ **Segundo:** Instale Visual C++ Redistributable (Solução 2)
3. ✅ **Terceiro:** Execute como Administrador (Solução 4)
4. ✅ **Quarto:** Configure DEP (Solução 3)
5. ✅ **Quinto:** Verifique logs e IP manual (Soluções 7 e 8)

## 📝 Checklist Rápido

- [ ] IP Resolver configurado corretamente no painel admin
- [ ] Visual C++ Redistributable instalado
- [ ] Cliente executando como Administrador
- [ ] DEP configurado para permitir o main.exe
- [ ] Cliente é compatível (Season 6 Episode 3)
- [ ] IP correto configurado (127.127.127.127 para local)
- [ ] Antivírus não está bloqueando
- [ ] Servidor está rodando e acessível

## 🔍 Verificar se Está Funcionando

Após aplicar as soluções:

1. **Verifique os logs do servidor:**
   ```powershell
   docker compose logs -f openmu-startup
   ```

2. **Procure por estas mensagens:**
   - "Client requested Server List"
   - "Connection Info sent"
   - Sem erros relacionados a IP

3. **Tente conectar novamente**

## 📞 Se Nada Funcionar

Se após testar todas as soluções o erro persistir:

1. Verifique se está usando a porta correta (`44405` ou `44406`)
2. Tente com outro cliente MU
3. Verifique se o servidor está completamente inicializado (aguarde 1-2 minutos após iniciar)
4. Consulte o [Discord do OpenMU](https://discord.gg/2u5Agkd) para suporte da comunidade

---

**Última atualização:** Baseado em problemas comuns com Access Violation no OpenMU
