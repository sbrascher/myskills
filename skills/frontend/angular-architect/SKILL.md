---
name: angular-architect
description: Especialista em arquitetar aplicações front-end modernas em Angular 19+, PrimeNG 21+ e Tailwind CSS v4. Guia o desenvolvimento de componentes standalone reativos (Signals), serviços, gerenciamento de estado e integrações semânticas.
---

# Angular Architect

Esta skill atua como um Arquiteto Front-end especialista, guiando a criação de novas features, refatoração de código, geração de componentes ricos e organização de estado utilizando Angular 19+ reativo, PrimeNG 21+ e Tailwind CSS v4.

## Princípios Arquiteturais e de Design

Siga rigorosamente estas regras em todos os desenvolvimentos:

### 1. Reatividade com Signals (Sem RxJS no Front)
- **Signals por Padrão:** Declare todos os estados de componentes e serviços usando a API de Signals do Angular (`signal`, `computed`).
- **Comunicação Moderna:**
  - Use `input()` para dados recebidos do componente pai (Signal Inputs).
  - Use `model()` para propriedades com Two-Way Binding (Signal Models).
  - Use `output()` para emissão de eventos (Signal Outputs).
- **Sem RxJS desnecessário:** Evite `BehaviorSubject` ou `Observable` em novos componentes. Use-os apenas em Services de infraestrutura/HTTP quando o Angular CLI ou bibliotecas externas exigirem, convertendo imediatamente para Signals com `toSignal()`.

### 2. Estilização CSS-First com Tailwind v4
- **Extensões de Design:** Toda customização visual deve ser registrada no bloco `@theme` dentro do arquivo CSS principal (ex: `src/styles.css` ou `src/styles.scss`).
- **Mapeamento de Cores:** Utilize variáveis nativas do PrimeNG Aura (`var(--p-primary-500)`, etc) para estender as classes utilitárias do Tailwind v4.

### 3. Componentes PrimeNG Styled Mode
- Use a importação modular e direta dos componentes PrimeNG (ex: `import { ButtonModule } from 'primeng/button'`) nas propriedades `imports` do componente standalone.
- Mantenha os componentes em **Styled Mode** utilizando o preset `Aura` configurado no arquivo global `app.config.ts`.

---

## Fluxo de Trabalho de Desenvolvimento

Siga estas etapas para criar novos recursos ou componentes na aplicação:

### Passo 1: Integração Visual com `ui-architect` (Leitura do `DESIGN.md`)
Antes de codificar qualquer componente ou tela:
1. Verifique se o arquivo `DESIGN.md` (gerado pela skill `ui-architect`) está presente na raiz ou nas referências do projeto.
2. Analise a paleta de cores (primária, secundária, superfícies) e as diretivas de tipografia definidas nele.
3. Se necessário, ajuste as definições do bloco `@theme` no CSS global do projeto para que correspondam exatamente às cores hexadecimais ou tokens do `DESIGN.md`.

### Passo 2: Geração de Componentes de Feature
Ao criar novos componentes de negócio (páginas, formulários, tabelas complexas):
1. Use componentes 100% **Standalone** injetados via `imports`.
2. Organize-os dentro da feature correspondente em `src/app/features/<feature-name>/components/`.
3. Use a injeção reativa via função `inject()` no início da classe.
4. **Sem Placeholders:** Construa layouts ricos em detalhes e funcionais, utilizando modais (`p-dialog`), feedbacks visuais (`p-toast`), e listagens fluidas.

### Passo 3: Gerenciamento de Estado Reativo
1. Não espalhe estados complexos ou lógica de negócio pesada nos templates ou componentes visuais.
2. Crie Stores reativas baseadas em Signals dentro de `src/app/signals/` para estados compartilhados.
3. Utilize o padrão exposto em `references/code-examples.md` para criar stores de estado previsíveis e limpas.

---

## 🎨 UX, Acessibilidade (a11y) e Loading States (Zero Firulas)

Sempre aplique estas três diretrizes cruciais para atingir excelência visual e usabilidade de nível enterprise:

1. **Micro-animações Fluidas:**
   - Adicione transições nativas do Tailwind CSS v4 para respostas imediatas ao usuário (ex: classe `transition-all duration-200 ease-in-out` no hover de botões, cards ou links).
   - Melhore a interatividade com pequenas alterações de escala (`hover:scale-[1.01]`), elevações (`hover:shadow-md`) e anéis de foco bem definidos (`focus-visible:ring-2 focus-visible:ring-primary-500 outline-none`).

2. **Loading States Predictivos (Sem Saltos Visuais):**
   - Para carregamento de dados em massa (listagens, tabelas e cards), use componentes de esqueleto (`p-skeleton` do PrimeNG) em vez de spinners genéricos de tela cheia. Isso mantém a estrutura visual estável.
   - Para botões de envio em formulários, adicione um ícone de carregamento dinâmico (`[icon]="loading() ? 'pi pi-spin pi-spinner' : 'pi pi-check'"`) e desabilite o botão enquanto o Signal de loading estiver ativo.

3. **Acessibilidade Semântica (a11y):**
   - **Formulários:** Cada campo de entrada (`input`, `select`) DEVE ter um elemento `<label>` correspondente apontando para o seu `id` (ex: `for="campo-nome"`).
   - **Controles de Ação:** Botões que contêm apenas ícones devem obrigatoriamente possuir um atributo `aria-label` descritivo (ex: `<button pButton icon="pi pi-trash" aria-label="Excluir Registro"></button>`).
   - **Teclado:** Certifique-se de que todos os elementos interativos sejam navegáveis utilizando `Tab` e ativados via `Enter` ou `Space`.

---

## Comandos Recomendados

Ao guiar o desenvolvedor ou executar comandos locais, utilize os padrões mais modernos do Angular CLI:

- **Geração de Componente Standalone (limpo):**
  ```bash
  ng generate component features/<feature-name>/components/<component-name> --standalone --inline-style=false
  ```
- **Geração de Serviço de Feature:**
  ```bash
  ng generate service features/<feature-name>/services/<service-name>
  ```
