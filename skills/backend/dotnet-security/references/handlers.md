# Handlers Patterns

The handler orchestrates the business logic, including validation, persistence, and external services.

## AutenticarCommandHandler

Logic: Validates input -> Fetches user data -> Checks locking and salt hashing -> Handles failed attempts -> Generates JWT (MFA status dependent) -> Sends MFA if enabled.

```csharp
public async Task<(AutenticarResponse?, int?)> ExecutarAsync(AutenticarCommand command)
{
    ValidationResult validationResult = await new AutenticarCommandValidation(_logger).ValidateAsync(command);

    if (!validationResult.IsValid)
    {
        _domainNotificationContext.Add(validationResult);
        return (null, null);
    }

    DadosAutenticacao? dadosAutenticacao = await _usuarioSqlServerRepository.ObterDadosAutenticacaoAsync(command.Login);

    if (dadosAutenticacao == null)
    {
        _domainNotificationContext.Add(string.Format(DomainNotificationMessages.CpfOuSenhaInvalidosComBloqueio, _mfaConfiguration.MaximoTentativasLogin));
        return (null, null);
    }

    if (dadosAutenticacao.Bloqueado)
    {
        _domainNotificationContext.Add(DomainNotificationMessages.AcessoBloqueado, HttpStatusCode.Locked);
        return (null, null);
    }

    string senha = Hash.CreateToBase64String(command.Senha, dadosAutenticacao.Salt);

    if (senha != dadosAutenticacao.Senha)
    {
        await TratarSenhaIncorretaAsync(dadosAutenticacao.Id, dadosAutenticacao.FalhasTentativaLogin);
        return (null, null);
    }

    await _usuarioSqlServerRepository.AtualizarLoginRealizadoAsync(dadosAutenticacao.Id);

    if (_mfaConfiguration.Enable)
    {
        await EnviarCodigoMfaAsync(dadosAutenticacao.Id);
    }

    string token = _jwtService.CriarAccessToken(dadosAutenticacao.Id, _mfaConfiguration.Enable);
    HttpStatusCode httpStatusCode = _mfaConfiguration.Enable ? HttpStatusCode.Accepted : HttpStatusCode.OK;

    return (new AutenticarResponse { Token = token, ... }, (int)httpStatusCode);
}
```

## ValidarMfaCommandHandler

Logic: Checks if MFA is enabled -> Validates code against repository -> Manages attempts and expiration -> If valid, deletes MFA record and issues final JWT.

```csharp
public async Task<ValidarMfaResponse?> ExecutarAsync(ValidarMfaCommand command)
{
    ValidationResult validationResult = await new ValidarMfaCommandValidation(_logger).ValidateAsync(command);

    if (!validationResult.IsValid)
    {
        _domainNotificationContext.Add(validationResult);
        return null;
    }

    UsuarioMfa? usuarioMfa = await _usuarioMfaRepository.ObterAsync(_contextService.UsuarioId());

    if (usuarioMfa == null)
    {
        _domainNotificationContext.Add(DomainNotificationMessages.ParametrosInvalidos);
        return null;
    }

    if (usuarioMfa.TentativasIncorretas >= _mfaConfiguration.MaximoTentativasMfa)
    {
        _domainNotificationContext.Add("Limite de tentativas de MFA excedido. Solicite um novo código.");
        return null;
    }

    if (DateTime.Now > usuarioMfa.DataExpiracao)
    {
        _domainNotificationContext.Add("O código de verificação expirou. Solicite um novo código.");
        return null;
    }

    if (usuarioMfa.Codigo != command.Codigo)
    {
        await _usuarioMfaRepository.IncrementarTentativasAsync(usuarioMfa.UsuarioId);
        _domainNotificationContext.Add("Código de verificação inválido.");
        return null;
    }

    await _usuarioMfaRepository.ExcluirAsync(usuarioMfa.UsuarioId);

    string token = _jwtService.CriarAccessToken(usuarioMfa.UsuarioId, false);

    return new ValidarMfaResponse { Token = token };
}
```

## AtualizarSenhaCommandHandler

Logic: Validates input -> Fetches current user -> Verifies current password (salt hash) -> Updates to new password using the same salt.

```csharp
public async Task ExecutarAsync(AtualizarSenhaCommand command)
{
    ValidationResult validationResult = await new AtualizarSenhaCommandValidation(_logger).ValidateAsync(command);

    if (!validationResult.IsValid)
    {
        _domainNotificationContext.Add(validationResult);
        return;
    }

    Usuario? usuario = await _usuarioSqlServerRepository.ObterAsync(_contextService.UsuarioId());

    if (usuario == null)
    {
        _domainNotificationContext.Add(DomainNotificationMessages.ParametrosInvalidos);
        return;
    }

    string senhaAtual = Hash.CreateToBase64String(command.Senha, usuario.Salt);

    if (senhaAtual != usuario.Senha)
    {
        _domainNotificationContext.Add(DomainNotificationMessages.SenhaAtualInvalida);
        return;
    }

    string novaSenha = Hash.CreateToBase64String(command.NovaSenha, usuario.Salt);

    await _usuarioSqlServerRepository.AtualizarSenhaAsync(usuario.Id, novaSenha);
}
```

## RecuperarSenhaCommandHandler

Logic: Validates email -> Rate limiting check -> Generates code and sends email -> Updates DB with code and timestamp.

```csharp
public async Task ExecutarAsync(RecuperarSenhaCommand command)
{
    ValidationResult validationResult = await new RecuperarSenhaCommandValidation(_logger).ValidateAsync(command);

    if (!validationResult.IsValid)
    {
        _domainNotificationContext.Add(validationResult);
        return;
    }

    Pessoa? pessoa = await _pessoaSqlServerRepository.ObterAsync(command.Email);

    if (pessoa == null)
    {
        _domainNotificationContext.Add("E-mail inválido.");
        return;
    }

    Usuario? usuario = await _usuarioSqlServerRepository.ObterAsync(pessoa.UsuarioId);

    if (usuario!.DataEnvioRecuperacaoSenha.HasValue)
    {
        double tempoDecorridoEnvio = DateTime.Now.Subtract(usuario.DataEnvioRecuperacaoSenha.Value).TotalSeconds;

        if (tempoDecorridoEnvio < _recuperacaoSenhaConfiguration.IntervaloEnvioCodigoSegundos)
        {
            _domainNotificationContext.Add("Instruções já enviadas. Aguarde para tentar novamente.");
            return;
        }
    }

    string codigo = _emailService.GerarCodigoConfirmacaoEmail().ToString();
    await _emailService.EnviarCodigoRecuperacaoSenhaAsync(pessoa.Email, codigo);
    await _usuarioSqlServerRepository.AtualizarRecuperacaoSenhaAsync(usuario.Id, codigo);
}
```
