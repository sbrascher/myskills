# Modelos de Implementação de Referência (.NET 8/9 MVC)

Este guia de referência descreve o código de infraestrutura completo para implementar a engine de blog estático de alta performance baseada em arquivos Markdown.

---

## 1. O Modelo e Serviços Core

### A. Entidade do Post (`BlogPost.cs`)
```csharp
namespace BlogEngine.Core.Models;

public class BlogPost
{
    // YAML Frontmatter properties
    public string Title { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public string Description { get; set; } = string.Empty;
    public List<string> Tags { get; set; } = new();
    public string Author { get; set; } = string.Empty;
    public string CoverImage { get; set; } = string.Empty;
    public bool Draft { get; set; } = false;

    // Body content properties
    public string ContentMarkdown { get; set; } = string.Empty;
    public string ContentHtml { get; set; } = string.Empty;
}
```

### B. O Cache de Posts com Auto-Reload (`BlogCacheService.cs`)
Esta classe carrega todos os arquivos `.md` na inicialização da aplicação em memória e expõe métodos rápidos para busca, paginação e listagem. Ela utiliza um `FileSystemWatcher` para monitorar a pasta de posts e recarregar o cache automaticamente sempre que um arquivo for adicionado, editado ou deletado.

```csharp
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;
using Markdig;
using BlogEngine.Core.Models;

namespace BlogEngine.Core.Services;

public interface IBlogCache
{
    IReadOnlyList<BlogPost> GetPosts();
    BlogPost? GetPostBySlug(string slug);
    IReadOnlyList<BlogPost> GetPostsByTag(string tag);
}

public class BlogCacheService : IHostedService, IBlogCache
{
    private readonly string _postsDirectory;
    private readonly ILogger<BlogCacheService> _logger;
    private readonly IDeserializer _yamlDeserializer;
    private readonly MarkdownPipeline _markdownPipeline;
    private FileSystemWatcher? _watcher;
    
    private List<BlogPost> _cache = new();
    private readonly object _lock = new();

    public BlogCacheService(IHostEnvironment env, ILogger<BlogCacheService> logger)
    {
        _logger = logger;
        _postsDirectory = Path.Combine(env.ContentRootPath, "wwwroot", "content", "posts");
        
        _yamlDeserializer = new DeserializerBuilder()
            .WithNamingConvention(CamelCaseNamingConvention.Instance)
            .IgnoreUnmatchedProperties()
            .Build();

        _markdownPipeline = new MarkdownPipelineBuilder()
            .UseAdvancedExtensions()
            .Build();
    }

    public Task StartAsync(CancellationToken cancellationToken)
    {
        Directory.CreateDirectory(_postsDirectory);
        
        LoadAllPosts();
        SetupFileSystemWatcher();

        return Task.CompletedTask;
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        _watcher?.Dispose();
        return Task.CompletedTask;
    }

    public IReadOnlyList<BlogPost> GetPosts()
    {
        lock (_lock)
        {
            return _cache.Where(p => !p.Draft).OrderByDescending(p => p.Date).ToList();
        }
    }

    public BlogPost? GetPostBySlug(string slug)
    {
        lock (_lock)
        {
            return _cache.FirstOrDefault(p => p.Slug.Equals(slug, StringComparison.OrdinalIgnoreCase) && !p.Draft);
        }
    }

    public IReadOnlyList<BlogPost> GetPostsByTag(string tag)
    {
        lock (_lock)
        {
            return _cache
                .Where(p => !p.Draft && p.Tags.Contains(tag, StringComparer.OrdinalIgnoreCase))
                .OrderByDescending(p => p.Date)
                .ToList();
        }
    }

    private void LoadAllPosts()
    {
        _logger.LogInformation("Iniciando carregamento de posts do diretório: {Dir}", _postsDirectory);
        
        var tempPosts = new List<BlogPost>();
        var files = Directory.GetFiles(_postsDirectory, "*.md");

        foreach (var file in files)
        {
            try
            {
                var content = File.ReadAllText(file);
                var post = ParsePostContent(content);
                
                if (string.IsNullOrEmpty(post.Slug))
                {
                    post.Slug = Path.GetFileNameWithoutExtension(file).ToLowerInvariant();
                }

                tempPosts.Add(post);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao processar o arquivo de post: {File}", file);
            }
        }

        lock (_lock)
        {
            _cache = tempPosts;
        }

        _logger.LogInformation("Carregamento concluído. {Count} posts adicionados ao cache.", _cache.Count);
    }

    private BlogPost ParsePostContent(string fileContent)
    {
        // Dividir a string no cabeçalho YAML Frontmatter
        var parts = fileContent.Split(new[] { "---" }, 3, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length < 2)
        {
            throw new FormatException("O post do blog deve conter metadados YAML Frontmatter delimitados por '---'.");
        }

        var yaml = parts[0];
        var markdownContent = parts[1].Trim();

        var post = _yamlDeserializer.Deserialize<BlogPost>(yaml);
        post.ContentMarkdown = markdownContent;
        post.ContentHtml = Markdown.ToHtml(markdownContent, _markdownPipeline);

        return post;
    }

    private void SetupFileSystemWatcher()
    {
        _watcher = new FileSystemWatcher(_postsDirectory, "*.md")
        {
            NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite | NotifyFilters.Size,
            EnableRaisingEvents = true
        };

        var reloadCache = (object sender, FileSystemEventArgs e) =>
        {
            _logger.LogInformation("Mudança detectada no diretório de posts ({ChangeType}). Recarregando...", e.ChangeType);
            LoadAllPosts();
        };

        _watcher.Created += (s, e) => reloadCache(s, e);
        _watcher.Changed += (s, e) => reloadCache(s, e);
        _watcher.Deleted += (s, e) => reloadCache(s, e);
        _watcher.Renamed += (s, e) => reloadCache(s, e);
    }
}
```

