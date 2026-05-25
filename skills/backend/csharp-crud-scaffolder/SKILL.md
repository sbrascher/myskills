---
name: csharp-crud-scaffolder
description: Scaffolds a complete, robust CRUD endpoint for a C# ASP.NET Core application (C# 12+). Follows Clean Architecture, CQRS (Hybrid), and uses Dapper for data access. Generates subfolder-organized handlers, validators, and repositories.
---

# C#/.NET CRUD Scaffolder Skill

Esta skill automatiza a criação de um endpoint CRUD completo. Ela segue rigorosamente a arquitetura de **Contextos (Subpastas)**, CQRS Híbrido, Dapper, Unit of Work e FluentValidation.

## Regras Críticas

1.  **Sem `SELECT *`:** É TERMINANTEMENTE PROIBIDO o uso de `SELECT *` em qualquer template SQL. Todos os campos devem ser listados literalmente (ex: `SELECT Id, Nome, Data FROM ...`).
2.  **Organização por Contexto:** Commands, Handlers e Validations devem ser gerados em subpastas nomeadas pelo contexto (ex: `src/Domain/Commands/Usuarios/`).
3.  **C# 12+ Style:** Siga o `gemini.md` (Explicit Typing, Allman Style, Collection Expressions `[]`, Target-typed new `new()`).

## Workflow

### Passo 1: Coletar Requisitos

1.  **Nome do Projeto:** Prefixo do namespace (ex: `Cadernos`).
2.  **Nome da Entidade:** PascalCase (ex: `Area`).
3.  **Contexto/Subpasta:** Nome da pasta de agrupamento (ex: `Areas`, `Usuarios`, `Itens`).
4.  **Propriedades:** Lista de campos (Tipo, Nome, Nullability).

### Passo 2: Derivar Variáveis

*   `{{ContextName}}`: Nome do contexto (ex: `Areas`).
*   `{{EntityName}}`: Nome da entidade (ex: `Area`).
*   `{{LiteralFields}}`: Lista separada por vírgula de todos os campos da tabela para SQL.

### Passo 3: Plano de Geração de Arquivos

Gere os arquivos nos seguintes caminhos (substituindo `[ProjectName]` pelo nome real):

1.  **Entidade:** `[ProjectName].Domain/Models/{{EntityName}}.cs`
2.  **Interface Repositório:** `[ProjectName].Domain/Interfaces/Repositories/I{{EntityName}}Repository.cs`
3.  **Requests:** `[ProjectName].Domain/Models/Requests/{{EntityName}}Requests.cs` (ou arquivos individuais se preferir)
4.  **Responses:** `[ProjectName].Domain/Models/Responses/{{EntityName}}Response.cs`
5.  **Commands:** `[ProjectName].Domain/Commands/{{ContextName}}/{{Action}}{{EntityName}}Command.cs`
6.  **Handlers:** `[ProjectName].Domain/CommandHandlers/{{ContextName}}/{{Action}}{{EntityName}}CommandHandler.cs`
7.  **Validations:** `[ProjectName].Domain/CommandValidations/{{ContextName}}/{{Action}}{{EntityName}}CommandValidator.cs`
8.  **Repositório Infra:** `[ProjectName].Infra/Data/Repositories/{{EntityName}}Repository.cs`
9.  **Controller:** `[ProjectName].Api/Controllers/{{EntityNamePlural}}Controller.cs`

### Passo 4: SQL Literales

Ao gerar o Repositório, use a variável `{{LiteralFields}}` para:
- `SELECT {{LiteralFields}} FROM ...`
- `INSERT INTO ... ({{LiteralFields}}) VALUES (@Field1, @Field2...)`
