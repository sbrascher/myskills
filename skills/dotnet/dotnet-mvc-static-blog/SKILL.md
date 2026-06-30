---
name: dotnet-mvc-static-blog
description: Engenheiro especialista em criar, otimizar e manter engines de blog estáticas em ASP.NET Core MVC de alta performance, utilizando Markdown, YAML Frontmatter, cache em memória e Docker para hospedagem multitenant.
---

# 🤖 Engenheiro de Blog .NET MVC Estático

Esta skill orienta e automatiza a criação, manutenção e geração de conteúdo para uma engine de blog customizada, de altíssima performance, desenvolvida em **ASP.NET Core MVC** utilizando arquivos Markdown (.md) como fonte de dados (banco de dados inexistente).

---

## 1. Arquitetura do Projeto

Não sugira soluções baseadas em bancos de dados relacionais (SQL), NoSQL ou WordPress. Toda a arquitetura do projeto segue estritamente os seguintes pilares:

* **Framework:** ASP.NET Core MVC (geralmente .NET 8 ou .NET 9).
* **Armazenamento:** Sem banco de dados. Os artigos são arquivos Markdown (`.md`) com metadados estruturados no topo (YAML Frontmatter).
* **Parsers Principais:**
  * `YamlDotNet` para ler os metadados do Frontmatter.
  * `Markdig` para converter o corpo do Markdown em HTML seguro.
* **Mecanismo de Cache:** Os posts devem ser carregados em memória (`IMemoryCache` ou um singleton dedicado) na inicialização da aplicação usando um `IHostedService` (ou `BackgroundService`). Isso garante respostas instantâneas na listagem, filtros e geração de sitemaps.
* **Hospedagem & Deploy:** Executado via **Docker** em uma VPS. O build do código .NET produz uma imagem genérica. O conteúdo dos posts e os assets (imagens) são injetados em tempo de execução via **Volumes do Docker**.
* **Multitenancy Estilo Variáveis de Ambiente:** O mesmo container C# serve diferentes blogs. Cores, logos e nome do site são lidos do `appsettings.json` (populados via variáveis de ambiente no container) e injetados nas Razor Views e no CSS via variáveis CSS nativas (`:root`).

---

## 2. Padrões de Código e Infraestrutura C#

### A. Modelo de Dados (`BlogPost.cs`)
```csharp
public class BlogPost
{
    // Mapeados a partir do YAML Frontmatter
    public string Title { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public string Description { get; set; } = string.Empty;
    public List<string> Tags { get; set; } = new();
    public string Author { get; set; } = string.Empty;
    public string CoverImage { get; set; } = string.Empty;
    public bool Draft { get; set; } = false;

    // Preenchidos após parsing do Markdown
    public string ContentMarkdown { get; set; } = string.Empty;
    public string ContentHtml { get; set; } = string.Empty;
}
```

### B. Leitura e Parse de Posts
Utilize `YamlDotNet.Serialization` e `Markdig`. 
Exemplo de processador de arquivo:
```csharp
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;
using Markdig;

public class BlogService
{
    private readonly MarkdownPipeline _pipeline;
    private readonly IDeserializer _yamlDeserializer;

    public BlogService()
    {
        _pipeline = new MarkdownPipelineBuilder()
            .UseAdvancedExtensions()
            .UseFriendlyFrontmatter() // Se aplicável, ou parse manual
            .Build();

        _yamlDeserializer = new DeserializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .IgnoreUnmatchedProperties()
            .Build();
    }

    public BlogPost ParsePost(string fileContent)
    {
        // Separação manual básica do Frontmatter (entre "---" e "---")
        var parts = fileContent.Split(new[] { "---" }, 3, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length < 2) throw new FormatException("Formato inválido. O post precisa conter YAML Frontmatter.");

        var yaml = parts[0];
        var markdown = parts[1];

        var post = _yamlDeserializer.Deserialize<BlogPost>(yaml);
        post.ContentMarkdown = markdown.Trim();
        post.ContentHtml = Markdown.ToHtml(markdown, _pipeline);

        return post;
    }
}
```

---

## 3. SEO e HTML Semântico (Razor Views)

Sempre que gerar código HTML nas Razor Views, siga regras rígidas de acessibilidade e semântica:

1. **Tag `<article>`:** O artigo em si deve estar envelopado em `<article>`.
2. **Navegação Semântica:** Use `<header>`, `<nav>`, `<main>`, `<footer>` e `<aside>` adequadamente.
3. **Meta Tags de SEO dinâmicas:** No `_Layout.cshtml`, leia do `ViewData` as seguintes tags:
   * `<title>@ViewData["Title"] - Nome do Blog</title>`
   * `<meta name="description" content="@ViewData["Description"]" />`
   * Open Graph (`og:title`, `og:description`, `og:image`, `og:type`, `og:url`).
   * Twitter Cards (`twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`).
4. **Links Relacionais:** Tags de paginação de posts devem conter `rel="prev"` e `rel="next"`.
5. **Imagens Responsivas:** Imagens devem conter atributos `alt` preenchidos e `loading="lazy"` para imagens que não estão no topo da página.

---

## 4. Estrutura de Diretórios e Docker

O deploy usa volumes Docker para manter o código agnóstico ao conteúdo:

```
/app
  /wwwroot
    /content
      /posts        <-- Montado como Volume Docker para ler os Markdowns (.md)
    /images
      /posts        <-- Montado como Volume Docker para assets de imagens
```

### Regra de Nomenclatura e Caminho de Imagens:
* O caminho das imagens de um post específico deve ficar em `/images/posts/{slug-do-artigo}/nome-da-imagem.webp`.
* Recomende sempre o uso do formato moderno **WebP** para melhor performance e pontuação do Core Web Vitals (LCP).

### Exemplo de Configuração Docker Compose (`docker-compose.yml`)
```yaml
services:
  blog-engine:
    image: sergio/dotnet-blog-engine:latest
    container_name: dotnet_blog_production
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - BlogSettings__SiteName="Meu Blog de Tech"
      - BlogSettings__PrimaryColor="#0f172a"
      - BlogSettings__AccentColor="#3b82f6"
    volumes:
      - /var/www/myblog/posts:/app/wwwroot/content/posts
      - /var/www/myblog/images/posts:/app/wwwroot/wwwroot/images/posts
    ports:
      - "8080:8080"
    restart: always
```

---

## 5. Workflow de Resolução do Agente

Ao receber uma requisição de blog em .NET MVC, siga estas etapas:

1. **Determinar o Tipo de Requisição:**
   * **Infraestrutura/Código:** Configurar rotas, injeção de dependências, controle de cache, leitura de arquivos físicos, geração de RSS/Sitemap dinâmicos, ou classes C#.
   * **Layout/Estilos:** Modificar Razor Views, configurar variáveis CSS no layout principal, estilizar o componente markdown (com classes `.markdown-content` ou Tailwind CSS Typography).
   * **Conteúdo/Artigo:** Escrever posts em markdown seguindo o exemplo de referência.
2. **Validação das Diretrizes:**
   * Garanta que o cache (`IMemoryCache` com expiração absoluta ou cache estático com FileSystemWatcher) seja implementado corretamente para não ler arquivos do disco em toda requisição de página.
   * Valide se o SEO está totalmente coberto.
   * Forneça explicações concisas focando no alto desempenho do C# moderno (.NET 8/9).
