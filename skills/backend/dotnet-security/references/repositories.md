# Repository Patterns

Infrastructure layer for authentication persistence using Dapper and SQL Server.

## IUsuarioSqlServerRepository

```csharp
public interface IUsuarioSqlServerRepository
{
    Task<DadosAutenticacao?> ObterDadosAutenticacaoAsync(string login);
    Task<Usuario?> ObterAsync(int id);
    Task AtualizarSenhaAsync(int id, string senha);
    Task AtualizarFalhasTentativaLoginAsync(int id, int falhas, bool bloqueado);
    Task AtualizarRecuperacaoSenhaAsync(int id, string codigo);
}
```

## Implementation (UsuarioSqlServerRepository)

```csharp
public async Task<DadosAutenticacao?> ObterDadosAutenticacaoAsync(string login)
{
    const string sql = @"
        SELECT 
            U.Id, U.Login, U.Senha, U.Salt, U.Bloqueado, U.FalhasTentativaLogin, P.Nome
        FROM dbo.Usuario U
        INNER JOIN dbo.Pessoa P ON P.Id = U.Id
        WHERE U.Login = @Login
    ";

    DynamicParameters parametros = new();
    parametros.Add("@Login", login, DbType.AnsiString, ParameterDirection.Input, 11);

    DbConnection cnn = await _session.CreateConnectionAsync();
    return await cnn.QueryFirstOrDefaultAsync<DadosAutenticacao>(sql, parametros, _session.Transaction);
}

public async Task AtualizarFalhasTentativaLoginAsync(int id, int falhas, bool bloqueado)
{
    const string sql = @"
        UPDATE dbo.Usuario SET
            FalhasTentativaLogin = @Falhas,
            Bloqueado = @Bloqueado,
            DataHoraBloqueio = CASE WHEN @Bloqueado = 1 THEN GETDATE() ELSE NULL END
        WHERE Id = @Id
    ";

    DynamicParameters parametros = new();
    parametros.Add("@Id", id, DbType.Int32);
    parametros.Add("@Falhas", falhas, DbType.Int32);
    parametros.Add("@Bloqueado", bloqueado, DbType.Boolean);

    DbConnection cnn = await _session.CreateConnectionAsync();
    await cnn.ExecuteAsync(sql, parametros, _session.Transaction);
}
```

## IUsuarioMfaRepository

```csharp
public interface IUsuarioMfaRepository
{
    Task<UsuarioMfa?> ObterAsync(int usuarioId);
    Task SalvarAsync(UsuarioMfa usuarioMfa);
    Task ExcluirAsync(int usuarioId);
    Task IncrementarTentativasAsync(int usuarioId);
}
```

## Implementation (UsuarioMfaSqlServerRepository - Merge)

```csharp
public async Task SalvarAsync(UsuarioMfa usuarioMfa)
{
    const string sql = @"
        MERGE INTO dbo.UsuarioMfa WITH (HOLDLOCK) AS target
        USING (SELECT @UsuarioId AS UsuarioId, @Codigo AS Codigo, @DataExpiracao AS DataExpiracao...) AS source
        ON target.UsuarioId = source.UsuarioId
        WHEN MATCHED THEN
            UPDATE SET Codigo = source.Codigo, DataExpiracao = source.DataExpiracao...
        WHEN NOT MATCHED THEN
            INSERT (UsuarioId, Codigo, DataExpiracao...)
            VALUES (source.UsuarioId, source.Codigo, source.DataExpiracao...);
    ";
    // ... parameters mapping
}
```
