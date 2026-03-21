# dbt-ai

## Project Overview

Bike-share analytics dbt project using two public BigQuery datasets (NYC Citi Bike and Austin Bikeshare). Demonstrates AI-powered dbt workflows for the Amsterdam dbt Meetup.

## Naming Conventions

- Staging models: `stg_<source>__<entity>.sql`
- Intermediate models: `int_<entity>.sql`
- Dimension tables: `dim_<entity>.sql`
- Fact tables: `fct_<entity>.sql`
- Source YAML: `_<source>__sources.yml`
- Model YAML: `_<layer>__models.yml` or `_<source>__models.yml`

## SQL Style

- Uppercase SQL keywords: `SELECT`, `FROM`, `WHERE`, `JOIN`, `GROUP BY`, etc.
- Lowercase for column and table names using `snake_case`
- One column per line in `SELECT` statements
- Always alias tables in joins
- Use CTEs over nested subqueries
- CTE pattern: `source` → `renamed` → `SELECT` for staging models

## Materializations

- Staging: `view`
- Intermediate: `view`
- Marts: `table` (use `incremental` with `merge` strategy where appropriate)

## Testing & Documentation

- Every model must have a YAML file with descriptions
- Every model must have at least one test
- Use `dbt_expectations` for range and pattern checks
- Use `dbt_utils` for generic utility macros
- Use dbt unit tests for computed column logic (e.g., `is_round_trip`, `is_weekend`)
- Define exposures in `models/marts/_marts__exposures.yml` for downstream consumers

## Development Commands

```bash
make setup      # Install deps, dbt packages, prek hooks
make run        # dbt build
make test       # dbt test + pytest
make lint       # Run all pre-commit hooks
make format     # Format SQL, Python, YAML
make freshness  # Check source freshness
make docs       # Generate and serve dbt docs
make clean      # Remove build artifacts
make slides     # Build presentation HTML
```

## Custom Slash Commands

| Command | Description |
|---------|-------------|
| `/add-tests <model>` | Add comprehensive tests to a model |
| `/document-model <model>` | Add documentation to a model |
| `/explain-model <model>` | Explain a model's purpose, lineage, and data quality |
| `/generate-exposure <description>` | Generate an exposure from a plain-English description |
| `/generate-staging-model <source.table>` | Generate a staging model from a source |
| `/generate-unit-tests <model>` | Generate dbt unit tests for computed columns |
| `/impact-analysis <model>` | Analyze downstream impact of changing a model |
| `/review-sql` | Review SQL for BigQuery performance anti-patterns |
| `/suggest-tests <model>` | Suggest missing tests for a model |

## GCP Interaction

All GCP interaction uses `gcloud` CLI. The project ID is configured via the `GCP_PROJECT` environment variable.

## BigQuery Sources

- `bigquery-public-data.austin_bikeshare` — Austin B-cycle bikeshare
- `bigquery-public-data.new_york_citibike` — NYC Citi Bike

## Architecture

```
models/
├── staging/          # Source-specific cleaning and renaming (views)
│   ├── austin_bikeshare/
│   └── new_york_citibike/
├── intermediate/     # Cross-source unions and aggregations (views)
└── marts/            # Business-ready dimensions and facts (tables)
```
