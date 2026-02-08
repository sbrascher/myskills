using Microsoft.AspNetCore.Mvc;
using SeuProjeto.Application.Common; // Assuming DomainNotificationContext is here

namespace SeuProjeto.Api.Common
{
    [ApiController]
    public abstract class BaseController : ControllerBase
    {
        private readonly DomainNotificationContext _domainNotificationContext;

        protected BaseController(DomainNotificationContext domainNotificationContext)
        {
            _domainNotificationContext = domainNotificationContext;
        }

        protected IActionResult Response(object? result = null)
        {
            if (_domainNotificationContext.HasNotifications)
            {
                // You can customize this to return specific error details
                return BadRequest(new
                {
                    errors = _domainNotificationContext.Notifications.Select(n => n.Value)
                });
            }

            if (result == null)
            {
                return NoContent();
            }

            // You can differentiate between POST (201 Created) and PUT/GET (200 OK)
            // For simplicity, we'll use Ok for now.
            return Ok(result);
        }
    }
}
