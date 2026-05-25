using [ProjectName].Domain.Commands.{{ContextName}};
using FluentValidation;

namespace [ProjectName].Domain.CommandValidations.{{ContextName}};

public class Create{{EntityName}}CommandValidator : AbstractValidator<Create{{EntityName}}Command>
{
    public Create{{EntityName}}CommandValidator()
    {
        {{ValidationRules}}
    }
}
