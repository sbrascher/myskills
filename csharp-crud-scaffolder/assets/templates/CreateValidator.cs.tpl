using FluentValidation;

namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Create{{EntityName}}
{
    public class Create{{EntityName}}CommandValidator : AbstractValidator<Create{{EntityName}}Command>
    {
        public Create{{EntityName}}CommandValidator()
        {
            // {{ValidationRules}}
        }
    }
}
