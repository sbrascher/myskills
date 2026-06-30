#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
LegendaService - Gerador de Legendas SRT
Traduzido do algoritmo LegendaService.cs para Python.
"""

import re
import argparse
from datetime import timedelta
from pathlib import Path

def formatar_texto(texto: str) -> str:
    """
    Formata e limpa o texto aplicando regras de regex idênticas ao C#.
    """
    # Substituições básicas
    texto = texto.replace('"', "'").replace('«', "'").replace('»', "'")
    texto = texto.replace('\n', ' ').replace('\r', '')
    
    # Inserção de espaços antes e depois de pontuações
    # Equivalente a: Regex.Replace(texto, @"([a-zA-Z\p{L}])([.,!?;:])", "$1 $2")
    texto = re.sub(r'([a-zA-ZÀ-ÖØ-öø-ÿ])([.,!?;:])', r'\1 \2', texto)
    
    # Equivalente a: Regex.Replace(texto, @"([.,!?;:])([a-zA-Z\p{L}])", "$1 $2")
    texto = re.sub(r'([.,!?;:])([a-zA-ZÀ-ÖØ-öø-ÿ])', r'\1 \2', texto)
    
    # Remove espaços duplos entre pontuações sequenciais
    texto = re.sub(r'([.,!?;:])\s([.,!?;:])', r'\1\2', texto)
    
    # Padroniza reticências
    texto = texto.replace('. . .', '...')
    
    # Ajusta aspas simples adjacentes a palavras
    texto = re.sub(r"(\B')(\w)", r"\1 \2", texto)
    texto = re.sub(r"(\w)('\B)", r"\1 \2", texto)
    
    # Remove espaços múltiplos consecutivos
    texto = re.sub(r'\s+', ' ', texto)
    
    return texto.strip()

def criar_blocos_de_texto(texto: str, max_length: int) -> list:
    """
    Divide o texto em sentenças e agrupa-as em blocos respeitando o tamanho máximo.
    """
    # Divide por fronteiras de pontuação terminal seguidas por espaço
    sentencas = re.split(r'(?<=[.?!])\s+', texto)
    sentencas = [s.strip() for s in sentencas if s.strip()]
    
    if not sentencas:
        return [texto] if texto else []
        
    blocos = []
    bloco_atual = ""
    
    for sentenca in sentencas:
        if bloco_atual and len(bloco_atual) + len(sentenca) + 1 > max_length:
            blocos.append(bloco_atual.strip())
            bloco_atual = ""
        
        if bloco_atual:
            bloco_atual += " "
        bloco_atual += sentenca
        
    if bloco_atual:
        blocos.append(bloco_atual.strip())
        
    return blocos

def dividir_texto_em_blocos(texto_original: str, max_caracteres_por_bloco: int) -> list:
    """
    Lógica de divisão de texto em blocos idêntica ao C#.
    """
    if not texto_original or max_caracteres_por_bloco <= 0:
        return []
    
    texto_formatado = formatar_texto(texto_original)
    return criar_blocos_de_texto(texto_formatado, max_caracteres_por_bloco)

def formatar_timestamp_srt(td: timedelta) -> str:
    """
    Formata o timedelta no padrão SRT: HH:MM:SS,mmm
    """
    total_seconds = int(td.total_seconds())
    milliseconds = int(round((td.total_seconds() - total_seconds) * 1000))
    
    # Ajuste fino para evitar milissegundos negativos ou maiores que 999
    if milliseconds >= 1000:
        total_seconds += milliseconds // 1000
        milliseconds = milliseconds % 1000
    elif milliseconds < 0:
        milliseconds = 0
        
    hours = total_seconds // 3600
    minutes = (total_seconds % 3600) // 60
    seconds = total_seconds % 60
    
    return f"{hours:02d}:{minutes:02d}:{seconds:02d},{milliseconds:03d}"

def gerar_blocos_com_timestamp(texto_original: str, max_caracteres_por_bloco: int, 
                               caracteres_por_segundo: float = 14.0, 
                               pausa_entre_blocos_seg: float = 0.9) -> list:
    """
    Calcula os tempos de início e fim de cada bloco baseado no número de caracteres.
    """
    blocos_de_texto = dividir_texto_em_blocos(texto_original, max_caracteres_por_bloco)
    blocos_com_timestamp = []
    tempo_atual = timedelta(0)
    sequencia = 1
    
    if caracteres_por_segundo <= 0:
        caracteres_por_segundo = 14.0
        
    for texto_do_bloco in blocos_de_texto:
        duracao_segundos = len(texto_do_bloco) / caracteres_por_segundo
        inicio = tempo_atual
        fim = inicio + timedelta(seconds=duracao_segundos)
        
        blocos_com_timestamp.append({
            'sequencia': sequencia,
            'texto': texto_do_bloco,
            'inicio': inicio,
            'fim': fim
        })
        
        sequencia += 1
        tempo_atual = fim + timedelta(seconds=pausa_entre_blocos_seg)
        
    return blocos_com_timestamp

def gerar_conteudo_srt(blocos: list, fator_velocidade: float = 1.0) -> str:
    """
    Gera a string final formatada em SRT com base nos blocos e no fator de velocidade.
    """
    linhas_srt = []
    
    for bloco in blocos:
        # Aplica o fator de velocidade nos tempos
        ticks_inicio = bloco['inicio'].total_seconds() * fator_velocidade
        ticks_fim = bloco['fim'].total_seconds() * fator_velocidade
        
        inicio_ajustado = timedelta(seconds=ticks_inicio)
        fim_ajustado = timedelta(seconds=ticks_fim)
        
        linhas_srt.append(str(bloco['sequencia']))
        linhas_srt.append(f"{formatar_timestamp_srt(inicio_ajustado)} --> {formatar_timestamp_srt(fim_ajustado)}")
        linhas_srt.append(bloco['texto'])
        linhas_srt.append("")  # Linha em branco separadora
        
    return "\n".join(linhas_srt)

def processar_manuscrito(caminho_input: str, caminho_output: str, 
                         max_caracteres: int = 100, cps: float = 14.0, 
                         pausa: float = 0.9, velocidade: float = 1.0):
    """
    Lê o manuscrito, ignora o título, gera as legendas e salva em arquivo.
    """
    conteudo = Path(caminho_input).read_text(encoding='utf-8')
    
    # Ignora o título (primeira linha não vazia do manuscrito)
    linhas = conteudo.splitlines()
    start_idx = 0
    for idx, linha in enumerate(linhas):
        if linha.strip():
            start_idx = idx + 1
            break
            
    texto_sem_titulo = "\n".join(linhas[start_idx:])
    
    # Executa a geração de blocos e timestamps
    blocos = gerar_blocos_com_timestamp(
        texto_sem_titulo, 
        max_caracteres_por_bloco=max_caracteres, 
        caracteres_por_segundo=cps, 
        pausa_entre_blocos_seg=pausa
    )
    
    # Gera a legenda SRT final
    conteudo_srt = gerar_conteudo_srt(blocos, fator_velocidade=velocidade)
    
    # Escreve o arquivo final de saída
    Path(caminho_output).write_text(conteudo_srt, encoding='utf-8')
    print(f"Legenda gerada com sucesso em: {caminho_output}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Conversor de Manuscrito para Legenda SRT")
    parser.add_argument("--input", required=True, help="Caminho do arquivo de texto do manuscrito (.txt)")
    parser.add_argument("--output", required=True, help="Caminho de saída para o arquivo SRT (.srt)")
    parser.add_argument("--max-chars", type=int, default=100, help="Máximo de caracteres por bloco de legenda (Default: 100)")
    parser.add_argument("--cps", type=float, default=14.0, help="Caracteres por segundo (Default: 14.0)")
    parser.add_argument("--pausa", type=float, default=0.9, help="Pausa entre blocos em segundos (Default: 0.9)")
    parser.add_argument("--velocidade", type=float, default=1.0, help="Fator multiplicador de velocidade (Default: 1.0)")
    
    args = parser.parse_args()
    
    processar_manuscrito(
        caminho_input=args.input,
        caminho_output=args.output,
        max_caracteres=args.max_chars,
        cps=args.cps,
        pausa=args.pausa,
        velocidade=args.velocidade
    )
