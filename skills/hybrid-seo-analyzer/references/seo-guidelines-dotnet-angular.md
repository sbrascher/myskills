# Manifesto de SEO Técnico para Arquiteturas Híbridas (.NET MVC + Angular)

Este documento define as diretrizes arquiteturais e operacionais obrigatórias para garantir a máxima indexabilidade, performance (Core Web Vitals) e ranqueamento em sistemas que utilizam C#/.NET MVC para renderização de servidor (SSR) e Angular Standalone Components para reatividade no cliente (CSR).

---

## 1. Estratégia de Renderização e Hidratação

O problema central de arquiteturas híbridas é a renderização em duas etapas do Googlebot e o risco do "Double Fetch". O conteúdo crítico para SEO deve estar presente na primeira leitura do servidor.

### 1.1. Injeção de Estado Inicial (Data Hydration)
* **Regra:** Componentes Angular que exibem conteúdo crítico para SEO (textos, produtos, dados estruturados) não devem fazer requisições HTTP para buscar seus dados iniciais durante o carregamento da página.
* **Implementação (.NET):** Utilize consultas otimizadas e leves (ex: via Dapper) diretamente no Controller MVC. Injete o resultado na View Razor (`.cshtml`) através de uma tag `<script type="application/json">` ou via variáveis globais seguras.
* **Implementação (Angular):** O componente Standalone deve ler este payload estático via injeção de dependência (`DOCUMENT` token) ou acessar o DOM no momento da inicialização, evitando chamadas à API no `ngOnInit` da carga inicial.

### 1.2. Progressive Enhancement e Fallbacks
* **Regra:** O seletor do componente Angular (ex: `<app-lista-tarefas>`) não deve ser um contêiner vazio na entrega do servidor.
* **Implementação:** O Razor deve gerar o HTML básico amigável (esqueleto, tabelas HTML puras ou links) dentro da tag do componente. Quando o Angular for inicializado, ele assume o controle do DOM de forma progressiva.

---

## 2. Core Web Vitals e Performance Frontend

### 2.1. Mitigação de CLS (Cumulative Layout Shift)
* **Regra:** A hidratação do Angular nunca deve causar saltos na interface ou empurrar elementos do layout renderizado pelo .NET.
* **Implementação:** Defina dimensões estritas (`min-height`, `width`) ou utilize *CSS Skeletons* injetados pelo `.cshtml` no local exato onde o componente Angular será montado.

### 2.2. Otimização de Bundles JS (LCP e INP)
* **Regra:** O framework completo não deve ser injetado globalmente se não for necessário.
* **Implementação:** Faça uso agressivo de Lazy Loading. Empacote os componentes Standalone de forma isolada e garanta que o layout principal (`_Layout.cshtml`) invoque apenas os scripts estritamente necessários para aquela rota específica.

---

## 3. SEO de Mídia e Imagens

A entrega de mídia é o maior ofensor da métrica LCP. O gerenciamento visual deve ser rigoroso.

* **Formatos Next-Gen:** Todas as imagens estáticas ou dinâmicas devem ser servidas nativamente em `WebP` ou `AVIF`. Nunca utilize JPG/PNG diretamente para o usuário final.
* **Diretiva NgOptimizedImage:** Dentro do escopo Angular, o uso da diretiva nativa `ngSrc` é obrigatório para garantir o gerenciamento automático do `srcset` e priorização de carregamento.
* **Atributo ALT:** O texto alternativo deve ser focado na semântica humana e contexto da imagem, inserindo palavras-chave naturalmente, sem praticar *keyword stuffing*.
* **Prioridade de Carregamento:**
    * *Above the fold (LCP):* `fetchpriority="high"` e `loading="eager"`.
    * *Abaixo da dobra:* `loading="lazy"`.

---

## 4. Semântica, Metadados e Arquitetura de Links

O controle das tags que ficam no `<head>` da página deve ser mantido estritamente pelo servidor (.NET), não pelo cliente (Angular).

### 4.1. Meta Tags e Tags Canônicas
* **Regra:** Cada view MVC deve ter controle absoluto sobre sua tag `<title>`, `<meta description>`, tags do Open Graph (`og:image`, `og:title`) e, principalmente, a tag `<link rel="canonical" href="..." />`.
* **Implementação:** O rastreamento de parâmetros de filtro excessivos (Faceted Navigation) deve ser contido no backend, aplicando `<meta name="robots" content="noindex, follow">` dinamicamente quando a combinação de filtros não agregar valor orgânico, preservando o *Crawl Budget*.

### 4.2. Dados Estruturados (Schema.org)
* **Regra:** Rich snippets dependem de leitura imediata.
* **Implementação:** Todo JSON-LD (como de Breadcrumbs, Artigos ou Produtos) deve ser gerado pelo backend e injetado diretamente no corpo da view Razor.

### 4.3. Linkagem Interna Otimizada
* O fluxo de PageRank exige a utilização de tags âncoras HTML `<a>` padrão com o atributo `href` real, mesmo para transições controladas pelo router do Angular. Botões com eventos de clique (`(click)="navigate()"`) não passam autoridade de SEO para os motores de busca.

---

## 5. Auditoria Contínua e Infraestrutura

### 5.1. Validação de Rastreamento
* Qualquer alteração na arquitetura híbrida deve ser auditada visualizando o código-fonte cru enviado pelo servidor e contrastando com a renderização da ferramenta de "Inspeção de URL" do Google Search Console.

### 5.2. Edge Caching
* A camada de Proxy Reverso (Nginx/Cloudflare) deve gerenciar compressão avançada (Brotli) e aplicar políticas de cache em disco/memória (offloading) para aliviar os *Controllers* .NET, derrubando o tempo de TTFB (Time to First Byte) para menos de 200ms.