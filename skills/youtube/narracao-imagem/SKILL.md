---
name: narracao-imagem
description: Especialista em geração física de imagens consistentes. Lê a lista de prompts em imagens/prompts_gerados.txt e aciona o motor de imagens em lote, utilizando uma imagem de referência de estilo.
---

# Gerador de Imagens por Lote (narracao-imagem)

Esta skill é responsável por ler os prompts planejados de um projeto e interagir com o motor de geração de imagens para produzir os assets visuais finais de forma padronizada.

---

## 🎨 Consistência de Estilo

Para manter a unidade de estilo do carrossel do vídeo:

1. **Imagem de Referência:** Sempre envie o caminho da imagem de referência de estilo no parâmetro `ImagePaths` da ferramenta `generate_image`. Por padrão, use a primeira imagem de estilo gerada para o canal (ex: `jesus_and_children.jpg` ou `Output/Whisk_4cdn2umnwugn4ajytezn0ktl1edn00syxgjytum_painted.jpeg`).
2. **Proporção:** Defina a proporção no motor como widescreen `16:9` (`AspectRatio` no JSON).

---

## 🚀 Fluxo de Trabalho (Geração Física)

1. **Leitura dos Prompts:** Leia o arquivo do projeto localizado em `D:/Projetos/IA/youtube/<RESULT_SLUG>/imagens/prompts_gerados.txt`.
2. **Execução em Lote:** Para cada um dos 20 prompts contidos no arquivo, faça a chamada correspondente da ferramenta `generate_image`.
3. **Cópia e Organização:**
   - Obtenha o arquivo gerado a partir do caminho retornado pelo motor.
   - Salve a imagem gerada no diretório final do projeto: `D:/Projetos/IA/youtube/<RESULT_SLUG>/imagens/`.
   - Renomeie as imagens sequencialmente como `carrossel_01.jpg` a `carrossel_20.jpg` para fácil encadeamento no editor de vídeo.
