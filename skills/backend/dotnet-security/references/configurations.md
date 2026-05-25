# Configuration and Environment Security

How to manage security settings and restrict access based on environment/network.

## Secure Configurations (Options Pattern)

All security settings are typed and loaded into the DI container using the `Options` pattern.

```csharp
// 1. Define the typed class (name must match appsettings section)
public class JwtConfiguration
{
    public string Secret { get; set; } = string.Empty;
    public int AccessTokenExpiresMinutes { get; set; }
}

// 2. Register in DependencyInjectionConfig
services.Configure<JwtConfiguration>(configuration.GetSection("JwtConfiguration"));

// 3. Usage in Services/Handlers
public class JwtService
{
    private readonly JwtConfiguration _config;
    public JwtService(IOptions<JwtConfiguration> options) => _config = options.Value;
}
```

## Azure KeyVault Integration

Secrets (like JWT keys and API passwords) should never be in `appsettings.json`. Use Azure KeyVault in Production.

```csharp
public static void AddAzureKeyVaultConfig(this IConfigurationBuilder configuration)
{
    if (Convert.ToBoolean(Environment.GetEnvironmentVariable("KeyVaultEnable")))
    {
        string uri = Environment.GetEnvironmentVariable("KeyVaultAddress");
        // KeyVault overrides local appsettings with the same key names
        configuration.AddAzureKeyVault(new Uri(uri), new DefaultAzureCredential());
    }
}
```

## Network and Environment Restrictions

Use custom attributes to restrict sensitive endpoints (like Debug or Internal tools).

### SomenteAmbienteInternoAttribute

Ensures an endpoint is only accessible if `SwaggerConfiguration.Enable` is true (usually only in Dev/Internal environments).

```csharp
[AttributeUsage(AttributeTargets.Method)]
public class SomenteAmbienteInternoAttribute : Attribute, IResourceFilter
{
    public void OnResourceExecuting(ResourceExecutingContext context)
    {
        var config = context.HttpContext.RequestServices.GetRequiredService<IOptions<SwaggerConfiguration>>();
        if (!config.Value.Enable)
        {
            context.Result = new NotFoundResult(); // Hides the endpoint (404)
        }
    }
}
```

## Azure Front Door (IP Restriction)

In Production, the API should only accept requests coming through Azure Front Door.

- **Middleware**: `AzureFrontDoorRequestMiddleware`
- **Validation**: Checks the `X-Azure-FDID` header against a known ID in `FrontDoorConfiguration`.
