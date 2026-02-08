namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Create{{EntityName}}
{
    public class Create{{EntityName}}Command
    {
        // {{Properties}}
        
        // Audit fields can be added here by the handler
        public int CreationUserId { get; set; }
        public int GroupId { get; set; }
    }
}
