---
name: dotnet-security
description: Implementa e gerencia o fluxo de autenticação (Login, MFA, Esqueci a Senha) seguindo os padrões de arquitetura e segurança do projeto Segov (.NET 9, DDD, CQRS). Use quando precisar criar ou modificar endpoints de autenticação, handlers de login ou regras de segurança.
---

# Dotnet Security Skill

Esta skill orienta a implementação e modificação do fluxo de autenticação no projeto Segov.

## Fluxo de Trabalho

Ao implementar um novo endpoint ou modificar o `AutenticarAsync`, siga estes passos:

1.  **Command & Validation**: Defina o `Command` e sua `Validation` correspondente.
2.  **Command Handler**: Implemente a lógica no Handler, garantindo o uso de Hashing com Salt e verificação de bloqueio.
3.  **Controller**: Adicione o método na `AutenticacaoController` usando `[AutorizacaoComRecaptcha]`.
4.  **Security**: Garanta que as configurações de MFA e JWT sejam respeitadas.

## Recursos Disponíveis

- **Padrões de Código**: Veja [patterns.md](references/patterns.md) para exemplos de Controllers e Commands.
- **Command Handlers**: Veja [handlers.md](references/handlers.md) para a lógica detalhada de cada comando.
- **Validations**: Veja [validators.md](references/validators.md) para regras de negócio com FluentValidation.
- **Repositories**: Veja [repositories.md](references/repositories.md) para persistência com Dapper.
- **Infraestrutura**: Veja [infrastructure.md](references/infrastructure.md) para Middlewares e Injeção de Dependência.
- **Contexto e Auditoria**: Veja [context.md](references/context.md) para extração de Claims e telemetria de segurança.
- **Configuração e Ambiente**: Veja [configurations.md](references/configurations.md) para segredos (KeyVault) e restrições de rede (Front Door).
- **Padrões de Segurança**: Veja [security.md](references/security.md) para detalhes sobre Hashing, Bloqueio de Conta, JWT, MFA e Recaptcha.

## Exemplo Rápido (AutenticarAsync)

```csharp
// 1. Controller
[AllowAnonymous]
[HttpPost("Autenticar")]
[AutorizacaoComRecaptcha("autenticar")]
public async Task<IActionResult> AutenticarAsync(...) { ... }

// 2. Handler Logic
DadosAutenticacao? dados = await _repo.ObterDadosAutenticacaoAsync(login);
if (dados == null) return Error(CpfOuSenhaInvalidos);
if (dados.Bloqueado) return Error(AcessoBloqueado, Locked);

string senhaHash = Hash.CreateToBase64String(senhaInformada, dados.Salt);
if (senhaHash != dados.Senha) return await TratarSenhaIncorretaAsync(dados);
```

## Observações Importantes

- Sempre use `DomainNotificationContext` para retornar erros de validação ou de negócio.
- Nunca retorne senhas ou salts nos responses da API.
- Use `HttpStatusCode.Accepted` (202) quando o MFA estiver habilitado e `HttpStatusCode.OK` (200) quando não.
