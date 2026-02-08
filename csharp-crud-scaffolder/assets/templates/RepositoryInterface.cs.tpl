using SeuProjeto.Application.Features.{{EntityNamePlural}}.Queries.Get{{EntityNamePlural}}Paged;
using SeuProjeto.Domain.Entities;
using System.Data;
using System.Threading.Tasks;

namespace SeuProjeto.Application.Abstractions
{
    public interface I{{EntityName}}Repository
    {
        Task<int> InsertAsync({{EntityName}} entity, IDbConnection connection, IDbTransaction transaction);
        Task<int> UpdateAsync({{EntityName}} entity, IDbConnection connection, IDbTransaction transaction);
        Task<int> DeleteAsync(int id, IDbConnection connection, IDbTransaction transaction);
        Task<{{EntityName}}?> GetByIdAsync(int id, IDbConnection connection);
        Task<PagedQueryResponse<{{EntityName}}Response>> GetPagedAsync(Get{{EntityNamePlural}}PagedQuery query, IDbConnection connection);
    }
}
