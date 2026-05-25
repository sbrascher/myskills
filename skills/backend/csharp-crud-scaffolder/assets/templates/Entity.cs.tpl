namespace [ProjectName].Domain.Models;

public class {{EntityName}}
{
    public {{EntityName}}({{ConstructorParams}})
    {
        {{ConstructorAssignments}}
    }

    public int Id { get; set; }
    {{Properties}}
    public int UsuarioCriacaoId { get; set; }
    public int? UsuarioAlteracaoId { get; set; }
}
