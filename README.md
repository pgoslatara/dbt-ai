# dbt-ai

AI-powered dbt project for bike-share analytics, built as a live demo for the [Amsterdam dbt Meetup](https://www.meetup.com/amsterdam-dbt-meetup/) (2026-03-26).

## Overview

This project demonstrates how to integrate AI into every stage of the dbt development lifecycle — from code generation and testing to PR review and automated codebase maintenance.

It uses two public BigQuery datasets (NYC Citi Bike and Austin Bikeshare) to build a staging → intermediate → marts analytics pipeline, with AI features layered on top.

## Architecture

```
models/
├── staging/              # Source-specific cleaning and renaming (views)
│   ├── austin_bikeshare/ #   Austin B-cycle bikeshare
│   └── new_york_citibike/#   NYC Citi Bike
├── intermediate/         # Cross-source unions and aggregations (views)
│   ├── int_stations_unioned.sql
│   ├── int_trip_metrics_by_station.sql
│   └── int_trips_unioned.sql
└── marts/                # Business-ready dimensions and facts (tables)
    ├── dim_stations.sql
    ├── fct_daily_station_metrics.sql  (incremental)
    └── fct_trips.sql
```

## AI Features

### CLAUDE.md — Teaching AI Your Conventions

The [`CLAUDE.md`](CLAUDE.md) file contains project-specific instructions that Claude follows when working with this codebase: naming conventions, SQL style rules, materialization patterns, and testing requirements.

### dbt-agent-skills

Purpose-built AI skills from the [dbt-agent-skills](https://github.com/dbt-labs/dbt-agent-skills) plugin, providing dbt-specific Claude Code capabilities.

### Custom Slash Commands

| Command | Description |
|---------|-------------|
| `/add-tests <model>` | Add comprehensive tests to a model |
| `/document-model <model>` | Add documentation to a model |
| `/generate-staging-model <source.table>` | Generate a staging model from a source |

### Claude PR Review

Every PR is automatically reviewed by Claude as a senior dbt/analytics engineer, checking SQL style, naming conventions, test coverage, and business logic correctness.

### AI PR Descriptions

PRs automatically receive AI-generated descriptions that summarize changes in business-friendly language, including dbt model changes and downstream impact.

### Agentic Workflows (Weekly)

- **Abandoned Models Detection**: Compares the dbt manifest against BigQuery datasets to find orphaned tables, generates cleanup SQL, and creates a GitHub issue.
- **Codebase Review**: AI analyzes the entire codebase for dbt best practice violations and creates a categorized GitHub issue with findings.

## Getting Started

### Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- A GCP project with BigQuery enabled

### GCP Setup

Run the setup script to create and configure the GCP project:

```bash
chmod +x scripts/setup_gcp.sh
./scripts/setup_gcp.sh
```

This creates the project, enables APIs, sets up a service account with Workload Identity Federation for keyless CI/CD authentication, and prints the GitHub Secrets you need to configure.

### Installation

```bash
make setup
```

### Development

```bash
make run        # dbt build
make test       # dbt test + pytest
make lint       # Run all pre-commit hooks
make format     # Format SQL, Python, YAML
make freshness  # Check source freshness
make docs       # Generate and serve dbt docs
```

## CI/CD

| Workflow | Trigger | Description |
|----------|---------|-------------|
| CI Pipeline | PR to main | Full build, test, lint cycle with ephemeral BigQuery dataset |
| CD Pipeline | Push to main | Build Docker image, push to Artifact Registry, deploy to Cloud Run |
| Daily Pipeline | Cron (06:00 UTC) | Production `dbt build` |
| Claude PR Review | PR open/sync | AI code review |
| AI PR Description | PR open | Auto-generated PR description |
| Abandoned Models | Weekly (Monday) | Detect orphaned BigQuery tables |
| Codebase Review | Weekly (Monday) | AI best-practice audit |

## Data Sources

| Source | BigQuery Dataset | Description |
|--------|-----------------|-------------|
| Austin Bikeshare | `bigquery-public-data.austin_bikeshare` | Austin B-cycle station and trip data |
| NYC Citi Bike | `bigquery-public-data.new_york_citibike` | NYC Citi Bike station and trip data |

## Project Structure

```
.
├── .claude/commands/     # Custom Claude Code slash commands
├── .github/workflows/    # CI/CD and agentic workflows
├── models/
│   ├── staging/          # Source-specific models
│   ├── intermediate/     # Cross-source unions
│   └── marts/            # Business-ready tables
├── presentation/         # Marp slide deck
├── scripts/              # Setup and utility scripts
├── tests/                # Custom data tests
├── CLAUDE.md             # AI project instructions
├── CODEOWNERS            # Code ownership
├── dbt-bouncer.yml       # dbt validation rules
├── dbt_project.yml       # dbt project config
├── Dockerfile            # Container build
├── Makefile              # Developer workflows
├── packages.yml          # dbt packages
├── prek.toml             # Pre-commit hook config
├── profiles.yml          # BigQuery connection profiles
└── pyproject.toml        # Python project config
```
