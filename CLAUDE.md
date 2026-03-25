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

## Skills

Skills encode *how Claude thinks* about a class of problem — multi-step analytical protocols reusable across projects. Lives in `~/.claude/skills/`.

**Use a skill when:** the task is a multi-step analytical or behavioral protocol that should be reusable across projects and can be triggered naturally or via slash command.

| Skill | Description |
|-------|-------------|
| `dbt-explain-model` | Explain a model's purpose, lineage, transformations, and data quality |
| `dbt-impact-analysis` | Analyze downstream dependencies and risk-assess a model change |
| `dbt-review-sql` | Review SQL for BigQuery performance anti-patterns |
| `dbt-suggest-tests` | Suggest missing tests for a model |

## Custom Slash Commands

Slash commands are user-initiated shortcuts that generate or modify artifacts. Lives in `.claude/commands/`.

**Use a slash command when:** the task is user-initiated, needs an explicit argument, and follows a predictable, templated output pattern.

| Command | Description |
|---------|-------------|
| `/add-tests <model>` | Add comprehensive tests to a model |
| `/document-model <model>` | Add documentation to a model |
| `/explain-model <model>` | Explain a model (invokes `dbt-explain-model` skill) |
| `/generate-exposure <description>` | Generate an exposure from a plain-English description |
| `/generate-staging-model <source.table>` | Generate a staging model from a source |
| `/generate-unit-tests <model>` | Generate dbt unit tests for computed columns |
| `/generate-verified-model <model>` | Generate a manifest-validated model from a description |
| `/impact-analysis <model>` | Analyze downstream impact (invokes `dbt-impact-analysis` skill) |
| `/review-sql` | Review SQL for BigQuery performance (invokes `dbt-review-sql` skill) |
| `/suggest-tests <model>` | Suggest missing tests (invokes `dbt-suggest-tests` skill) |

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
