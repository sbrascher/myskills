using [ProjectName].Domain.Commands.{{ContextName}};
using [ProjectName].Domain.CommandValidations.{{ContextName}};
using [ProjectName].Domain.Interfaces.Repositories;
using [ProjectName].Domain.Models;
using [ProjectName].Domain.Models.Responses;
using [ProjectName].Tools.Notifications;
using FluentValidation.Results;

namespace [ProjectName].Domain.CommandHandlers.{{ContextName}};

public class Create{{EntityName}}CommandHandler
{
    private readonly DomainNotificationContext _domainNotificationContext;
    private readonly I{{EntityName}}Repository _{{EntityNameLowerCase}}Repository;

    public Create{{EntityName}}CommandHandler(
        DomainNotificationContext domainNotificationContext,
        I{{EntityName}}Repository {{EntityNameLowerCase}}Repository)
    {
        _domainNotificationContext = domainNotificationContext;
        _{{EntityNameLowerCase}}Repository = {{EntityNameLowerCase}}Repository;
    }

    public async Task<{{EntityName}}Response?> ExecuteAsync(Create{{EntityName}}Command command)
    {
        ValidationResult validationResult = new Create{{EntityName}}CommandValidator().Validate(command);
        if (!validationResult.IsValid)
        {
            _domainNotificationContext.Add(validationResult);
            return null;
        }

        {{EntityName}} {{EntityNameLowerCase}} = new({{ConstructorParamsFromCommand}});

        int {{EntityNameLowerCase}}Id = await _{{EntityNameLowerCase}}Repository.CreateAsync({{EntityNameLowerCase}});

        if ({{EntityNameLowerCase}}Id == 0)
        {
            _domainNotificationContext.Add("Não foi possível criar o registro.");
            return null;
        }

        return new {{EntityName}}Response
        {
            Id = {{EntityNameLowerCase}}Id,
            {{MapEntityToResponseProperties}}
        };
    }
}
