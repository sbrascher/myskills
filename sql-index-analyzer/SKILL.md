---
name: sql-index-analyzer
description: Analyzes C# repository files containing SQL Server queries and suggests optimal database indexes to improve performance. Use this skill when you want to optimize database queries in a C# project.
---

# SQL Index Analyzer

This skill guides the analysis of a C# project to find SQL Server queries and recommend performance-enhancing database indexes.

## Workflow

Follow these steps to generate the index suggestions.

### 1. Locate Repository Files

The primary location for data access logic is in files that follow the repository pattern.

- Use the `glob` tool to find all repository files in the target project.
- The recommended pattern is `**/*Repository.cs`.

```bash
glob pattern="**/*Repository.cs"
```

### 2. Extract SQL Queries from Each File

For each repository file found, you need to extract the raw SQL query strings. These are typically stored in C# verbatim string literals (`@"..."`).

- Use `read_file` to get the content of each repository file.
- Analyze the content to identify and extract all string variables or literals that contain SQL statements (look for keywords like `SELECT`, `UPDATE`, `INSERT`, `DELETE` within `@"` blocks).
- For each query found, keep a record of its source file path to provide better context in the final report.

### 3. Analyze Each SQL Query

This is the core analysis step. For each extracted query, perform the following analysis based on SQL performance best practices.

1.  **Identify the target table(s):** Find the table name from the `FROM` or `JOIN` clauses.
2.  **Identify filter columns:** List all columns used in `WHERE` clauses.
3.  **Identify join columns:** List all columns used in `JOIN ... ON` conditions. These are critical for index suggestions.
4.  **Identify sort columns:** List all columns used in `ORDER BY` clauses. The order of columns is important.
5.  **Identify grouping columns:** List all columns used in `GROUP BY` clauses.

### 4. Generate Index Suggestions

Based on the columns identified in the previous step, generate `CREATE INDEX` statements.

- **Rule for `WHERE` and `JOIN` columns:** These are high-priority candidates for single-column indexes.
  - **Example:** A query with `WHERE CustomerId = @Id` should lead to:
    `CREATE INDEX IX_TableName_CustomerId ON dbo.TableName (CustomerId);`

- **Rule for `ORDER BY` and `GROUP BY` columns:** These columns are also strong candidates for indexes to avoid costly sorting and grouping operations.
  - **Example:** A query with `ORDER BY OrderDate DESC` should lead to:
    `CREATE INDEX IX_TableName_OrderDate ON dbo.TableName (OrderDate);`

- **Rule for Composite Indexes:** If a query frequently filters by one column and sorts by another, a composite index is often best. The order matters: place the equality filter column(s) before the range/sort column(s).
  - **Example:** `WHERE Status = @Status ORDER BY CreateDate DESC`
  - **Suggestion:** `CREATE INDEX IX_TableName_Status_CreateDate ON dbo.TableName (Status, CreateDate);`

- **Consolidate and Refine:** Review all suggestions for a single table. Avoid creating redundant indexes. For example, if you have an index on `(ColumnA, ColumnB)`, you do not need a separate index on `(ColumnA)`.

### 5. Present the Final Report

Format the output as a clear, actionable Markdown report.

- Group the suggested indexes by the database table they apply to.
- For each suggestion, provide the full `CREATE INDEX` T-SQL statement.
- Add a brief, clear explanation of *why* the index is being recommended, referencing the file and the part of the query (`WHERE`, `ORDER BY`, etc.) that will benefit.

**Example Report Structure:**

```markdown
# SQL Index Analysis Report

Here are the suggested indexes to improve query performance.

## Table: `dbo.Orders`

### Suggested Indexes:

1.  **`CREATE INDEX IX_Orders_CustomerId ON dbo.Orders (CustomerId);`**
    *   **Reason:** Recommended for the `WHERE` clause in the `GetOrdersForCustomer` query found in `OrderRepository.cs`.

2.  **`CREATE INDEX IX_Orders_Status_OrderDate ON dbo.Orders (Status, OrderDate);`**
    *   **Reason:** Recommended for the `WHERE` and `ORDER BY` clauses in the `GetPendingOrdersSorted` query found in `OrderRepository.cs`.

---
```