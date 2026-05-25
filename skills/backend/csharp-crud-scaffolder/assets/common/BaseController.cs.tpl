using [ProjectName].Domain.Interfaces.Services;
using [ProjectName].Tools.Notifications;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace [ProjectName].Api.Controllers;

[Authorize]
[Route("[controller]")]
[ProducesResponseType(200)]
[ProducesResponseType(202)]
[ProducesResponseType(400)]
[ProducesResponseType(401)]
[ProducesResponseType(423)]
[ProducesResponseType(500)]
public abstract class ApiControllerBase : ControllerBase
{
    protected readonly DomainNotificationContext _domainNotificationContext;
    protected readonly IContextService _contextService;
    protected readonly ILogger _logger;

    protected ApiControllerBase(
        DomainNotificationContext domainNotificationContext,
        IContextService contextService,
        ILoggerFactory loggerFactory)
    {
        _domainNotificationContext = domainNotificationContext;
        _contextService = contextService;
        _logger = loggerFactory.CreateLogger<ApiControllerBase>();
    }

    protected new IActionResult Response(object? result = null, int? statusCode = null)
    {
        if (IsValidOperation())
        {
            if (statusCode != null)
            {
                return StatusCode(statusCode.Value, new
                {
                    success = true,
                    data = result
                });
            }

            return Ok(new
            {
                success = true,
                data = result
            });
        }

        statusCode = _domainNotificationContext.GetStatusCode();

        if (result != null)
        {
            return StatusCode(statusCode.Value, new
            {
                success = false,
                data = result,
                errors = _domainNotificationContext.GetMessages()
            });
        }

        return StatusCode(statusCode.Value, new
        {
            success = false,
            errors = _domainNotificationContext.GetMessages()
        });
    }

    private bool IsValidOperation()
    {
        return !_domainNotificationContext.HasNotifications();
    }
}
