# Guia de Análise Visual e Extração de Design Tokens

Este documento é a referência operacional da IA para converter imagens (prints, screenshots, protótipos) ou descrições visuais textuais em especificações estruturadas no arquivo `DESIGN.md` sob o padrão Google Stitch.

---

## 1. Passo a Passo da Extração Visual (Prints)

Quando o usuário fornecer uma imagem de tela, execute a análise seguindo estas 4 camadas de design:

### Camada A: Paleta Cromática e Atmosfera (Cores)
*   **Identifique a Cor Predominante de Fundo (Canvas):** É um Dark Mode profundo (ex: `#090D16`), um Light Mode puro (`#FFFFFF`) ou um tom de cinza suave?
*   **Identifique o Container/Surface:** Os cards e modais se destacam do fundo? Qual o nível de opacidade se for um layout com vidro (ex: `rgba(255, 255, 255, 0.05)` com `backdrop-filter: blur`)?
*   **Identifique a Cor Primária (Brand Color):** Onde estão os botões de ação principal (CTA), links destacados ou estados ativos? Extraia a cor exata em hexadecimal.
*   **Cores de Suporte (Semânticas):** Qual a cor para erros (geralmente vermelho/coral), sucesso (verde/esmeralda) e avisos (amarelo/laranja)?

### Camada B: Espaçamento e Densidade (Layout)
*   **Determine a Unidade Base:** O layout se alinha a um grid de `8px` (padrão desktop/mobile profissional) ou `4px` (alta densidade)?
*   **Escala de Espaçamento:** Mapeie os paddings internos de cards comuns e margens entre seções para deduzir a escala (ex: `spacing-xs: 8px`, `spacing-sm: 16px`, `spacing-md: 24px`, `spacing-lg: 32px`).

### Camada C: Geometria e Profundidade (Shapes & Elevation)
*   **Arredondamento de Cantos (Border Radius):** Os elementos são totalmente quadrados (`0px`), suavemente arredondados (`8px` a `12px`) ou extremamente circulares (`24px`+)?
*   **Profundidade Visual (Shadows/Elevation):** Existem sombras suaves projetadas sob os cards? Elas são difusas (layouts elegantes) ou nítidas e com borda dura (Neo-brutalismo)?

### Camada D: Tipografia (Texto)
*   **Família Tipográfica:** É uma fonte sem serifa geométrica (tipo *Inter*, *Outfit*, *Roboto*), uma fonte moderna de tecnologia (tipo *JetBrains Mono*) ou uma fonte elegante com serifa?
*   **Escala de Tamanho:** Deduzir o tamanho relativo do cabeçalho principal, subtítulo e texto do corpo.

---

## 2. Tradução para Design Tokens do Stitch

Cada elemento visual observado deve ser traduzido em tokens organizados em três níveis lógicos de abstração no bloco `design-token`:

1.  **Core (Global Tokens):** Valores brutos e paletas literais.
    *   *Sintaxe:* `core-[categoria]-[nome]: [valor]`
2.  **Alias (Tokens Semânticos):** Vinculados à intenção de uso do sistema de design.
    *   *Sintaxe:* `[categoria]-[intencao]: $[core-token-equivalente]`
3.  **Component (Tokens de Componente):** Valores específicos para elementos do PrimeNG ou HTML.
    *   *Sintaxe:* `[componente]-[propriedade]: $[alias-token-equivalente]`

---

## 3. Estudo de Caso Prático (Exemplo de Tradução)

### Input do Usuário:
> *"Crie um design para um dashboard de cripto moderno, com fundo escuro azulado quase preto, botões em neon roxo brilhante, cantos bem arredondados nos cards e efeito de vidro transparente com borda fina."*

### Análise Visual da IA:
*   **Tema:** Dark Mode Glassmorphism.
*   **Fundo:** Dark Navy `#080B11`.
*   **Primary/CTA:** Roxo Neon `#8B5CF6` (com hover em `#A78BFA`).
*   **Superfície/Surface:** Vidro semi-transparente `rgba(15, 23, 42, 0.6)` com blur e borda de `1px` em `rgba(255, 255, 255, 0.08)`.
*   **Geometria:** Arredondamento suave de `16px` (`radius-lg`).

### Output Gerado (`DESIGN.md`):

```yaml
---
id: crypto-glass-dashboard
type: theme
status: draft
---

# Design System: Crypto Glass Dashboard

## 1. Tokens de Design

```design-token
# Cores Core (Valores Brutos)
core-color-dark-bg: #080B11
core-color-purple-neon: #8b5cf6
core-color-purple-light: #a78bfa
core-color-glass-base: rgba(15, 23, 42, 0.6)
core-color-glass-border: rgba(255, 255, 255, 0.08)
core-color-text-bright: #f8fafc
core-color-text-muted: #94a3b8

# Tokens Semânticos (Alias)
color-bg-canvas: $core-color-dark-bg
color-bg-surface: $core-color-glass-base
color-border-surface: $core-color-glass-border
color-primary-action: $core-color-purple-neon
color-primary-hover: $core-color-purple-light

# Tipografia
font-family-main: "Outfit", sans-serif
font-size-base: 16px
font-size-title: 32px

# Geometria e Grid
spacing-base-unit: 8px
radius-card: 16px
radius-button: 12px
```

## 2. Regras de Layout e Usabilidade

### Superfícies e Profundidade
- Todos os cards de métricas e gráficos devem aplicar `backdrop-filter: blur(12px)` combinado com o token `color-bg-surface`.
- A borda fina (`1px solid color-border-surface`) é obrigatória em todas as superfícies flutuantes para garantir separação visual.

### Botões e Interatividade
- Botões primários usam o fundo `color-primary-action` com cantos de `radius-button`.
- Adicione uma transição suave de 200ms para o estado hover (`color-primary-hover`) com um brilho sutil de box-shadow em roxo neon.
