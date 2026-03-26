# dbt-ai

AI-powered dbt project for bike-share analytics, built as a demo for my presentation at the [NL dbt meetup: 15th Edition](https://www.meetup.com/nl-nl/amsterdam-dbt-meetup/events/313554612/).

## Overview

This project demonstrates how to integrate AI into every stage of the dbt development lifecycle — from code generation and testing to PR review and automated codebase maintenance.

It uses two public BigQuery datasets (NYC Citi Bike and Austin Bikeshare) to build a staging → intermediate → marts analytics pipeline, with AI features layered on top. These datasets are available in BigQuery's public datasets project (`bigquery-public-data`).

## AI Features

### CLAUDE.md — Teaching AI Your Conventions

The [`CLAUDE.md`](CLAUDE.md) file contains project-specific instructions that Claude follows when working with this codebase: naming conventions, SQL style rules, materialisation patterns, and testing requirements.

### dbt MCP Server

The [dbt MCP server](https://github.com/dbt-labs/dbt-mcp) (`dbt-mcp`) is configured in `.claude/settings.local.json`, giving Claude direct access to dbt CLI commands, model metadata, lineage, and the semantic layer — no need to shell out to `dbt` manually.

### dbt-agent-skills

Purpose-built AI skills from the [dbt-agent-skills](https://github.com/dbt-labs/dbt-agent-skills) plugin, providing dbt-specific Claude Code capabilities.

### Skills

Multi-step analytical protocols that encode how Claude approaches a class of problem. Stored in `.claude/skills/` and invokable naturally or via slash command.

| Skill | Slash command | Description |
|-------|---------------|-------------|
| `dbt-explain-model` | `/explain-model <model>` | Explain a model's purpose, lineage, transformations, and data quality |
| `dbt-impact-analysis` | `/impact-analysis <model>` | Analyse downstream dependencies and risk-assess a model change |
| `dbt-review-sql` | `/review-sql` | Review SQL for BigQuery performance anti-patterns |
| `dbt-suggest-tests` | `/suggest-tests <model>` | Suggest missing tests for a model |

### Custom Slash Commands

User-initiated shortcuts that generate or modify artefacts. Stored in `.claude/commands/`.

| Command | Description |
|---------|-------------|
| `/add-tests <model>` | Add comprehensive tests to a model |
| `/document-model <model>` | Add documentation to a model |
| `/explain-model <model>` | Explain a model (invokes `dbt-explain-model` skill) |
| `/generate-exposure <description>` | Generate an exposure from a plain-English description |
| `/generate-staging-model <source.table>` | Generate a staging model from a source |
| `/generate-unit-tests <model>` | Generate dbt unit tests for computed columns |
| `/generate-verified-model <model>` | Generate a manifest-validated model from a description |
| `/impact-analysis <model>` | Analyse downstream dependencies and risk-assess a model change |
| `/review-sql` | Review SQL for BigQuery performance anti-patterns |
| `/suggest-tests <model>` | Suggest missing tests for a model |

### AI PR Review

Every PR is automatically reviewed by Claude as a senior dbt/analytics engineer, checking SQL style, naming conventions, test coverage, and business logic correctness.

### Agentic Workflows

**On Pull Request**

- **Fix CI Failure**: When the CI pipeline fails on a PR, Claude fetches the failed job logs, identifies the root cause (naming the specific step, model, or test), and posts a PR comment with a concrete fix suggestion and the local commands needed to verify it.
- **Auto-Document Columns**: When SQL models are added or modified in a PR, Claude parses each changed file, generates descriptions for any undocumented columns, commits the updated YAML files to the branch, and posts a comment to let the developer know.
- **Real-Time Cost Estimation**: When SQL models change in a PR, Claude compiles the project, runs a BigQuery dry-run for each changed model to retrieve bytes processed, and calculates estimated cost at $6.25/TB. If any model exceeds $1.00 per run, Claude flags it and analyses the SQL for missing partition filters, full table scans, or cross joins that could reduce cost.

**On Cloud Run Failure**

- **Fix Cloud Run Failure**: Triggered by a `repository_dispatch` webhook from Cloud Run (or manually). Claude fetches the failed execution details and logs from Cloud Logging, determines the root cause, creates a fix branch with the necessary code changes, and opens a PR summarising the failure and the fix. If the failure is an infrastructure issue rather than a code problem, it creates a GitHub issue instead.

**Scheduled (Weekly)**

- **Abandoned Models Detection**: Compares the dbt manifest against BigQuery datasets to find orphaned tables, generates cleanup SQL, and creates a GitHub issue.
- **Codebase Review**: AI analyses the entire codebase for dbt best practice violations and creates a categorised GitHub issue with findings.

### Data Quality Monitoring

A weekly GitHub Actions workflow queries production BigQuery data for statistical anomalies (trip volume spikes, duration outliers, data freshness issues) and creates a GitHub issue with AI-analysed findings.

## Presentation

[Slide deck for NL dbt meetup: 15th Edition](https://docs.google.com/presentation/d/1YsPOhB1FHJIsEAkF_QHNQZlPgoeRge5zSVh9AfenYds/edit?usp=sharing)

## Getting Started

### Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- A GCP project

### GCP Setup

Run the setup script to create and configure the GCP project:

```bash
chmod +x scripts/setup_gcp.sh
./scripts/setup_gcp.sh
```

This creates the project, enables APIs, sets up a service account with Workload Identity Federation (WIF) for keyless CI/CD authentication, and prints the GitHub Secrets you need to configure.

#### Required GitHub Secrets

Configure these under **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth token for Claude Code GitHub Actions (authenticates all AI workflows). Generate with `claude setup-token` — requires a Claude Pro or Max subscription. |
| `GCP_PROJECT_ID` | GCP project ID |
| `GCP_SERVICE_ACCOUNT` | Service account email for CI/CD |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Workload Identity Federation provider resource name |
| `PAT_GITHUB` | GitHub Personal Access Token with `repo` and `workflow` scopes, used for cross-workflow triggers and PR comments |

#### Required Dependabot Secrets

Dependabot PRs cannot access Actions secrets by default. Configure the same secrets under **Settings → Secrets and variables → Dependabot** so CI and AI PR Review run on dependency bump PRs:

| Secret | Description |
|--------|-------------|
| `CLAUDE_CODE_OAUTH_TOKEN` | Same value as the Actions secret above |
| `GCP_PROJECT_ID` | Same value as the Actions secret above |
| `GCP_SERVICE_ACCOUNT` | Same value as the Actions secret above |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Same value as the Actions secret above |
| `PAT_GITHUB` | Same value as the Actions secret above |

To set all Dependabot secrets at once (requires `gcloud` auth and `PAT_GITHUB` in your environment):

```bash
GCP_PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects describe "${GCP_PROJECT_ID}" --format="value(projectNumber)")

gh secret set PAT_GITHUB              --app dependabot --body "$PAT_GITHUB"
gh secret set GCP_PROJECT_ID         --app dependabot --body "$GCP_PROJECT_ID"
gh secret set GCP_SERVICE_ACCOUNT    --app dependabot --body "github-actions@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER --app dependabot \
  --body "projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
gh secret set CLAUDE_CODE_OAUTH_TOKEN --app dependabot --body "$CLAUDE_CODE_OAUTH_TOKEN"
```

### Installation

```bash
make setup
```

### Development

```bash
make clean      # Remove temporary files
make lint       # Run all pre-commit hooks
make format     # Format SQL, Python, YAML
```

## CI/CD

| Workflow | Trigger | Description |
|----------|---------|-------------|
| CI Pipeline | PR to main | Full build, test, lint cycle with ephemeral BigQuery dataset |
| CD Pipeline | Push to main | Build Docker image, push to Artifact Registry, deploy to Cloud Run |
| Daily Pipeline | Cron (06:00 UTC) | Production `dbt build` |
| AI PR Review | PR open/sync | AI code review |
| Auto-Document Columns | PR with SQL changes | Generate missing column descriptions and commit to branch |
| Real-Time Cost Estimation | PR with SQL changes | BigQuery dry-run cost analysis with optimisation recommendations |
| Fix CI Failure | CI Pipeline failure | Analyse failure logs and comment fix suggestions on PR |
| Fix Cloud Run Failure | Cloud Run Job failure / `repository_dispatch` | Analyse logs, create fix PR |
| Abandoned Models | Weekly (Monday) | Detect orphaned BigQuery tables |
| Codebase Review | Weekly (Monday) | AI best-practice audit |
| Data Quality Check | Weekly (Monday) | Detect data anomalies and create issue |

## Data Sources

| Source | BigQuery Dataset | Description |
|--------|-----------------|-------------|
| Austin Bikeshare | `bigquery-public-data.austin_bikeshare` | Austin B-cycle station and trip data |
| NYC Citi Bike | `bigquery-public-data.new_york_citibike` | NYC Citi Bike station and trip data |

## Project Structure

```
.
├── .claude/commands/     # Custom Claude Code slash commands
├── .claude/skills/       # Project-local Claude Code skills
├── .github/workflows/    # CI/CD and agentic workflows
├── models/
│   ├── staging/          # Source-specific models
│   ├── intermediate/     # Cross-source unions
│   └── marts/            # Business-ready tables
├── scripts/              # Setup and utility scripts
├── tests/                # Custom data tests
├── CLAUDE.md             # AI project instructions
├── CODEOWNERS            # Code ownership
├── dbt-bouncer.yml       # dbt validation rules
├── dbt_project.yml       # dbt project config
├── Dockerfile            # Container build
├── Makefile              # Developer workflows
├── packages.yml          # dbt packages
├── profiles.yml          # BigQuery connection profiles
└── pyproject.toml        # Python project config
```

# A note on tooling

This repository uses GitHub, GCP and Claude, these were chosen not because they are leading technologies in their areas but because they make demonstrations easy to replicate by being free (GitHub), having a generous free tier (GCP) or widely used (Claude). The ideas, processes and way of working can be replicated using many other tools.
