Add comprehensive tests to the dbt model `$ARGUMENTS`.

1. Read the model's SQL file and understand its columns and logic.
2. Read the model's existing YAML file (if any).
3. Add or update the YAML with tests for each column:
   - `not_null` for required columns
   - `unique` for primary keys
   - `accepted_values` for enum-like columns
   - `relationships` for foreign keys
   - `dbt_expectations` range checks for numeric columns
4. Follow the project's YAML naming convention: `_<source>__models.yml` for staging, `_<layer>__models.yml` for intermediate/marts.
5. Ensure tests are alphabetically ordered within each column.
