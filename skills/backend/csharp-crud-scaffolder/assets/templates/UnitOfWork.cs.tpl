public interface IUnitOfWork : IDisposable
{
    System.Data.IDbConnection Connection { get; }
    System.Data.IDbTransaction? Transaction { get; }
    void BeginTransaction();
    void Commit();
    void Rollback();
}

public sealed class DbSession : IDisposable
{
    public System.Data.IDbConnection Connection { get; }
    public System.Data.IDbTransaction? Transaction { get; set; }

    public DbSession(Microsoft.Extensions.Options.IOptions<SqlServerConfiguration> options)
    {
        Connection = new Microsoft.Data.SqlClient.SqlConnection(options.Value.ConnectionString);
        Connection.Open();
    }

    public void Dispose()
    {
        Connection?.Dispose();
    }
}

public sealed class UnitOfWork : IUnitOfWork
{
    private readonly DbSession _session;

    public UnitOfWork(DbSession session)
    {
        _session = session;
    }

    public System.Data.IDbConnection Connection => _session.Connection;
    public System.Data.IDbTransaction? Transaction => _session.Transaction;

    public void BeginTransaction()
    {
        _session.Transaction = _session.Connection.BeginTransaction();
    }

    public void Commit()
    {
        _session.Transaction?.Commit();
        Dispose();
    }

    public void Rollback()
    {
        _session.Transaction?.Rollback();
        Dispose();
    }

    public void Dispose()
    {
        _session.Transaction?.Dispose();
    }
}