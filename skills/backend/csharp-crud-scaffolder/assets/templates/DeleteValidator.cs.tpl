using [ProjectName].Domain.Commands.{{ContextName}};
using FluentValidation;

namespace [ProjectName].Domain.CommandValidations.{{ContextName}};

public class Delete{{EntityName}}CommandValidator : AbstractValidator<Delete{{EntityName}}Command>
{
    public Delete{{EntityName}}CommandValidator()
    {
        RuleFor(x => x.Id)
            .GreaterThan(0)
            .WithMessage("Id é obrigatório e deve ser maior que zero.");
    }
}
