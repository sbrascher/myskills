---
name: narracao-legenda
description: Especialista em converter manuscritos de vídeo em legendas formatadas no padrão SRT (.srt). Ignora o título principal do texto e aplica o algoritmo de timestamps automatizados baseado no comprimento dos blocos de caracteres.
---

# Especialista em Geração de Legendas (LegendaService)

Esta skill permite ao agente converter um manuscrito narrativo corrido em um arquivo de legenda estruturado no formato padrão SubRip (`.srt`), ideal para sincronização em vídeos do YouTube ou softwares de edição.

---

## ⚙️ Parâmetros do Algoritmo

O processo de legenda segue exatamente as regras lógicas e de expressões regulares implementadas no port de Python do `LegendaService`:

1. **Ignorar Título:** A primeira linha não vazia do arquivo de entrada é identificada como o título e descartada automaticamente do processamento da legenda.
2. **Normalização de Texto:**
   - Aspas e aspas angulares (`"`, `«`, `»`) são convertidas para aspas simples (`'`).
   - Espaçamento padrão é inserido antes e depois de pontuações (`.`, `,`, `!`, `?`, `;`, `:`).
   - Reticências (`. . .`) são normalizadas para `...`.
   - Espaços múltiplos são reduzidos a um único espaço.
3. **Divisão de Blocos:**
   - O texto é segmentado com base em pontuações de fim de frase (`.`, `?`, `!`).
   - As sentenças são unidas em blocos de até **100 caracteres** (`max_caracteres_por_bloco`).
4. **Cálculo de Tempo (Timestamps):**
   - **Velocidade de Leitura:** O cálculo assume uma taxa padrão de **14 caracteres por segundo (CPS)** para definir a duração de exibição de cada bloco.
   - **Pausa de Transição:** É inserida uma pausa de **0.9 segundos** entre a exibição de blocos consecutivos.
   - **Ajuste de Velocidade:** O multiplicador de velocidade padrão é de `1.0`.

---

## 🛠️ Script Utilitário Exclusivo

Esta skill possui um script auxiliar em Python localizado em [gerar_legenda.py](file:///D:/Projetos/IA/youtube/.agents/skills/legenda/scripts/gerar_legenda.py) que executa todo o processamento com precisão matemática.

### Comandos de Execução

Para gerar a legenda de um manuscrito, execute o seguinte comando no terminal do projeto:

```bash
python .agents/skills/legenda/scripts/gerar_legenda.py --input D:/Projetos/IA/youtube/manuscrito.txt --output D:/Projetos/IA/youtube/manuscrito.srt
```

### Parâmetros Opcionais Suportados
Você pode customizar o comportamento passando flags adicionais para o script:
- `--max-chars <int>`: Modifica o tamanho máximo do bloco (Padrão: `100`).
- `--cps <float>`: Altera os caracteres por segundo (Padrão: `14.0`).
- `--pausa <float>`: Define a pausa de silêncio entre blocos em segundos (Padrão: `0.9`).
- `--velocidade <float>`: Multiplicador final da velocidade dos tempos (Padrão: `1.0`).
