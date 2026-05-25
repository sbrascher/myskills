# Context and Auditing

Methods for extracting security context and implementing audit logs.

## Security Context Extraction

Use `ContextService` to safely access user information and request metadata.

```csharp
public class ContextService
{
    // Extracts 'usuarioId' claim from the JWT
    public int UsuarioId() => GetClaimValue<int>("usuarioId");

    // Resolves Client IP, prioritizing Azure Front Door headers
    public string IpAddress()
    {
        string ip = GetHeaderValue("X-Azure-ClientIP");
        return string.IsNullOrWhiteSpace(ip) 
            ? _httpContextAccessor.HttpContext?.Connection.RemoteIpAddress?.ToString() 
            : ip;
    }

    public string Token() => GetHeaderValue("Authorization").Replace("Bearer ", "");
}
```

## Security Auditing (Application Insights)

Security events should be enriched with custom telemetry for monitoring and incident response.

```csharp
// Example in AutenticarCommandHandler
public async Task ExecutarAsync(AutenticarCommand command)
{
    // ... logic ...

    // Add User ID to the request telemetry for auditing
    _contextService.AddRequestTelemetryProperty("UsuarioId", dados.Id);

    if (dados.Bloqueado)
    {
        _logger.LogWarning("Tentativa de login em conta bloqueada: {Login}", command.Login);
    }
}
```

## Logging Best Practices

- **Login Failures**: Always log as `Warning`, including the login identifier (CPF/Email) but NEVER the password.
- **Critical Changes**: Log password updates and MFA resets as `Information` with the user ID.
- **Sensitive Data**: Never log passwords, salts, or the full JWT token content.
