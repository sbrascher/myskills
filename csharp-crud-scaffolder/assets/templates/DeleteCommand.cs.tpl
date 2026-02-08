namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Delete{{EntityName}}
{
    public class Delete{{EntityName}}Command
    {
        public int Id { get; set; }
        public int GroupId { get; set; } // For security validation
    }
}
