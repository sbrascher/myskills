---
name: csharp-crud-scaffolder
description: Scaffolds a complete, robust CRUD endpoint for a C# ASP.NET Core application. Follows Clean Architecture, CQRS, and uses Dapper for data access. Use this skill to generate controllers, command/query handlers, validators, repositories, and DTOs for a new entity.
---

# C#/.NET CRUD Scaffolder Skill

This skill automates the creation of a full CRUD (Create, Read, Update, Delete) endpoint for a new entity in a C#/.NET application. It adheres to Clean Architecture principles and the patterns previously discussed (CQRS, Dapper, Unit of Work, FluentValidation).

## Workflow

Follow these steps precisely to generate the code.

### Step 1: Gather Entity Requirements

1.  **Confirm Entity Name:** Ask the user for the name of the entity in PascalCase (e.g., `Product`, `CustomerOrder`).
2.  **Confirm Properties:** Ask the user for a list of properties for the entity. Each property must include:
    *   **C# Type:** (e.g., `string`, `int`, `decimal`, `DateTime`, `bool`).
    *   **Name:** (in PascalCase, e.g., `Name`, `Description`, `Price`).
    *   **Nullability:** Indicate if the type is nullable (e.g., `string?`, `int?`).
    *   **Validation Rules (Optional):** Ask for basic validation rules like `required`, `maxLength`, `pattern`.

    **Example User Input:**
    "I want to create a `Product` entity with these properties:
    - `string Name` (required, max 100)
    - `string? Description` (max 500)
    - `decimal Price` (required)
    - `int Stock` (required)"

### Step 2: Derive Variables

From the entity name, derive the following variations to be used as placeholders:

*   `{{EntityName}}`: The original name (e.g., `Product`).
*   `{{EntityNamePlural}}`: The plural version (e.g., `Products`).
*   `{{EntityNameLowerCase}}`: The camelCase version (e.g., `product`).
*   `{{EntityNamePluralLowerCase}}`: The plural camelCase or all-lowercase version for routes (e.g., `products`).

### Step 3: Generate Code from Templates

For each file to be generated, you will load the corresponding template from the `assets/` directory, process the placeholders, and generate the final code.

**Placeholder Replacement Logic:**

*   **Simple Placeholders:** Replace `{{EntityName}}`, `{{EntityNamePlural}}`, etc., with the derived variables.
*   **`{{Properties}}`:** Iterate through the user-defined property list. For each property, generate a line: `public {{Type}} {{Name}} { get; set; }`.
*   **`{{ValidationRules}}`:** Iterate through properties. Generate `FluentValidation` rules.
    *   If `required` and `string`: `RuleFor(x => x.{{Name}}).NotEmpty().WithMessage("{{Name}} is required.");`
    *   If `maxLength`: `RuleFor(x => x.{{Name}}).MaximumLength({{length}}).WithMessage("{{Name}} cannot exceed {{length}} characters.");`
    *   If `required` and not `string`: `RuleFor(x => x.{{Name}}).NotEmpty().WithMessage("{{Name}} is required.");`
*   **`{{ColumnNames}}` (for SQL INSERT):** Generate a comma-separated list of property names (e.g., `Name, Description, Price, Stock`).
*   **`{{AtColumnNames}}` (for SQL INSERT VALUES):** Generate a comma-separated list of `@` prefixed property names (e.g., `@Name, @Description, @Price, @Stock`).
*   **`{{UpdateSetStatements}}` (for SQL UPDATE):** Generate a comma-separated list of `Column = @Column` statements (e.g., `Name = @Name, Description = @Description, Price = @Price`).
*   **`{{MapRequestToCommandProperties}}`:** Generate property assignments from a `request` object to a `command` object.
*   **`{{MapCommandToEntityProperties}}`:** Generate property assignments from a `command` object to an `entity` object.
*   **`{{MapEntityToResponseProperties}}`:** Generate property assignments from an `entity` object to a `response` object.
*   **`{{FilterConditions}}` (for Paged Query):** Generate `if` statements for filtering based on query parameters. This might require asking the user which properties are filterable. For a v1, you can leave this blank or add a simple example.

### Step 4: Write Generated Files

Using the project structure defined in our plan, construct the full file path for each generated file and use the `write_file` tool to save the content.

**File Generation Plan:**

1.  **Entity:**
    *   Template: `assets/templates/Entity.cs.tpl`
    *   Output: `src/SeuProjeto.Domain/Entities/{{EntityName}}.cs`
2.  **Repository Interface:**
    *   Template: `assets/templates/RepositoryInterface.cs.tpl`
    *   Output: `src/SeuProjeto.Domain/Interfaces/Repositories/I{{EntityName}}Repository.cs`
3.  **Create Command DTOs:**
    *   Template: `assets/templates/CreateRequest.cs.tpl`
    *   Output: `src/SeuProjeto.Domain/Requests/Create{{EntityName}}Request.cs`
    *   Template: `assets/templates/CreateCommand.cs.tpl`
    *   Output: `src/SeuProjeto.Domain/Commands/Create{{EntityName}}Command.cs`
4.  **Create Command Validator:**
    *   Template: `assets/templates/CreateValidator.cs.tpl`
    *   Output: `src/SeuProjeto.Domain/Validators/Create{{EntityName}}CommandValidator.cs`
5.  **Create Command Handler:**
    *   Template: `assets/templates/CreateCommandHandler.cs.tpl`
    *   Output: `src/SeuProjeto.Domain/CommandHandlers/Create{{EntityName}}CommandHandler.cs`
6.  **Update DTOs, Command, Validator, Handler:** (Repeat for `Update` templates)
7.  **Delete Command, Validator, Handler:** (Repeat for `Delete` templates)
8.  **GetById Query, Handler, Response:** (Repeat for `GetById` and `Response` templates)
9.  **GetPaged Query, Handler:** (Repeat for `GetPaged` templates)
10. **Repository Implementation:**
    *   Template: `assets/templates/Repository.cs.tpl`
    *   Output: `src/SeuProjeto.Infrastructure/Repositories/{{EntityName}}SqlServerRepository.cs`
11. **Controller:**
    *   Template: `assets/templates/Controller.cs.tpl`
    *   Output: `src/SeuProjeto.Api/Controllers/{{EntityNamePlural}}Controller.cs`
12. **Common Files (Copy if they don't exist):**
    *   Copy files from `assets/common` to appropriate locations if they are not already present in the user's project.

### Step 5: Final Instructions for User

After generating all files, inform the user of the final manual step:

"The CRUD endpoint for `{{EntityName}}` has been generated. The final step is to register the new services in your Dependency Injection container (e.g., in `Program.cs` or `Startup.cs`). Please add the following lines:

```csharp
// For {{EntityName}}
services.AddScoped<I{{EntityName}}Repository, {{EntityName}}SqlServerRepository>();
services.AddScoped<Create{{EntityName}}CommandHandler>();
services.AddScoped<Update{{EntityName}}CommandHandler>();
services.AddScoped<Delete{{EntityName}}CommandHandler>();
services.AddScoped<Get{{EntityName}}ByIdQueryHandler>();
services.AddScoped<Get{{EntityNamePlural}}PagedQueryHandler>();
```
"