---

## 2. A Camada de Apresentação (Controller MVC)

### A. Controlador Principal (`BlogController.cs`)
Implementa paginação, busca por tags e detalhes do artigo.

```csharp
using Microsoft.AspNetCore.Mvc;
using BlogEngine.Core.Services;

namespace BlogEngine.Controllers;

public class BlogController : Controller
{
    private readonly IBlogCache _blogCache;
    private const int PageSize = 6;

    public BlogController(IBlogCache blogCache)
    {
        _blogCache = blogCache;
    }

    [HttpGet("")]
    public IActionResult Index([FromQuery] int page = 1)
    {
        if (page < 1) page = 1;

        var allPosts = _blogCache.GetPosts();
        var totalPosts = allPosts.Count;
        var totalPages = (int)Math.Ceiling((double)totalPosts / PageSize);

        var posts = allPosts
            .Skip((page - 1) * PageSize)
            .Take(PageSize)
            .ToList();

        ViewData["CurrentPage"] = page;
        ViewData["TotalPages"] = totalPages;

        return View(posts);
    }

    [HttpGet("post/{slug}")]
    public IActionResult Details(string slug)
    {
        var post = _blogCache.GetPostBySlug(slug);
        if (post == null)
        {
            return NotFound();
        }

        return View(post);
    }

    [HttpGet("tag/{tag}")]
    public IActionResult Tag(string tag, [FromQuery] int page = 1)
    {
        if (page < 1) page = 1;

        var tagPosts = _blogCache.GetPostsByTag(tag);
        var totalPosts = tagPosts.Count;
        var totalPages = (int)Math.Ceiling((double)totalPosts / PageSize);

        var posts = tagPosts
            .Skip((page - 1) * PageSize)
            .Take(PageSize)
            .ToList();

        ViewData["Tag"] = tag;
        ViewData["CurrentPage"] = page;
        ViewData["TotalPages"] = totalPages;

        return View(posts);
    }
}
```

---

## 3. SEO dinâmico, Sitemap e Feed RSS

Esses componentes adicionais trazem alto valor de SEO técnico nativo para o blog estático.

### A. Geração de Sitemap Dinâmico (`SitemapController.cs`)
```csharp
using System.Text;
using System.Xml;
using Microsoft.AspNetCore.Mvc;
using BlogEngine.Core.Services;

namespace BlogEngine.Controllers;

[ApiController]
public class SitemapController : ControllerBase
{
    private readonly IBlogCache _blogCache;

    public SitemapController(IBlogCache blogCache)
    {
        _blogCache = blogCache;
    }

    [HttpGet("sitemap.xml")]
    public IActionResult GetSitemap()
    {
        var baseUrl = $"{Request.Scheme}://{Request.Host}";
        var posts = _blogCache.GetPosts();

        var xmlDoc = new XmlDocument();
        var xmlDeclaration = xmlDoc.CreateXmlDeclaration("1.0", "UTF-8", null);
        xmlDoc.AppendChild(xmlDeclaration);

        var urlset = xmlDoc.CreateElement("urlset", "http://www.sitemaps.org/schemas/sitemap/0.9");
        xmlDoc.AppendChild(urlset);

        // Página Inicial
        AddUrlElement(xmlDoc, urlset, baseUrl, DateTime.UtcNow, "daily", "1.0");

        // Posts
        foreach (var post in posts)
        {
            AddUrlElement(
                xmlDoc, 
                urlset, 
                $"{baseUrl}/post/{post.Slug}", 
                post.Date, 
                "monthly", 
                "0.8"
            );
        }

        var stringWriter = new StringWriterWithEncoding(Encoding.UTF8);
        using (var xmlWriter = XmlWriter.Create(stringWriter, new XmlWriterSettings { Indent = true }))
        {
            xmlDoc.Save(xmlWriter);
        }

        return Content(stringWriter.ToString(), "application/xml");
    }

    private void AddUrlElement(XmlDocument doc, XmlElement root, string loc, DateTime lastmod, string changefreq, string priority)
    {
        var url = doc.CreateElement("url", root.NamespaceURI);

        var locNode = doc.CreateElement("loc", root.NamespaceURI);
        locNode.InnerText = loc;
        url.AppendChild(locNode);

        var lastmodNode = doc.CreateElement("lastmod", root.NamespaceURI);
        lastmodNode.InnerText = lastmod.ToString("yyyy-MM-dd");
        url.AppendChild(lastmodNode);

        var changefreqNode = doc.CreateElement("changefreq", root.NamespaceURI);
        changefreqNode.InnerText = changefreq;
        url.AppendChild(changefreqNode);

        var priorityNode = doc.CreateElement("priority", root.NamespaceURI);
        priorityNode.InnerText = priority;
        url.AppendChild(priorityNode);

        root.AppendChild(url);
    }

    private class StringWriterWithEncoding : StringWriter
    {
        public StringWriterWithEncoding(Encoding encoding) { Encoding = encoding; }
        public override Encoding Encoding { get; }
    }
}
```
