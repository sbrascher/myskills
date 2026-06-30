---
name: narracao-imagem-prompts
description: Especialista em analisar manuscritos e gerar 20 prompts de imagem (10 paisagens, 10 cenas) em inglês seguindo a fórmula clássica de contraluz quente e pintura a óleo, salvando-os em imagens/prompts_gerados.txt.
---

# Planejador de Prompts Visuais (narracao-imagem-prompts)

Esta skill guia o agente na análise de manuscritos textuais e no planejamento de recursos visuais consistentes, gerando a lista de 20 prompts de imagem necessária para a produção do vídeo.

---

## 🎨 Diretrizes de Estilo Consistente

Todos os prompts devem ser escritos em **inglês** e incorporar a fórmula exata do estilo visual clássico e contraluz dourada:

- **Fórmula do Prompt de Estilo:** Cada prompt de imagem gerado deve terminar obrigatoriamente com o sufixo:
  `"...Warm golden hour sunlight coming from behind (backlight/rim lighting), creating a soft glowing halo effect on their hair and contours. Classic painterly style with visible textured brushstrokes, soft edges, and rich details. Warm earthy color palette featuring browns, ochres, soft beige, and muted terracotta. 16:9 aspect ratio."`

---

## 🚀 Fluxo de Trabalho (Geração de Prompts)

1. **Análise do Roteiro:** Analise o manuscrito do projeto atual (localizado em `<RESULT_SLUG>/manuscrito.txt`).
2. **Formulação dos Prompts (20 Imagens):**
   - **10 Prompts de Paisagens/Ambientes:** Crie prompts focados na ambientação histórica da época (vias, rios, lagos, olivais, construções de pedra, vilas, desertos).
   - **10 Prompts de Cenas da História:** Crie prompts focados em momentos cruciais do enredo, personagens principais e no clímax dramático.
3. **Exportação:**
   - Adicione o sufixo de estilo a cada um dos 20 prompts.
   - Salve a lista final no arquivo de projeto: `D:/Projetos/IA/youtube/<RESULT_SLUG>/imagens/prompts_gerados.txt`.
