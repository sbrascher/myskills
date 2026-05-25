using SeuProjeto.Application.Abstractions;
using SeuProjeto.Application.Common;
using System.Threading.Tasks;

namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Queries.Get{{EntityNamePlural}}Paged
{
    public class Get{{EntityNamePlural}}PagedQueryHandler
    {
        private readonly I{{EntityName}}Repository _{{EntityNameLowerCase}}Repository;
        private readonly IUnitOfWorkFactory _uowFactory;

        public Get{{EntityNamePlural}}PagedQueryHandler(I{{EntityName}}Repository {{EntityNameLowerCase}}Repository, IUnitOfWorkFactory uowFactory)
        {
            _{{EntityNameLowerCase}}Repository = {{EntityNameLowerCase}}Repository;
            _uowFactory = uowFactory;
        }

        public async Task<PagedQueryResponse<{{EntityName}}Response>> ExecuteAsync(Get{{EntityNamePlural}}PagedQuery query)
        {
            using (IUnitOfWork uow = _uowFactory.Create())
            {
                return await _{{EntityNameLowerCase}}Repository.GetPagedAsync(query, uow.Connection);
            }
        }
    }
}
