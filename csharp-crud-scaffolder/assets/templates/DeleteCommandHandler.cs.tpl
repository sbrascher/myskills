using SeuProjeto.Application.Abstractions;
using SeuProjeto.Application.Common;
using SeuProjeto.Domain.Entities;
using FluentValidation.Results;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Delete{{EntityName}}
{
    public class Delete{{EntityName}}CommandHandler
    {
        private readonly DomainNotificationContext _domainNotificationContext;
        private readonly ILogger<Delete{{EntityName}}CommandHandler> _logger;
        private readonly I{{EntityName}}Repository _{{EntityNameLowerCase}}Repository;
        private readonly IUnitOfWorkFactory _uowFactory;

        public Delete{{EntityName}}CommandHandler(
            DomainNotificationContext domainNotificationContext,
            ILogger<Delete{{EntityName}}CommandHandler> logger,
            I{{EntityName}}Repository {{EntityNameLowerCase}}Repository,
            IUnitOfWorkFactory uowFactory)
        {
            _domainNotificationContext = domainNotificationContext;
            _logger = logger;
            _{{EntityNameLowerCase}}Repository = {{EntityNameLowerCase}}Repository;
            _uowFactory = uowFactory;
        }

        public async Task ExecuteAsync(Delete{{EntityName}}Command command)
        {
            ValidationResult validationResult = await new Delete{{EntityName}}CommandValidator().ValidateAsync(command);
            if (!validationResult.IsValid)
            {
                _domainNotificationContext.Add(validationResult);
                return;
            }

            using (IUnitOfWork uow = _uowFactory.Create())
            {
                try
                {
                    // Optional: Check if the entity exists before deleting
                    // var entity = await _{{EntityNameLowerCase}}Repository.GetByIdAsync(command.Id, uow.Connection);
                    // if (entity == null || entity.GroupId != command.GroupId) { ... }

                    // Optional: Check for linked records before deleting
                    // var linkedItems = await _{{EntityNameLowerCase}}Repository.CountItemsAsync(command.Id, uow.Connection);
                    // if (linkedItems > 0) { ... }

                    int rowsAffected = await _{{EntityNameLowerCase}}Repository.DeleteAsync(command.Id, uow.Connection, uow.Transaction);
                    if (rowsAffected == 0)
                    {
                        _domainNotificationContext.Add("{{EntityName}} record not found or already deleted.");
                        return;
                    }

                    uow.Commit();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error deleting {{EntityName}}.");
                    _domainNotificationContext.Add("An unexpected error occurred while deleting the {{EntityName}} record.");
                }
            }
        }
    }
}
