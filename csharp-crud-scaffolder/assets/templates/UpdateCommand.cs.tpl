namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Update{{EntityName}}
{
    public class Update{{EntityName}}Command
    {
        public int Id { get; set; }
        // {{Properties}}
        
        // Audit fields
        public int LastChangeUserId { get; set; }
        public int GroupId { get; set; }
    }
}
