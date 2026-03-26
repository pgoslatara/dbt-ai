---
name: dbt-explain-model
description: Explain a dbt model in plain English — its purpose, lineage, transformations, and data quality guarantees. Use when asked to explain, describe, summarise, or walk through a dbt model.
---

# dbt-explain-model

Explain the dbt model `$ARGUMENTS` in plain English.

1. Read the model's SQL file and understand its transformations.
2. Read the model's YAML file for descriptions and tests.
3. Identify all upstream dependencies by finding `ref()` and `source()` calls in the SQL.
4. Identify all downstream dependents by searching the codebase for `ref('$ARGUMENTS')`.
5. Produce a clear summary covering:
   - **Purpose**: What this model does and its business value.
   - **Lineage**: What models/sources feed into it, and what models consume it.
   - **Key transformations**: Computed columns, joins, aggregations, filters.
   - **Data quality**: What tests protect this model and what guarantees they provide.
   - **Materialisation**: How it's materialised and why.
6. Keep the explanation concise — aim for someone unfamiliar with the project to understand it in 30 seconds.
