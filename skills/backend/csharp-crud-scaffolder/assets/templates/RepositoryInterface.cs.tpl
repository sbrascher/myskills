using [ProjectName].Domain.Models;
using [ProjectName].Domain.Responses;
using [ProjectName].Tools.Queries;

namespace [ProjectName].Domain.Interfaces.Repositories;

public interface I{{EntityName}}Repository
{
    Task<int> CreateAsync({{EntityName}} {{EntityNameLowerCase}});

    Task<int> UpdateAsync({{EntityName}} {{EntityNameLowerCase}});

    Task<int> DeleteAsync(int id);

    Task<{{EntityName}}?> GetByIdAsync(int id);

    Task<{{EntityName}}Response?> GetResponseByIdAsync(int id);

    Task<PagedQueryResponse<{{EntityName}}Response>> GetPagedAsync({{FilterParams}}, PagedQuery query);
}
