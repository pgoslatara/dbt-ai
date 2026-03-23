Analyze the dbt model `$ARGUMENTS` and suggest missing tests.

1. Read the model's SQL file to understand columns and logic.
2. Read the model's existing YAML tests.
3. For each column, analyze its semantics (name, type, computation) and suggest appropriate tests that are NOT already present:
   - `not_null` for columns that should never be null.
   - `unique` for natural or surrogate keys.
   - `accepted_values` for enum-like columns (e.g., city, status).
   - `relationships` for foreign keys referencing other models.
   - `dbt_expectations.expect_column_values_to_be_between` for numeric columns with logical bounds.
4. Present suggestions as a prioritized list with rationale for each.
5. Do NOT apply the suggestions — just list them. The user can run `/add-tests $ARGUMENTS` to apply.
