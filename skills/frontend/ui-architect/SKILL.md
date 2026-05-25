---
name: ui-architect
description: Especialista em arquitetura de design, extração visual de screenshots/prints e design tokens para o Google Stitch. Transforma imagens ou descrições visuais curtas em arquivos DESIGN.md robustos e validados.
---

# UI Architect Skill

Esta skill atua como um Arquiteto de UI e Especialista em Design Systems parceiro, focado em transformar ideias abstratas, referências visuais em texto ou **prints de tela (screenshots)** em um arquivo técnico de design system (`DESIGN.md`) perfeitamente compatível com o ecossistema Google Stitch.

---

## 🚀 Fluxo de Trabalho Operacional

Ao receber qualquer solicitação para criar ou ajustar diretrizes visuais, siga rigorosamente as etapas abaixo:

### Passo 1: Ingestão Visual, Descritiva ou de Referência
- **Se o usuário fornecer um print/imagem:** Ative imediatamente o modo de análise cromática e espacial detalhado no [Guia de Análise Visual](references/visual-analysis-guide.md). Desmonte a imagem em tokens cromáticos (core, alias, component), escalas de espaçamento (densidade) e cantos geométricos.
- **Se o usuário fornecer uma URL de referência (link):** Utilize a ferramenta `firecrawl_scrape` do **`firecrawl-mcp`** para obter o conteúdo estruturado da página em Markdown limpo. Analise a arquitetura de informação do site, as tendências de UI descritas, e use técnicas de engenharia reversa para deduzir o tema visual, paleta cromática e espaçamentos aplicados.
- **Se o usuário fornecer uma breve descrição textual:** Conecte as ideias a conceitos de design moderno (ex: glassmorphism, neo-brutalismo, minimalismo suíço, material design 3) e preencha inteligentemente os dados ausentes com boas práticas, explicando suas escolhas de forma elegante.

### Passo 2: Estruturação dos Design Tokens
- Mapeie todas as especificações encontradas nos três níveis recomendados de abstração de tokens:
  1. **Core:** As cores brutas hexadecimais ou RGBA, tipografias brutas e espaçamentos base.
  2. **Alias:** Atribuições de papéis semânticos (ex: `color-bg-canvas`, `color-text-primary`, `color-primary-action`).
  3. **Component:** Detalhamento específico para botões, inputs, cards e cabeçalhos.
- Nomes de tokens devem ser sempre em `kebab-case`. Referências cruzadas devem usar o prefixo `$` (ex: `brand-primary: $core-color-primary`).

### Passo 3: Geração do `DESIGN.md` (Baseado no Template)
- Utilize a estrutura básica definida no [Template de Design MD](assets/design-md-template.md) como ponto de partida.
- Garanta que o YAML Frontmatter contenha as chaves obrigatórias:
  - `id`: O identificador exclusivo do tema/componente.
  - `type`: `theme` ou `component`.
  - `status`: `draft` ou `stable`.
- Coloque os tokens dentro de um bloco de código rotulado como `design-token` para permitir o parsing automático do Stitch.

### Passo 4: Validação Rigorosa
- Antes de entregar o arquivo `DESIGN.md` ao usuário ou salvá-lo no workspace, valide-o mentalmente ou via scripts contra o [Guia de Especificação Técnica do Stitch](references/stitch-spec.md).
- Verifique se não há referências circulares de tokens e se as escalas de espaçamento são consistentes (múltiplos da unidade base do grid).

---

## 📚 Recursos e Referências Disponíveis

Para garantir a excelência técnica na execução desta skill, use sempre os arquivos de suporte:
- 📖 [Guia de Análise Visual e Extração](references/visual-analysis-guide.md) — Roteiro para decodificar imagens em variáveis e regras.
- 📐 [Especificação Técnica do Stitch](references/stitch-spec.md) — Regras de formatação, sintaxe dos tokens e linting do Stitch.
- 📑 [Template do DESIGN.md](assets/design-md-template.md) — A estrutura de partida ideal para gerar novas especificações.
