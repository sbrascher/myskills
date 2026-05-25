# Validation Patterns

Uses FluentValidation to enforce business rules.

## AutenticarCommandValidation

```csharp
public class AutenticarCommandValidation : CommandValidationBase<AutenticarCommand>
{
    public AutenticarCommandValidation(ILogger logger) : base(logger)
    {
        RuleFor(x => x.Login)
            .NotEmpty()
            .WithMessage("CPF deve ser informado.")
            .Must(ValidationMethods.CpfValido)
            .WithMessage("CPF inválido.");

        RuleFor(x => x.Senha)
            .NotEmpty()
            .WithMessage("Senha deve ser informada.");
    }
}
```

## AtualizarSenhaCommandValidation

```csharp
public class AtualizarSenhaCommandValidation : CommandValidationBase<AtualizarSenhaCommand>
{
    public AtualizarSenhaCommandValidation(ILogger logger) : base(logger)
    {
        RuleFor(x => x.Senha)
            .NotEmpty()
            .WithMessage("Senha atual deve ser informada.");

        RuleFor(x => x.NovaSenha)
            .NotEmpty()
            .WithMessage("Nova senha deve ser informada.")
            .Must(ValidationMethods.SenhaValida)
            .WithMessage("Nova senha não atende aos requisitos de complexidade.");

        RuleFor(x => x.ConfirmacaoNovaSenha)
            .Equal(x => x.NovaSenha)
            .WithMessage("A confirmação da nova senha não confere.");
    }
}
```

## RecuperarSenhaCommandValidation

```csharp
public class RecuperarSenhaCommandValidation : CommandValidationBase<RecuperarSenhaCommand>
{
    public RecuperarSenhaCommandValidation(ILogger logger) : base(logger)
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .WithMessage("E-mail deve ser informado.")
            .EmailAddress()
            .WithMessage("E-mail inválido.");
    }
}
```

## ValidarMfaCommandValidation

```csharp
public class ValidarMfaCommandValidation : CommandValidationBase<ValidarMfaCommand>
{
    public ValidarMfaCommandValidation(ILogger logger) : base(logger)
    {
        RuleFor(x => x.Codigo)
            .NotEmpty()
            .WithMessage("Código de verificação deve ser informado.");
    }
}
```
