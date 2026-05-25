---
name: frontend-testing-validation
description: Especialista em automação de testes e validação visual de aplicações front-end. Utiliza as ferramentas Playwright e Chrome DevTools MCP para interagir com a aplicação local em tempo real, auditando erros de console, responsividade e integridade dos fluxos.
---

# Frontend Testing & Validation Skill

Esta skill orienta o agente a realizar uma validação operacional rigorosa (Runtime Validation) de qualquer componente, tela ou fluxo desenvolvido, garantindo que o código entregue esteja 100% livre de bugs e apresente visual impecável em todos os dispositivos.

---

## 🛠️ Ferramentas MCP Utilizadas

Para realizar a auditoria da aplicação em execução, você usará os servidores MCP integrados:
* **`playwright`** / **`chrome-devtools-mcp`**: Permitem navegar, clicar, preencher formulários, tirar prints e capturar mensagens de console.
* **Logs do Console:** Utilização ativa de `browser_console_messages` ou `get_console_message` para monitorar a integridade da aplicação.

---

## 🔄 Protocolo de Testes Operacionais (Passo a Passo)

Ao finalizar o desenvolvimento ou refatoração de um componente ou funcionalidade, execute rigorosamente este protocolo de validação:

### Passo 1: Inicialização Local
Certifique-se de que a aplicação está executando localmente (normalmente via `npm run dev` ou `npm start`). 

### Passo 2: Abertura do Navegador e Ingestão
Abra uma nova aba e navegue programaticamente para a URL de desenvolvimento local da aplicação (geralmente `http://localhost:4200` para projetos Angular).
* Ferramenta recomendada: `browser_navigate` ou `navigate_page`.

### Passo 3: Inspeção do Console de Inicialização
Inspecione os logs de console imediatamente após o carregamento inicial da página.
* **Critério de Validação:** **Qualquer erro (`Error`, `Exception`, `Failed to load resource`) ou warning significativo (`Deprecation`, `Performance Warning`) deve ser resolvido imediatamente.**
* Ferramenta recomendada: `browser_console_messages` ou `list_console_messages`.

### Passo 4: Teste de Fluxo de Usuário (E2E Simulado)
Simule as interações reais do usuário para verificar o comportamento dinâmico e o gerenciamento de estado:
1. **Preenchimento e Validação:** Insira dados válidos e inválidos em formulários para testar as validações reativas.
   * Ferramentas recomendadas: `browser_fill_form`, `type_text`.
2. **Envio e Feedback:** Clique nos botões de submissão e confirme se os loading states, modais (`p-dialog`) ou alertas visuais (`p-toast`) são disparados com sucesso.
   * Ferramentas recomendadas: `browser_click`, `click`.
3. **Casos de Exceção:** Tente submeter dados incorretos e valide se o estado da UI permanece consistente e se as mensagens de erro de acessibilidade (a11y) são legíveis.

### Passo 5: Auditoria de Responsividade e Layout Visual
Valide a integridade estética do componente em diferentes formatos de tela utilizando o redimensionamento do navegador:
1. **Visualização Desktop (Resolução Padrão: 1280x800):**
   * Garanta que layouts com Sidebar, Grids complexos e painéis de dados se comportem com boa leitura e espaçamento.
2. **Visualização Mobile (Resolução Padrão: 375x812):**
   * Redimensione a tela (usando `browser_resize` ou `resize_page`).
   * **Critério de Validação:** Verifique a quebra automática de textos, empilhamento dinâmico de cards, substituição do menu lateral pelo menu Hamburger e a **ausência absoluta de scrollbars horizontais indesejadas**.
3. **Evidência Visual:** Tire capturas de tela (`browser_take_screenshot` ou `take_screenshot`) das visualizações desktop e mobile para inspecionar possíveis desalinhamentos geométricos.

---

## 📝 Critérios de Aceitação (Definition of Done - DoD)

Um componente ou tela só é considerado concluído para entrega quando satisfizer os quatro critérios abaixo:

1. **Zero Bugs no Console:** Console do navegador totalmente limpo de erros e logs de depuração esquecidos.
2. **Responsividade Fluida:** Layout mobile limpo, adaptável e sem rolagem horizontal no container principal.
3. **Feedback Visual Consistente:** Loading states visíveis para qualquer chamada assíncrona lenta e alertas reativos (sucesso/erro) após ações importantes.
4. **Navegação Acessível por Teclado:** Suporte à navegação usando `Tab` e acionamento por `Enter`/`Space` em botões e inputs customizados.
