import os
import requests
from bs4 import BeautifulSoup
import json
import re
import argparse

class HybridDomInspector:
    def __init__(self, target, angular_prefixes=None):
        self.target = target
        self.angular_prefixes = angular_prefixes or ["app", "lib", "ui"]
        self.headers = {
            # Simulando o Googlebot
            'User-Agent': 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
        }

    def fetch_static_html(self, url):
        try:
            response = requests.get(url, headers=self.headers, timeout=10)
            response.raise_for_status()
            return response.text
        except requests.exceptions.RequestException as e:
            return f"Erro ao acessar {url}: {e}"

    def read_local_file(self, path):
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                return f.read()
        except Exception as e:
            return f"Erro ao ler arquivo {path}: {e}"

    def analyze_live_url(self, html_content):
        soup = BeautifulSoup(html_content, 'html.parser')
        report = {
            "critical_issues": [],
            "warnings": [],
            "angular_components_found": [],
            "seo_summary": {}
        }

        # 1. Analisar Tags de SEO no HTML Cru (Server-side)
        title_tag = soup.find('title')
        if not title_tag or not title_tag.text.strip():
            report["critical_issues"].append("Tag <title> ausente ou vazia no HTML renderizado pelo .NET.")
        else:
            report["seo_summary"]["title"] = title_tag.text.strip()
        
        desc_tag = soup.find('meta', attrs={'name': 'description'})
        if not desc_tag or not desc_tag.get('content'):
            report["critical_issues"].append("Meta description ausente ou vazia no HTML estático.")
        else:
            report["seo_summary"]["description"] = desc_tag.get('content')

        # 1.1 Validar Open Graph (OG Tags)
        og_tags = ['og:title', 'og:description', 'og:image']
        for og in og_tags:
            if not soup.find('meta', attrs={'property': og}):
                report["warnings"].append(f"Tag de compartilhamento social '{og}' ausente no HTML estático.")

        # 1.2 Validar Schema.org JSON-LD
        json_ld = soup.find_all('script', type='application/ld+json')
        if not json_ld:
            report["warnings"].append("Dados estruturados (Schema.org JSON-LD) ausentes no HTML entregue pelo servidor.")

        # 1.3 Validar Hierarquia de Títulos (H1)
        h1_tags = soup.find_all('h1')
        if len(h1_tags) == 0:
            report["critical_issues"].append("Nenhuma tag <h1> encontrada na página estática.")
        elif len(h1_tags) > 1:
            report["warnings"].append(f"Múltiplas tags <h1> encontradas ({len(h1_tags)}). O ideal para SEO é ter apenas uma.")

        # 2. Identificar Componentes Angular (Prefixos Dinâmicos)
        pattern = f"^({'|'.join(self.angular_prefixes)})-"
        angular_tags = soup.find_all(re.compile(pattern))
        
        for tag in angular_tags:
            tag_name = tag.name
            report["angular_components_found"].append(tag_name)
            
            # Verifica conteúdo de fallback
            if not tag.text.strip() and not tag.find_all():
                report["warnings"].append(
                    f"Componente Angular <{tag_name}> está totalmente vazio na resposta do servidor. "
                    "Risco de causar Layout Shift (CLS) e atraso na renderização de conteúdo indexável (LCP)."
                )
                
                # Alerta sobre a falta de estilos/classes CSS de reserva de tamanho
                if not tag.get('class') and not tag.get('style'):
                    report["warnings"].append(
                        f"Componente vazio <{tag_name}> não possui classes ou estilos de reserva de altura/largura. "
                        "Altamente provável de causar instabilidade visual (Layout Shift) durante a hidratação."
                    )

        # 3. Verificar Injeção de Estado Inicial (Hydration Payload)
        state_scripts = soup.find_all('script', type='application/json')
        if not state_scripts and angular_tags:
            report["critical_issues"].append(
                "Componentes Angular detectados, mas nenhum payload JSON de estado inicial (`<script type=\"application/json\">`) encontrado. "
                "Isso forçará um 'Double Fetch' no cliente para carregar dados que o servidor já deveria ter injetado."
            )

        # 4. Verificar Imagens
        images = soup.find_all('img')
        for img in images:
            src = img.get('src', '')
            if not img.get('alt'):
                report["warnings"].append(f"Imagem sem tag 'alt' detectada no servidor: {src}")
            if src and not any(src.lower().endswith(ext) for ext in ['.webp', '.avif', '.svg']):
                report["warnings"].append(f"Imagem não está em formato Next-Gen (WebP/AVIF/SVG): {src}")

        return report

    def analyze_source_file(self, file_path, file_content):
        report = {
            "file": file_path,
            "critical_issues": [],
            "warnings": [],
            "angular_components_found": [],
            "checks": {
                "has_razor_seo": False,
                "has_fallback_content": False,
                "has_hydration_state": False
            }
        }

        # 1. Verificar configuração de SEO via Razor no arquivo
        razor_seo_patterns = [
            r'ViewData\["Title"\]', 
            r'ViewBag\.Title',
            r'ViewData\["Description"\]',
            r'ViewBag\.Description',
            r'<title>',
            r'<meta name="description"'
        ]
        
        for pattern in razor_seo_patterns:
            if re.search(pattern, file_content, re.IGNORECASE):
                report["checks"]["has_razor_seo"] = True
                break
        
        if not report["checks"]["has_razor_seo"] and file_path.endswith('.cshtml') and not os.path.basename(file_path).startswith('_'):
            report["warnings"].append(
                f"Nenhuma definição explícita de título ou descrição do Razor (ViewData/ViewBag) encontrada nesta view. "
                "Certifique-se de que o SEO está sendo definido estaticamente pelo MVC antes do envio."
            )

        # 2. Identificar tags Angular no código fonte
        pattern = f"<({'|'.join(self.angular_prefixes)})-[a-zA-Z0-9-]+"
        angular_tags = re.findall(pattern, file_content)
        
        for tag in set(angular_tags):
            tag_name = tag.replace('<', '')
            report["angular_components_found"].append(tag_name)
            
            # Buscar a tag inteira para analisar atributos
            # Regex simples para capturar até o fechamento da tag de abertura
            tag_pattern = r'<' + tag_name + r'[^>]*>'
            tag_matches = re.findall(tag_pattern, file_content)
            
            # Buscar o fechamento da tag para ver se há conteúdo interno
            full_tag_pattern = r'<' + tag_name + r'[^>]*>([\s\S]*?)</' + tag_name + r'>'
            full_tag_matches = re.findall(full_tag_pattern, file_content)

            for tag_opening in tag_matches:
                # Verifica se passa dados de estado/inicialização
                has_state = any(attr in tag_opening for attr in [
                    'state', 'data', 'model', 'json', '@Json', '@Html', '[state]', '[data]'
                ])
                if has_state:
                    report["checks"]["has_hydration_state"] = True
                
                # Verifica se há classes/estilos para CLS
                has_dimensions = 'class=' in tag_opening or 'style=' in tag_opening
                if not has_dimensions:
                    report["warnings"].append(
                        f"Componente <{tag_name}> declarado sem classe/estilo CSS na view Razor. "
                        "Pode causar Layout Shift (CLS) se não houver um container estilizado no CSS crítico."
                    )

            for inner_content in full_tag_matches:
                if inner_content.strip():
                    report["checks"]["has_fallback_content"] = True

            if not report["checks"]["has_hydration_state"]:
                report["critical_issues"].append(
                    f"Componente <{tag_name}> não parece receber dados iniciais do Razor. "
                    "Risco alto de 'Double Fetch' no cliente para carregar dados que o backend já possui."
                )
                
            if not report["checks"]["has_fallback_content"]:
                report["warnings"].append(
                    f"Componente <{tag_name}> está vazio no arquivo fonte (sem conteúdo de fallback). "
                    "Recomendado adicionar um esqueleto HTML ou conteúdo estático inicial para melhorar o LCP e SEO."
                )

        return report

    def run(self):
        # Se for uma URL
        if self.target.startswith("http://") or self.target.startswith("https://"):
            html = self.fetch_static_html(self.target)
            if html.startswith("Erro"):
                return {"error": html}
            return self.analyze_live_url(html)
        
        # Se for um arquivo local
        elif os.path.isfile(self.target):
            content = self.read_local_file(self.target)
            if content.startswith("Erro"):
                return {"error": content}
            return self.analyze_source_file(self.target, content)
            
        # Se for um diretório
        elif os.path.isdir(self.target):
            results = []
            for root, _, files in os.walk(self.target):
                for file in files:
                    if file.endswith(('.cshtml', '.html')):
                        file_path = os.path.join(root, file)
                        content = self.read_local_file(file_path)
                        if not content.startswith("Erro"):
                            analysis = self.analyze_source_file(file_path, content)
                            if analysis["angular_components_found"] or analysis["critical_issues"] or analysis["warnings"]:
                                results.append(analysis)
            return {"directory": self.target, "files_analyzed": results}
            
        else:
            return {"error": f"Alvo inválido: '{self.target}' não é uma URL válida ou um arquivo/diretório existente."}

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Analisa HTML estático ou arquivos Razor (.cshtml) para SEO em arquiteturas híbridas com Angular.')
    parser.add_argument('target', type=str, help='URL, caminho do arquivo .cshtml ou diretório do projeto')
    parser.add_argument('--prefixes', type=str, help='Lista de prefixos Angular separados por vírgula (ex: app,lib,ui)')
    args = parser.parse_args()

    angular_prefixes = args.prefixes.split(',') if args.prefixes else None
    
    inspector = HybridDomInspector(args.target, angular_prefixes)
    resultado = inspector.run()
    
    print(json.dumps(resultado, indent=2, ensure_ascii=False))
