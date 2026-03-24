Generate a new dbt model `$ARGUMENTS` based on a description.

1. Ensure the dbt project is compiled so the manifest is up-to-date (`uv run dbt parse` or `uv run dbt compile`).
2. Read the `target/manifest.json` file. This is the ultimate source of truth for the project.
3. Validate your proposed model against the manifest. Do NOT hallucinate tables or columns. If the user asks you to join to a table, verify that the table and required columns exist in the manifest.
4. Review the `CLAUDE.md` conventions for naming and materialization rules.
5. Create the `.sql` file in the appropriate directory (`models/marts` or `models/intermediate`).
6. Create or update the corresponding `_<layer>__models.yml` file to include descriptions and tests.
7. Only use `ref()` and `source()` calls for existing models/sources found in the manifest.
8. If the user asks for a column that does not exist in the manifest, inform them that the data is not available and stop. Do not generate fake logic.
