using [ProjectName].Domain.Commands.{{ContextName}};
using [ProjectName].Domain.CommandValidations.{{ContextName}};
using [ProjectName].Domain.Interfaces.Repositories;
using [ProjectName].Domain.Models;
using [ProjectName].Tools.Notifications;
using FluentValidation.Results;
using System.Net;

namespace [ProjectName].Domain.CommandHandlers.{{ContextName}};

public class Update{{EntityName}}CommandHandler
{
    private readonly DomainNotificationContext _domainNotificationContext;
    private readonly I{{EntityName}}Repository _{{EntityNameLowerCase}}Repository;

    public Update{{EntityName}}CommandHandler(
        DomainNotificationContext domainNotificationContext,
        I{{EntityName}}Repository {{EntityNameLowerCase}}Repository)
    {
        _domainNotificationContext = domainNotificationContext;
        _{{EntityNameLowerCase}}Repository = {{EntityNameLowerCase}}Repository;
    }

    public async Task ExecuteAsync(Update{{EntityName}}Command command)
    {
        ValidationResult validationResult = new Update{{EntityName}}CommandValidator().Validate(command);
        if (!validationResult.IsValid)
        {
            _domainNotificationContext.Add(validationResult);
            return;
        }

        {{EntityName}}? {{EntityNameLowerCase}} = await _{{EntityNameLowerCase}}Repository.GetByIdAsync(command.Id);

        if ({{EntityNameLowerCase}} == null)
        {
            _domainNotificationContext.Add("Registro não encontrado.", HttpStatusCode.NotFound);
            return;
        }

        {{MapCommandToEntityProperties}}
        {{EntityNameLowerCase}}.UsuarioAlteracaoId = command.UsuarioAlteracaoId;

        int linhaAfetadas = await _{{EntityNameLowerCase}}Repository.UpdateAsync({{EntityNameLowerCase}});

        if (linhaAfetadas == 0)
        {
            _domainNotificationContext.Add("Não foi possível alterar o registro.");
        }
    }
}
