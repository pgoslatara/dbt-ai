Generate a staging model for the source `$ARGUMENTS`.

The argument should be in the format `<source_name>.<table_name>` (e.g., `austin_bikeshare.bikeshare_stations`).

1. Look up the source table schema in BigQuery or the source YAML.
2. Create the staging SQL file following the CTE pattern:
   - `source` CTE: `SELECT * FROM {{ source('<source_name>', '<table_name>') }}`
   - `renamed` CTE: rename columns to snake_case, cast types, add `city` column
   - Final `SELECT * FROM renamed`
3. Create or update the source YAML file (`_<source>__sources.yml`) with the table definition.
4. Create or update the model YAML file (`_<source>__models.yml`) with column descriptions and tests.
5. Place files in `models/staging/<source_name>/`.
6. Follow all naming conventions from CLAUDE.md.
