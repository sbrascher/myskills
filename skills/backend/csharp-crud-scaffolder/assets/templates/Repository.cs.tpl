using [ProjectName].Domain.Interfaces.Repositories;
using [ProjectName].Domain.Models;
using [ProjectName].Domain.Models.Responses;
using [ProjectName].Infra.Data;
using [ProjectName].Infra.Data.Extensions;
using [ProjectName].Tools.Queries;
using Dapper;
using System.Data;
using System.Text;

namespace [ProjectName].Infra.Data.Repositories;

public class {{EntityName}}Repository : I{{EntityName}}Repository
{
    private readonly DbSession _session;

    public {{EntityName}}Repository(DbSession session)
    {
        _session = session;
    }

    public async Task<int> CreateAsync({{EntityName}} {{EntityNameLowerCase}})
    {
        string sql = @"
            INSERT INTO {{EntityName}} 
            ( 
                {{LiteralFieldsExceptId}},
                UsuarioCriacaoId
            ) VALUES (
                {{AtLiteralFieldsExceptId}},
                @UsuarioCriacaoId
            );
            SELECT SCOPE_IDENTITY();
        ";

        return await _session.Connection.ExecuteScalarAsync<int>(sql, {{EntityNameLowerCase}}, _session.Transaction);
    }

    public async Task<int> UpdateAsync({{EntityName}} {{EntityNameLowerCase}})
    {
        string sql = @"
            UPDATE {{EntityName}} SET
                {{UpdateSetStatements}},
                UsuarioAlteracaoId = @UsuarioAlteracaoId
            WHERE Id = @Id
        ";

        return await _session.Connection.ExecuteAsync(sql, {{EntityNameLowerCase}}, _session.Transaction);
    }

    public async Task<int> DeleteAsync(int id)
    {
        string sql = "DELETE FROM {{EntityName}} WHERE Id = @Id";
        return await _session.Connection.ExecuteAsync(sql, new { Id = id }, _session.Transaction);
    }

    public async Task<{{EntityName}}?> GetByIdAsync(int id)
    {
        // Regra: Campos listados literalmente, nunca SELECT *
        string sql = "SELECT {{LiteralFields}} FROM {{EntityName}} WHERE Id = @Id";
        return await _session.Connection.QuerySingleOrDefaultAsync<{{EntityName}}>(sql, new { Id = id }, _session.Transaction);
    }

    public async Task<{{EntityName}}Response?> GetResponseByIdAsync(int id)
    {
        string sql = "SELECT {{LiteralFields}} FROM {{EntityName}} WHERE Id = @Id";
        return await _session.Connection.QuerySingleOrDefaultAsync<{{EntityName}}Response>(sql, new { Id = id }, _session.Transaction);
    }

    public async Task<PagedQueryResponse<{{EntityName}}Response>> GetPagedAsync({{FilterParams}}, PagedQuery query)
    {
        (string where, DynamicParameters parameters) = BuildFilters({{FilterParamsUsage}});

        string sql = $@"
            SELECT {{LiteralFields}}
            FROM {{EntityName}}
            {where}
        ";

        return await _session.Connection.QueryPagedAsync<{{EntityName}}Response>(sql, "Id", parameters, query);
    }

    private static (string where, DynamicParameters parameters) BuildFilters({{FilterParams}})
    {
        DynamicParameters parameters = new();
        StringBuilder sb = new(" WHERE 1=1 ");

        {{FilterConditions}}

        return (sb.ToString(), parameters);
    }
}
