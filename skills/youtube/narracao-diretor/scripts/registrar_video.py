#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Orquestrador de Projetos de Vídeo - narracao-diretor
Gera o nome da pasta (slug), cria os diretórios necessários e registra o projeto no videos.xlsx.
"""

import os
import sys
import re
import unicodedata
import openpyxl
from openpyxl import Workbook
from datetime import datetime

def slugify(value: str) -> str:
    """
    Transforma um título em um slug de diretório válido (caixa baixa, sem acentos, hifens no lugar de espaços).
    """
    # Remove acentos
    value = unicodedata.normalize('NFKD', value).encode('ascii', 'ignore').decode('ascii')
    # Remove caracteres especiais e pontuações
    value = re.sub(r'[^\w\s-]', '', value).strip().lower()
    # Substitui espaços e hifens múltiplos por um único hífen
    return re.sub(r'[-\s]+', '-', value)

def registrar_video(titulo: str):
    """
    Registra as informações do vídeo no videos.xlsx e cria a estrutura de pastas do projeto.
    """
    pasta_slug = slugify(titulo)
    caminho_excel = "D:/Projetos/IA/youtube/videos.xlsx"
    
    # 1. Criar ou carregar o arquivo Excel videos.xlsx
    if not os.path.exists(caminho_excel):
        wb = Workbook()
        ws = wb.active
        ws.title = "Projetos"
        # Escreve o cabeçalho
        ws.append(["Nome do Vídeo", "Nome da Pasta", "Data Atual"])
    else:
        wb = openpyxl.load_workbook(caminho_excel)
        ws = wb.active
        
    # Adiciona a linha correspondente ao novo projeto
    data_atual = datetime.now().strftime("%d/%m/%Y")
    ws.append([titulo, pasta_slug, data_atual])
    wb.save(caminho_excel)
    
    # 2. Criar o diretório de saída do projeto e a pasta de imagens interna
    caminho_pasta = f"D:/Projetos/IA/youtube/{pasta_slug}"
    caminho_imagens = f"{caminho_pasta}/imagens"
    
    os.makedirs(caminho_pasta, exist_ok=True)
    os.makedirs(caminho_imagens, exist_ok=True)
    
    # Output para leitura do agente
    print(f"RESULT_SLUG:{pasta_slug}")
    print(f"RESULT_PATH:{caminho_pasta}")
    print(f"RESULT_IMAGES_PATH:{caminho_imagens}")
    print(f"Status: Registro inserido em videos.xlsx e estrutura criada com sucesso.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Erro: Forneça o título do vídeo como argumento.")
        sys.exit(1)
        
    titulo_video = sys.argv[1]
    registrar_video(titulo_video)
