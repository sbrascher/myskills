using FluentValidation;

namespace SeuProjeto.Application.Features.{{EntityNamePlural}}.Commands.Delete{{EntityName}}
{
    public class Delete{{EntityName}}CommandValidator : AbstractValidator<Delete{{EntityName}}Command>
    {
        public Delete{{EntityName}}CommandValidator()
        {
            RuleFor(x => x.Id).NotEmpty().WithMessage("Id is required.");
        }
    }
}
