using Microsoft.AspNetCore.Mvc;
using SeuProjeto.Api.Common;
using SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Create{{EntityName}};
using SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Update{{EntityName}};
using SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Delete{{EntityName}};
using SeuProjeto.Application.Features.{{EntityNamePlural}}.Queries.Get{{EntityName}}ById;
using SeuProjeto.Application.Features.{{EntityNamePlural}}.Queries.Get{{EntityNamePlural}}Paged;
using System.Threading.Tasks;

namespace SeuProjeto.Api.Controllers
{
    [Route("api/{{EntityNamePluralLowerCase}}")]
    public class {{EntityNamePlural}}Controller : BaseController
    {
        public {{EntityNamePlural}}Controller(DomainNotificationContext domainNotificationContext) : base(domainNotificationContext)
        {
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetByIdAsync(
            [FromServices] Get{{EntityName}}ByIdQueryHandler handler,
            [FromRoute] int id)
        {
            Get{{EntityName}}ByIdQuery query = new() { Id = id };
            var response = await handler.ExecuteAsync(query);
            return Response(response);
        }

        [HttpGet]
        public async Task<IActionResult> GetPagedAsync(
            [FromServices] Get{{EntityNamePlural}}PagedQueryHandler handler,
            [FromQuery] Get{{EntityNamePlural}}PagedQuery query)
        {
            var response = await handler.ExecuteAsync(query);
            return Response(response);
        }

        [HttpPost]
        public async Task<IActionResult> InsertAsync(
            [FromServices] Create{{EntityName}}CommandHandler commandHandler,
            [FromBody] Create{{EntityName}}Request request)
        {
            // Note: The command can be created here or inside the handler.
            // Creating it here makes the controller's responsibility clearer.
            Create{{EntityName}}Command command = new()
            {
                // {{MapRequestToCommandProperties}}
            };

            var response = await commandHandler.ExecuteAsync(command);
            // This could return a CreatedAtRoute (201) for POST requests
            return Response(response);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateAsync(
            [FromServices] Update{{EntityName}}CommandHandler commandHandler,
            [FromRoute] int id,
            [FromBody] Update{{EntityName}}Request request)
        {
            Update{{EntityName}}Command command = new()
            {
                Id = id,
                // {{MapRequestToCommandProperties}}
            };
            
            await commandHandler.ExecuteAsync(command);
            return Response();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(
            [FromServices] Delete{{EntityName}}CommandHandler commandHandler,
            [FromRoute] int id)
        {
            Delete{{EntityName}}Command command = new() { Id = id };
            await commandHandler.ExecuteAsync(command);
            return Response();
        }
    }
}
