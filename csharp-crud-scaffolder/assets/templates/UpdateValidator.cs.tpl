using FluentValidation;

namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Update{{EntityName}}
{
    public class Update{{EntityName}}CommandValidator : AbstractValidator<Update{{EntityName}}Command>
    {
        public Update{{EntityName}}CommandValidator()
        {
            RuleFor(x => x.Id).NotEmpty();
            // {{ValidationRules}}
        }
    }
}
