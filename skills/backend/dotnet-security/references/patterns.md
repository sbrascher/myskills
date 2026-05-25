# Authentication Patterns

This reference documents the code patterns used for authentication in the Segov project.

## Controller Pattern

Controllers should use the `ApiControllerBase` and inject the Command Handler directly into the action method.

```csharp
[AllowAnonymous]
[HttpPost("Autenticar")]
[AutorizacaoComRecaptcha("autenticar")]
public async Task<IActionResult> AutenticarAsync(
    [FromServices] AutenticarCommandHandler commandHandler,
    [FromBody] AutenticarCommand command)
{
    (AutenticarResponse? response, int? statusCode) = await commandHandler.ExecutarAsync(command);
    return Response(response, statusCode);
}

[HttpPut("AtualizarSenha")]
public async Task<IActionResult> AtualizarSenhaAsync(
    [FromServices] AtualizarSenhaCommandHandler commandHandler,
    [FromBody] AtualizarSenhaCommand command)
{
    await commandHandler.ExecutarAsync(command);
    return Response();
}

[AllowAnonymous]
[HttpPut("RecuperarSenha")]
[AutorizacaoComRecaptcha("recuperarSenha")]
public async Task<IActionResult> RecuperarSenhaAsync(
    [FromServices] RecuperarSenhaCommandHandler commandHandler,
    [FromBody] RecuperarSenhaCommand command)
{
    await commandHandler.ExecutarAsync(command);
    return Response();
}

[AllowAnonymous]
[HttpPost("ValidarCodigoRecuperacaoSenha")]
[AutorizacaoComRecaptcha("validarCodigoRecuperacaoSenha")]
public async Task<IActionResult> ValidarCodigoRecuperacaoSenhaAsync(
    [FromServices] ValidarCodigoRecuperacaoSenhaCommandHandler commandHandler,
    [FromBody] ValidarCodigoRecuperacaoSenhaCommand command)
{
    await commandHandler.ExecutarAsync(command);
    return Response();
}

[AllowAnonymous]
[HttpPut("RecuperarSenhaAtualizar")]
[AutorizacaoComRecaptcha("recuperarSenhaAtualizar")]
public async Task<IActionResult> RecuperarSenhaAtualizarAsync(
    [FromServices] RecuperarSenhaAtualizarCommandHandler commandHandler,
    [FromBody] RecuperarSenhaAtualizarCommand command)
{
    await commandHandler.ExecutarAsync(command);
    return Response();
}

[HttpPost("ValidarMfa")]
public async Task<IActionResult> ValidarMfaAsync(
    [FromServices] ValidarMfaCommandHandler commandHandler,
    [FromBody] ValidarMfaCommand command)
{
    ValidarMfaResponse? response = await commandHandler.ExecutarAsync(command);
    return Response(response);
}

[HttpPost("ReenviarMfa")]
public async Task<IActionResult> ReenviarMfaAsync(
    [FromServices] ReenviarMfaCommandHandler commandHandler)
{
    ReenviarMfaResponse? response = await commandHandler.ExecutarAsync();
    return Response(response);
}
```

## Command Pattern

Commands are simple DTOs representing the intent.

```csharp
public class AutenticarCommand
{
    public required string Login { get; set; }
    public required string Senha { get; set; }
}

public class AtualizarSenhaCommand
{
    public required string Senha { get; set; }
    public required string NovaSenha { get; set; }
    public required string ConfirmacaoNovaSenha { get; set; }
}

public class RecuperarSenhaCommand
{
    public required string Email { get; set; }
}

public class ValidarCodigoRecuperacaoSenhaCommand
{
    public required string Email { get; set; }
    public required string CodigoRecuperacaoSenha { get; set; }
}

public class RecuperarSenhaAtualizarCommand
{
    public required string Email { get; set; }
    public required string Senha { get; set; }
    public required string ConfirmacaoSenha { get; set; }
    public required string CodigoRecuperacaoSenha { get; set; }
}

public class ValidarMfaCommand
{
    public required string Codigo { get; set; }
}
```

## Command Handler Pattern

The handler orchestrates the business logic, including validation, persistence, and external services.

Para exemplos detalhados de cada handler, veja [handlers.md](handlers.md).

## Validation Pattern

Uses FluentValidation to enforce business rules.

Para exemplos detalhados de cada validator, veja [validators.md](validators.md).
