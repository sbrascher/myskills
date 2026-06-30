---
name: narracao-diretor
description: Orquestrador e Diretor Geral de Produção Autônomo. Gerencia, executa e valida as etapas de escrita (narracao-texto), legendagem (narracao-legenda) e planejamento de imagens (narracao-imagem-prompts), preparando os assets para a geração manual das imagens.
---

# Diretor Geral de Produção Autônomo (narracao-diretor)

Esta skill atua como um **Orquestrador Central Autônomo** para a criação de vídeos do YouTube. O agente assume o papel de Diretor e tem **plena autonomia** para conduzir a produção, avaliando e aprovando o material gerado de forma independente (sem interromper o fluxo para pedir aprovação humana a cada capítulo), parando a produção após o planejamento das imagens.

---

## 🎬 Ciclo de Vida da Produção Autônoma

O Diretor deve auto-avaliar a qualidade e aprovar o progresso de cada fase antes de prosseguir.

### **Fase 0: Inicialização e Registro (videos.xlsx)**
1. Registre o vídeo executando o script de inicialização com o título do projeto:
   ```bash
   python .agents/skills/narracao-diretor/scripts/registrar_video.py "Título do Vídeo"
   ```
2. Salve o nome da pasta gerada (`RESULT_SLUG`).

---

### **Fase 1: Roteiro Autônomo (Orquestrando a skill `narracao-texto`)**
O Diretor conduz a escrita do manuscrito avaliando os critérios de qualidade de forma autônoma:
1. **Conceito (Etapa 1):** Gera o título e a sinopse. Auto-avalia a coerência temática e declara **"Aprovado"** internamente, prosseguindo ao esboço.
2. **Esboço (Etapa 2):** Gera a estrutura de 6 capítulos. Valida se a curva dramática está crescente e declara **"Aprovado"** internamente.
3. **Escrita dos Capítulos (Etapa 3):** Escreve cada capítulo individualmente. O Diretor auto-aprova cada capítulo declarando **"Aprovado"** se satisfizer os critérios:
   - Extensão entre **800 e 1.000 palavras**.
   - Rica imersão sensorial (*Show, Don't Tell*).
   - Ausência completa de colchetes ou marcas técnicas.
4. **Compilação final:** Grava o manuscrito unificado com a Chamada para Ação (CTA) e sem títulos de capítulos em `D:/Projetos/IA/youtube/<RESULT_SLUG>/manuscrito.txt`.

---

### **Fase 2: Legendas SRT (Orquestrando a skill `narracao-legenda`)**
Gera as legendas chamando o script e validando o resultado:
1. Executa o comando de legendagem:
   ```bash
   python .agents/skills/narracao-legenda/scripts/gerar_legenda.py --input "D:/Projetos/IA/youtube/<RESULT_SLUG>/manuscrito.txt" --output "D:/Projetos/IA/youtube/<RESULT_SLUG>/manuscrito.srt"
   ```
2. Abre e valida o arquivo `.srt` criado.

---

### **Fase 3: Planejamento Visual (Orquestrando a skill `narracao-imagem-prompts`)**
1. Gera os 20 prompts de imagem (10 ambientação, 10 de cenas) em inglês seguindo a fórmula de contraluz dourado.
2. Grava os prompts em `D:/Projetos/IA/youtube/<RESULT_SLUG>/imagens/prompts_gerados.txt`.

*(Nota: A geração das imagens físicas via `narracao-imagem` não é executada pelo diretor. Ela deve ser chamada manualmente pelo usuário posteriormente).*

---

## 🔍 Painel de Controle e Checklist de Sucesso

O Diretor realiza uma checagem de validação de todos os arquivos antes de apresentar a entrega final ao usuário:

- [ ] **Linha no Excel:** Registro inserido com sucesso em [videos.xlsx](file:///D:/Projetos/IA/youtube/videos.xlsx).
- [ ] **Manuscrito finalizado:** `D:/Projetos/IA/youtube/<RESULT_SLUG>/manuscrito.txt` (via `narracao-texto`).
- [ ] **Legenda SRT criada:** `D:/Projetos/IA/youtube/<RESULT_SLUG>/manuscrito.srt` (via `narracao-legenda`).
- [ ] **Lista de Prompts criada:** `D:/Projetos/IA/youtube/<RESULT_SLUG>/imagens/prompts_gerados.txt` (via `narracao-imagem-prompts`).
