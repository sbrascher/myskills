using Dapper;
using SeuProjeto.Application.Abstractions;
using SeuProjeto.Application.Features.{{EntityNamePlural}}.Queries.Get{{EntityNamePlural}}Paged;
using SeuProjeto.Domain.Entities;
using System.Data;
using System.Text;
using System.Threading.Tasks;

namespace SeuProjeto.Infrastructure.Persistence.Repositories
{
    public class {{EntityName}}SqlServerRepository : I{{EntityName}}Repository
    {
        public {{EntityName}}SqlServerRepository()
        {
        }

        public async Task<int> InsertAsync({{EntityName}} entity, IDbConnection connection, IDbTransaction transaction)
        {
            const string sql = @"
                INSERT INTO {{EntityName}} 
                ( 
                    // {{ColumnNames}}
                ) VALUES (
                    // {{AtColumnNames}}
                );
                SELECT CAST(SCOPE_IDENTITY() as int);
            ";
            
            return await connection.ExecuteScalarAsync<int>(sql, entity, transaction);
        }

        public async Task<int> UpdateAsync({{EntityName}} entity, IDbConnection connection, IDbTransaction transaction)
        {
            const string sql = @"
                UPDATE {{EntityName}} SET
                    // {{UpdateSetStatements}}
                WHERE Id = @Id
            ";

            return await connection.ExecuteAsync(sql, entity, transaction);
        }

        public async Task<int> DeleteAsync(int id, IDbConnection connection, IDbTransaction transaction)
        {
            const string sql = "DELETE FROM {{EntityName}} WHERE Id = @Id";
            return await connection.ExecuteAsync(sql, new { Id = id }, transaction);
        }

        public async Task<{{EntityName}}?> GetByIdAsync(int id, IDbConnection connection)
        {
            const string sql = "SELECT * FROM {{EntityName}} WHERE Id = @Id";
            return await connection.QuerySingleOrDefaultAsync<{{EntityName}}>(sql, new { Id = id });
        }

        public async Task<PagedQueryResponse<{{EntityName}}Response>> GetPagedAsync(Get{{EntityNamePlural}}PagedQuery query, IDbConnection connection)
        {
            DynamicParameters parameters = new();
            StringBuilder whereBuilder = new();

            // Start with a non-failing clause
            whereBuilder.Append(" WHERE 1=1 "); 
            
            // {{FilterConditions}}
            // Example:
            // if (!string.IsNullOrWhiteSpace(query.Name))
            // {
            //     whereBuilder.Append(" AND Name LIKE @Name ");
            //     parameters.Add("@Name", $"%{query.Name}%", DbType.AnsiString, ParameterDirection.Input, 100);
            // }

            string where = whereBuilder.ToString();
            string sql = $@"
                SELECT
                    -- Select columns for the response DTO
                    Id,
                    // {{ColumnNames}}
                FROM {{EntityName}}
                {where}
                ORDER BY Id -- Or a default sort column
                OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY
            ";
            parameters.Add("@Offset", (query.PageNumber - 1) * query.PageSize);
            parameters.Add("@PageSize", query.PageSize);

            string sqlCount = $"SELECT COUNT(*) FROM {{EntityName}} {where}";

            var totalItems = await connection.ExecuteScalarAsync<int>(sqlCount, parameters);
            var data = await connection.QueryAsync<{{EntityName}}Response>(sql, parameters);

            return new PagedQueryResponse<{{EntityName}}Response>
            {
                Data = data,
                TotalItems = totalItems,
                PageNumber = query.PageNumber,
                PageSize = query.PageSize
            };
        }
    }
}
