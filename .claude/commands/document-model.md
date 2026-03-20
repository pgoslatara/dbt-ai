Add documentation to the dbt model `$ARGUMENTS`.

1. Read the model's SQL file and understand its purpose, columns, and business logic.
2. Read the model's existing YAML file (if any).
3. Add or update the YAML with:
   - A clear model-level description explaining what the model represents and its business purpose.
   - Column-level descriptions for every column in the final SELECT.
4. Follow the project's YAML naming convention: `_<source>__models.yml` for staging, `_<layer>__models.yml` for intermediate/marts.
5. Descriptions should be concise but informative — explain the "what" and "why", not the "how".
