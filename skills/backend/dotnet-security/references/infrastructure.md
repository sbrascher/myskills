# Infrastructure and Lifecycle

This section covers Middleware integration, Dependency Injection (DI), and Service registration.

## MFA Enforcement Middleware

The `RequerMfaMiddleware` intercepts requests to ensure that authenticated users with a pending MFA (`mfaPendente` claim) can only access MFA-related endpoints.

```csharp
public class RequerMfaMiddleware
{
    private readonly RequestDelegate _next;
    private readonly bool _mfaHabilitado;
    private readonly string[] UrlsPermitidasMfa = ["/Autenticacao/ValidarMfa", "/Autenticacao/ReenviarMfa"];

    public async Task InvokeAsync(HttpContext context)
    {
        // 1. Skip if MFA is globally disabled or user is not authenticated
        if (!_mfaHabilitado || context.User?.Identity?.IsAuthenticated != true)
        {
            await _next(context);
            return;
        }

        // 2. Skip if user has already completed MFA
        if (context.User.FindFirstValue("mfaPendente") == "False")
        {
            await _next(context);
            return;
        }

        // 3. Allow access only to MFA validation/resend endpoints
        if (UrlsPermitidasMfa.Any(url => context.Request.Path.Value.StartsWith(url, ...)))
        {
            await _next(context);
            return;
        }

        // 4. Block other requests with 202 Accepted (standard for "pending action")
        context.Response.StatusCode = (int)HttpStatusCode.Accepted;
    }
}
```

## Dependency Injection Registration

All security components must be registered in `NativeInjectorBootStrapper`.

```csharp
public static void RegisterServices(IServiceCollection services)
{
    // Scoped: New instance per request (essential for Context and Notifications)
    services.AddScoped<DomainNotificationContext>();
    services.AddScoped<ContextService>();
    services.AddScoped<JwtService>();

    // Handlers
    services.AddScoped<AutenticarCommandHandler>();
    services.AddScoped<ValidarMfaCommandHandler>();

    // Repositories
    services.AddScoped<IUsuarioSqlServerRepository, UsuarioSqlServerRepository>();
    services.AddScoped<IUsuarioMfaRepository, UsuarioMfaSqlServerRepository>();
}
```

- **Scoped**: Use for everything that depends on the current user or request context.
- **Singleton**: Use only for stateless utilities or configurations that don't change.
