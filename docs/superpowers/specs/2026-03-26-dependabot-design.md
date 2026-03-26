# Dependabot & Pre-commit Autoupdate Design

**Date:** 2026-03-26
**Status:** Approved

## Goal

Automate version updates for three categories of dependencies:

1. GitHub Actions used across `.github/workflows/`
2. Python package dependencies declared in `pyproject.toml`
3. External pre-commit hook revisions in `.pre-commit-config.yaml`

## Approach

Dependabot natively handles GitHub Actions and pip packages. A separate scheduled workflow handles pre-commit hooks, since Dependabot has no native support for `.pre-commit-config.yaml`.

## Files to Create

### `.github/dependabot.yml`

Two update blocks, both on a weekly Monday schedule:

- **`github-actions`** — scans `.github/workflows/`, groups all action version bumps into a single PR labelled `dependencies`
- **`pip`** — scans the project root for `pyproject.toml`, groups all package version bumps into a single PR labelled `dependencies`

Grouping is used so each ecosystem produces one PR per cycle rather than one PR per package.

### `.github/workflows/pre_commit_autoupdate.yml`

Scheduled weekly on Monday (consistent with Dependabot). Also triggerable via `workflow_dispatch`.

Permissions required: `contents: write` (to push the autoupdate branch) and `pull-requests: write` (to open the PR).

Steps:
1. `actions/checkout@v4`
2. `astral-sh/setup-uv` + `uv python install` — consistent with other workflows in this repo
3. `uv run pre-commit autoupdate` — updates all external hook revisions in `.pre-commit-config.yaml`
4. `peter-evans/create-pull-request` — opens a PR titled `chore: update pre-commit hook versions` if any files changed; uses branch `chore/pre-commit-autoupdate`; labelled `dependencies`

If `.pre-commit-config.yaml` has not changed (all hooks already at latest), no PR is created.

## Constraints

- All three update mechanisms fire on Monday; no scheduling conflicts between them.
- Dependabot PRs are attributed to `dependabot[bot]`; the autoupdate PR is attributed to `github-actions[bot]`.
- Only one external pre-commit hook currently exists (`pre-commit/pre-commit-hooks@v5.0.0`); the workflow is correct for any future additions too.
- `peter-evans/create-pull-request` version will itself be kept up to date by the `github-actions` Dependabot block.

## Out of Scope

- Python interpreter version (`requires-python`) — not managed by any of these tools.
- Local pre-commit hooks (`repo: local`) — no version to track.
- Auto-merge of Dependabot/autoupdate PRs.
