using SeuProjeto.Application.Abstractions;
using SeuProjeto.Application.Common;
using SeuProjeto.Domain.Entities;
using FluentValidation.Results;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Update{{EntityName}}
{
    public class Update{{EntityName}}CommandHandler
    {
        private readonly DomainNotificationContext _domainNotificationContext;
        private readonly ILogger<Update{{EntityName}}CommandHandler> _logger;
        private readonly I{{EntityName}}Repository _{{EntityNameLowerCase}}Repository;
        private readonly IUnitOfWorkFactory _uowFactory;

        public Update{{EntityName}}CommandHandler(
            DomainNotificationContext domainNotificationContext,
            ILogger<Update{{EntityName}}CommandHandler> logger,
            I{{EntityName}}Repository {{EntityNameLowerCase}}Repository,
            IUnitOfWorkFactory uowFactory)
        {
            _domainNotificationContext = domainNotificationContext;
            _logger = logger;
            _{{EntityNameLowerCase}}Repository = {{EntityNameLowerCase}}Repository;
            _uowFactory = uowFactory;
        }

        public async Task ExecuteAsync(Update{{EntityName}}Command command)
        {
            ValidationResult validationResult = await new Update{{EntityName}}CommandValidator().ValidateAsync(command);
            if (!validationResult.IsValid)
            {
                _domainNotificationContext.Add(validationResult);
                return;
            }

            using (IUnitOfWork uow = _uowFactory.Create())
            {
                try
                {
                    {{EntityName}}? entity = await _{{EntityNameLowerCase}}Repository.GetByIdAsync(command.Id, uow.Connection);

                    if (entity == null) // Or check group id: entity.GroupId != command.GroupId
                    {
                        _domainNotificationContext.Add("{{EntityName}} record not found.");
                        return;
                    }

                    // {{MapCommandToEntityProperties}}
                    // entity.LastChangeUserId = command.LastChangeUserId;

                    int rowsAffected = await _{{EntityNameLowerCase}}Repository.UpdateAsync(entity, uow.Connection, uow.Transaction);
                    if (rowsAffected == 0)
                    {
                        _domainNotificationContext.Add("Unable to update the {{EntityName}} record.");
                        return;
                    }

                    uow.Commit();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error updating {{EntityName}}.");
                    _domainNotificationContext.Add("An unexpected error occurred while updating the {{EntityName}} record.");
                }
            }
        }
    }
}
