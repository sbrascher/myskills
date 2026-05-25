namespace [ProjectName].Domain.Commands.{{ContextName}};

public class Update{{EntityName}}Command
{
    public int Id { get; set; }
    {{Properties}}
    public int UsuarioAlteracaoId { get; set; }
}
