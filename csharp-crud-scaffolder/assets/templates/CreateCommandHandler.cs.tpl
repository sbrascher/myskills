using SeuProjeto.Application.Abstractions;
using SeuProjeto.Application.Common;
using SeuProjeto.Domain.Entities;
using FluentValidation.Results;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Create{{EntityName}}
{
    public class Create{{EntityName}}CommandHandler
    {
        private readonly DomainNotificationContext _domainNotificationContext;
        private readonly ILogger<Create{{EntityName}}CommandHandler> _logger;
        private readonly I{{EntityName}}Repository _{{EntityNameLowerCase}}Repository;
        private readonly IUnitOfWorkFactory _uowFactory;

        public Create{{EntityName}}CommandHandler(
            DomainNotificationContext domainNotificationContext,
            ILogger<Create{{EntityName}}CommandHandler> logger,
            I{{EntityName}}Repository {{EntityNameLowerCase}}Repository,
            IUnitOfWorkFactory uowFactory)
        {
            _domainNotificationContext = domainNotificationContext;
            _logger = logger;
            _{{EntityNameLowerCase}}Repository = {{EntityNameLowerCase}}Repository;
            _uowFactory = uowFactory;
        }

        public async Task<{{EntityName}}Response?> ExecuteAsync(Create{{EntityName}}Command command)
        {
            ValidationResult validationResult = await new Create{{EntityName}}CommandValidator().ValidateAsync(command);
            if (!validationResult.IsValid)
            {
                _domainNotificationContext.Add(validationResult);
                return null;
            }

            using (IUnitOfWork uow = _uowFactory.Create())
            {
                try
                {
                    // You might want to add a check for existing entities here
                    // var existingEntity = await _{{EntityNameLowerCase}}Repository.GetByNameAsync(command.Name, uow.Connection);
                    // if (existingEntity != null) { ... }

                    {{EntityName}} entity = new()
                    {
                        // {{MapCommandToEntityProperties}}
                    };

                    entity.Id = await _{{EntityNameLowerCase}}Repository.InsertAsync(entity, uow.Connection, uow.Transaction);

                    if (entity.Id == 0)
                    {
                        _domainNotificationContext.Add("Unable to insert the {{EntityName}} record.");
                        return null;
                    }

                    uow.Commit();

                    return new {{EntityName}}Response
                    {
                        Id = entity.Id,
                        // {{MapEntityToResponseProperties}}
                    };
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error inserting {{EntityName}}.");
                    _domainNotificationContext.Add("An unexpected error occurred while inserting the {{EntityName}} record.");
                    return null;
                }
            }
        }
    }
}
