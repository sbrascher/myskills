using [ProjectName].Domain.CommandHandlers.{{ContextName}};
using [ProjectName].Domain.Commands.{{ContextName}};
using [ProjectName].Domain.Interfaces.Repositories;
using [ProjectName].Domain.Interfaces.Services;
using [ProjectName].Domain.Models.Requests;
using [ProjectName].Domain.Models.Responses;
using [ProjectName].Tools.Notifications;
using [ProjectName].Tools.Queries;
using Microsoft.AspNetCore.Mvc;

namespace [ProjectName].Api.Controllers;

[Route("api/[controller]")]
public class {{EntityNamePlural}}Controller : ApiControllerBase
{
    public {{EntityNamePlural}}Controller(
        DomainNotificationContext domainNotificationContext,
        IContextService contextService,
        ILoggerFactory loggerFactory) : base(domainNotificationContext, contextService, loggerFactory)
    {
    }

    [HttpPost]
    public async Task<IActionResult> CreateAsync(
        [FromServices] Create{{EntityName}}CommandHandler handler,
        [FromBody] Create{{EntityName}}Request request)
    {
        Create{{EntityName}}Command command = new()
        {
            {{MapRequestToCommandProperties}},
            UsuarioCriacaoId = _contextService.UsuarioId()
        };

        {{EntityName}}Response? response = await handler.ExecuteAsync(command);

        return Response(response);
    }

    [HttpPut]
    public async Task<IActionResult> UpdateAsync(
        [FromServices] Update{{EntityName}}CommandHandler handler,
        [FromBody] Update{{EntityName}}Request request)
    {
        Update{{EntityName}}Command command = new()
        {
            Id = request?.Id ?? 0,
            {{MapRequestToCommandProperties}},
            UsuarioAlteracaoId = _contextService.UsuarioId()
        };

        await handler.ExecuteAsync(command);

        return Response();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteAsync(
        [FromServices] Delete{{EntityName}}CommandHandler handler,
        [FromRoute] int id)
    {
        Delete{{EntityName}}Command command = new() { Id = id };

        await handler.ExecuteAsync(command);

        return Response();
    }

    [HttpGet]
    public async Task<IActionResult> GetPagedAsync(
        [FromServices] I{{EntityName}}Repository {{EntityNameLowerCase}}Repository,
        [FromQuery] {{FilterParams}},
        [FromQuery] PagedQuery pagedQuery)
    {
        PagedQueryResponse<{{EntityName}}Response> response = await {{EntityNameLowerCase}}Repository.GetPagedAsync({{FilterParamsUsage}}, pagedQuery);

        return Response(response);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetByIdAsync(
        [FromServices] I{{EntityName}}Repository {{EntityNameLowerCase}}Repository,
        [FromRoute] int id)
    {
        {{EntityName}}Response? response = await {{EntityNameLowerCase}}Repository.GetResponseByIdAsync(id);

        return Response(response);
    }
}
