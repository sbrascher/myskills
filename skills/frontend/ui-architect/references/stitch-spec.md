# Especificação Técnica do Stitch Design MD

Este documento serve como referência para a geração de arquivos `DESIGN.md` compatíveis com o ecossistema Google Stitch.

## 1. Frontmatter (YAML)
Todo arquivo deve começar com um bloco YAML contendo:
- `id`: Identificador único (kebab-case).
- `type`: Tipo do componente ou token (ex: `component`, `theme`).
- `status`: Estado atual (`draft`, `stable`, `deprecated`).
- `tokens`: Mapeamento de tokens locais.

Exemplo:
```yaml
---
id: main-theme
type: theme
status: draft
---
```

## 2. Blocos de Design Tokens
Para definir tokens processáveis pela CLI, use blocos de código com a linguagem `design-token`.

Estrutura recomendada:
- **Global Tokens:** Cores brutas (ex: `blue-500: #3b82f6`).
- **Alias Tokens:** Semântica (ex: `primary-color: $blue-500`).
- **Component Tokens:** Uso específico (ex: `button-bg: $primary-color`).

Exemplo de bloco:
```design-token
core-color-primary: #1a73e8
core-color-secondary: #5f6368
alias-color-brand: $core-color-primary
```

## 3. Tipografia e Escalas
Use unidades consistentes. O Stitch prefere tokens que definem:
- `font-family`
- `font-size`
- `line-height`
- `letter-spacing`

## 4. Regras de Linting
- Nomes devem ser `kebab-case`.
- Referências a outros tokens usam o prefixo `$`.
- Evite referências circulares.
