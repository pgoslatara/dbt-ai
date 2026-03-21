---
marp: true
theme: gaia
paginate: true
backgroundColor: #1a1a2e
color: #e0e0e0
style: |
  section {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  }
  h1, h2, h3 {
    color: #ff6b35;
  }
  code {
    background-color: #16213e;
    color: #e0e0e0;
  }
  a {
    color: #4ecdc4;
  }
  table {
    font-size: 0.8em;
  }
  th {
    background-color: #ff6b35;
    color: #1a1a2e;
  }
  .columns {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
  }
---

<!-- _class: lead -->
<!-- _paginate: false -->

# AI-Powered dbt

## From Code Review to Agentic Workflows

**Amsterdam dbt Meetup** — 26 March 2026

Philip Oslatara

<!-- Speaker notes: Welcome everyone. Today I'll show you how AI can become a genuine teammate in your dbt workflow — not just a chatbot, but an active participant in code review, testing, and maintenance. -->

---

# About Me

- **Philip Oslatara** — Data Engineering Consultant
- Building data platforms with dbt, BigQuery, and friends
- Passionate about developer experience and automation
- GitHub: [@pgoslatara](https://github.com/pgoslatara)

<!-- Speaker notes: Brief intro. I've been working with dbt for several years across multiple client projects. The patterns I'll show today come from real production experience. ~1 minute -->

---

# Agenda

1. The problem: dbt at scale
2. AI as a teammate (not a tool)
3. Teaching AI your conventions
4. Automated code review
5. Agentic workflows
6. **Live demo**
7. Lessons learned

<!-- Speaker notes: Here's what we'll cover in the next 20 minutes. The live demo is about 6 minutes — I'll generate a model, open a PR, and show the AI in action. ~30 seconds -->

---

# The Problem: dbt at Scale

- **Code review burden** — every PR needs SQL style checks, test coverage review, naming convention validation
- **Stale models** — BigQuery tables that no longer have a dbt model definition
- **Quality drift** — conventions established early get forgotten as the team grows
- **Documentation debt** — columns and models without descriptions

<!-- Speaker notes: These are problems I see at every client. The bigger the project, the worse it gets. Manual reviews can't catch everything, and developers have better things to do than check naming conventions. ~2 minutes -->

---

# The Solution: AI as a Teammate

| Manual | AI-Powered |
|--------|-----------|
| Review PR for style | Claude reviews every PR automatically |
| Check for missing tests | AI flags untested models |
| Find orphaned tables | Weekly automated detection |
| Write boilerplate | Slash commands generate models |
| Document columns | AI generates descriptions |

**Key insight:** AI handles the repetitive, rule-based work so humans can focus on business logic and architecture.

<!-- Speaker notes: The shift here is from AI as a code generator to AI as an active participant in your development workflow. It's not about replacing engineers — it's about automating the tedious parts. ~1 minute -->

---

# CLAUDE.md — Teaching AI Your Conventions

```markdown
## Naming Conventions
- Staging models: `stg_<source>__<entity>.sql`
- Intermediate models: `int_<entity>.sql`
- Dimensions: `dim_<entity>.sql`
- Facts: `fct_<entity>.sql`

## SQL Style
- Uppercase SQL keywords
- One column per line in SELECT
- CTEs over subqueries

## Materializations
- Staging/Intermediate: view
- Marts: table or incremental
```

**This file is the secret weapon.** Every AI interaction follows these rules.

<!-- Speaker notes: CLAUDE.md is a project-level instruction file. When Claude Code works on your project, it reads this file first. Think of it as onboarding docs for your AI teammate. ~2 minutes -->

---

# dbt-agent-skills

Purpose-built AI skills from **dbt Labs**:

- Understand dbt project structure
- Know about refs, sources, materializations
- Follow dbt best practices by default

```bash
# Installed via Claude Code marketplace
/plugin marketplace add dbt-labs/dbt-agent-skills
```

**Why it matters:** Generic AI knows SQL. dbt-agent-skills know *dbt*.

<!-- Speaker notes: This is a Claude Code plugin from dbt Labs themselves. It gives Claude deep knowledge of dbt patterns — not just SQL, but refs, sources, the DAG, materializations. ~1.5 minutes -->

---

# Custom Slash Commands

```
/generate-staging-model austin_bikeshare.bikeshare_trips
```

Generates:
- SQL file with CTE pattern (`source` -> `renamed` -> `SELECT`)
- Source YAML with freshness checks
- Model YAML with column descriptions and tests
- Correct naming and placement

Also available:
- `/add-tests <model>` — add comprehensive tests
- `/document-model <model>` — add documentation

<!-- Speaker notes: These are custom prompts stored in .claude/commands/. They encode your project's patterns so any developer can generate consistent models. ~1 minute -->

---

# Claude PR Review

Every PR gets reviewed by Claude as a **senior dbt engineer**:

- SQL style compliance
- Naming convention violations
- Missing tests and documentation
- Performance concerns (full scans, wrong materializations)
- Business logic correctness

```yaml
# .github/workflows/claude_pr_review.yml
uses: anthropics/claude-code-action@v1
with:
  prompt: |
    Review this PR as a senior dbt/analytics engineer...
```

<!-- Speaker notes: This runs on every PR via GitHub Actions. It's not a replacement for human review — it's a first pass that catches the mechanical stuff so your human reviewers can focus on design and logic. ~1.5 minutes -->

---

# Agentic Workflows

## Weekly Abandoned Models Detection

```
Manifest models ──→ Compare ←── BigQuery tables
                       │
                  Abandoned?
                       │
              Create GitHub Issue
              with DROP SQL
```

## Weekly Codebase Review

AI scans the entire project for:
- Models without tests or docs
- Naming violations
- Incorrect materializations
- Missing source freshness checks

<!-- Speaker notes: These run on a weekly cron schedule. The abandoned models check uses the dbt manifest and BigQuery metadata. The codebase review is a full AI audit. Both create GitHub issues automatically. ~2 minutes -->

---

# Automated Failure Remediation

## CI Pipeline Fails on a PR

```
PR push → CI fails → Fix CI Failure workflow
                           │
                   Claude analyzes logs
                           │
                   Posts fix suggestion
                   as PR comment
```

## Cloud Run Job Fails (Daily Build)

```
Cloud Run fails → Cloud Monitoring alert
                       │
              GitHub repository_dispatch
                       │
              Claude creates fix PR
```

**Self-healing pipelines** — failures are analyzed and fixes proposed automatically.

<!-- Speaker notes: This is where it gets really interesting. When CI fails on a PR, Claude automatically analyzes the logs and posts a comment with the root cause and suggested fix. For production failures, it goes further and creates a fix PR. ~2 minutes -->

---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _backgroundColor: #0f0f23 -->

# Live Demo

<!-- Speaker notes: Transition to live demo. Switch to terminal. ~0 seconds -->

---

# Demo: Project Structure

```
models/
├── staging/
│   ├── austin_bikeshare/    # 4 files
│   └── new_york_citibike/   # 4 files
├── intermediate/            # 4 files
└── marts/                   # 4 files
```

**Two cities -> unified analytics**

Staging (source-specific) -> Intermediate (unified) -> Marts (business metrics)

<!-- Speaker notes: BACKUP SLIDE. Show the repo structure in terminal. Point out the clear layer separation. ~30 seconds -->

---

# Demo: Generating a Staging Model

```bash
# In Claude Code terminal:
/generate-staging-model austin_bikeshare.bikeshare_stations
```

**What happens:**
1. Claude reads the source schema
2. Generates SQL with CTE pattern
3. Creates source + model YAML
4. Adds tests and descriptions
5. Places files correctly

<!-- Speaker notes: BACKUP SLIDE. Run the command live. Show the generated files. Point out how it follows CLAUDE.md conventions. ~2 minutes -->

---

# Demo: Claude PR Review in Action

**PR opened -> Claude comments within minutes:**

- "Column `station_id` should have a `not_null` test"
- "Consider `incremental` materialization for this large fact table"
- "Missing description for `is_weekend` column"

<!-- Speaker notes: BACKUP SLIDE. Show a real PR with Claude's review comments. Point out the quality and specificity of the feedback. ~1.5 minutes -->

---

# Demo: Agentic Workflow Output

**GitHub Issue created automatically:**

> ### Abandoned Models Report
> The following BigQuery tables exist but are not defined in the dbt manifest:
> - `dbt_ai_prod.old_staging_table`
>
> ### Suggested cleanup SQL
> ```sql
> DROP TABLE IF EXISTS `project.dbt_ai_prod.old_staging_table`;
> ```

<!-- Speaker notes: BACKUP SLIDE. Show a real GitHub issue. Point out the actionable SQL. ~1 minute -->

---

# Lessons Learned

**What works well:**
- PR review catches 80% of style/convention issues
- Slash commands dramatically speed up new model creation
- Abandoned model detection prevents BigQuery cost creep

**What to watch out for:**
- AI can be confidently wrong — always review generated code
- Token costs add up with large diffs
- Keep CLAUDE.md updated as conventions evolve

<!-- Speaker notes: Be honest about limitations. AI is a teammate, not a replacement. The cost is real but worth it for the time saved. ~1.5 minutes -->

---

# Getting Started

1. **Add `CLAUDE.md`** to your dbt project with your conventions
2. **Install dbt-agent-skills** in Claude Code
3. **Create slash commands** for your common patterns
4. **Add PR review workflow** (< 20 lines of YAML)
5. **Start with one agentic workflow** and expand

**Repository:** [github.com/pgoslatara/dbt-ai](https://github.com/pgoslatara/dbt-ai)

<!-- Speaker notes: Encourage people to start small. CLAUDE.md alone is a massive improvement. ~1 minute -->

---

<!-- _class: lead -->
<!-- _paginate: false -->

# Questions?

**Philip Oslatara**

GitHub: [@pgoslatara](https://github.com/pgoslatara)

Repo: [github.com/pgoslatara/dbt-ai](https://github.com/pgoslatara/dbt-ai)

<!-- Speaker notes: Open for Q&A. Have the repo open for reference. -->
