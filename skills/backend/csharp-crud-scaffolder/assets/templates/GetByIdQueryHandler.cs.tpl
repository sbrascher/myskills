using SeuProjeto.Application.Abstractions;
using SeuProjeto.Application.Common;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Queries.Get{{EntityName}}ById
{
    public class Get{{EntityName}}ByIdQueryHandler
    {
        private readonly I{{EntityName}}Repository _{{EntityNameLowerCase}}Repository;
        private readonly IUnitOfWorkFactory _uowFactory; // Read operations don't need a transaction, but share the connection factory

        public Get{{EntityName}}ByIdQueryHandler(I{{EntityName}}Repository {{EntityNameLowerCase}}Repository, IUnitOfWorkFactory uowFactory)
        {
            _{{EntityNameLowerCase}}Repository = {{EntityNameLowerCase}}Repository;
            _uowFactory = uowFactory;
        }

        public async Task<{{EntityName}}Response?> ExecuteAsync(Get{{EntityName}}ByIdQuery query)
        {
            // Create a UoW to get a connection, but we won't use the transaction
            using (IUnitOfWork uow = _uowFactory.Create())
            {
                var entity = await _{{EntityNameLowerCase}}Repository.GetByIdAsync(query.Id, uow.Connection);

                if (entity == null)
                {
                    return null;
                }

                return new {{EntityName}}Response
                {
                    Id = entity.Id,
                    // {{MapEntityToResponseProperties}}
                };
            }
        }
    }
}
