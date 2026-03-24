---
marp: true
theme: default
paginate: true
style: |
  /* ── Xebia brand palette ── */
  :root {
    --xebia-plum: #6B2D5B;
    --xebia-teal: #2CBCB3;
    --xebia-green: #2E8B57;
    --xebia-gray: #555555;
    --xebia-light-gray: #f5f5f5;
  }

  /* ── Default (light) slides ── */
  section {
    font-family: 'Nunito Sans', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #ffffff;
    color: var(--xebia-gray);
  }
  h1 {
    color: var(--xebia-plum);
    font-weight: 800;
    font-size: 1.8em;
  }
  h2 {
    color: var(--xebia-plum);
    font-weight: 700;
    font-size: 1.4em;
  }
  h3 {
    color: var(--xebia-plum);
    font-weight: 600;
  }
  strong {
    color: #333333;
  }
  a {
    color: var(--xebia-teal);
  }
  code {
    background-color: #f0f0f0;
    color: var(--xebia-green);
    font-size: 0.9em;
  }
  pre code {
    background-color: #1e1e2e;
    color: #e0e0e0;
  }
  pre {
    background-color: #1e1e2e;
    border-radius: 8px;
    border-left: 4px solid var(--xebia-plum);
  }
  table {
    font-size: 0.8em;
  }
  th {
    background-color: var(--xebia-plum);
    color: #ffffff;
  }
  li::marker {
    color: var(--xebia-plum);
  }
  blockquote {
    border-left: 4px solid var(--xebia-teal);
    color: var(--xebia-gray);
    background-color: var(--xebia-light-gray);
    padding: 0.5em 1em;
  }
  footer {
    color: #999999;
    font-size: 0.6em;
  }
  section::after {
    color: #999999;
    font-size: 0.7em;
  }

  /* ── Dark (plum) slides ── */
  section.lead {
    background-color: var(--xebia-plum);
    color: #ffffff;
  }
  section.lead h1,
  section.lead h2,
  section.lead h3 {
    color: #ffffff;
  }
  section.lead strong {
    color: #ffffff;
  }
  section.lead a {
    color: var(--xebia-teal);
  }
  section.lead code {
    background-color: rgba(255,255,255,0.15);
    color: #ffffff;
  }
  section.lead::after {
    color: rgba(255,255,255,0.5);
  }

  /* ── Columns helper ── */
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

Padraic Slattery

<!-- Speaker notes: Welcome everyone. Today I'll show you how AI can become a genuine teammate in your dbt workflow — not just a chatbot, but an active participant in code review, testing, and maintenance. -->

---

# About Me

- **Padraic Slattery** — Analytics Engineer @ Xebia Data
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
5. Agentic workflows & data quality monitoring
6. Unit tests & hooks
7. **Cutting-edge Wow Factors (MCP, Auto-Docs, Cost Agents)**
8. **Live demo**
9. Lessons learned

<!-- Speaker notes: Here's what we'll cover in the next 20 minutes. The live demo is about 6 minutes — I'll generate a model, open a PR, and show the AI in action. ~30 seconds -->

---

<!-- _class: lead -->

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

| Command | What it does |
|---------|-------------|
| `/generate-staging-model` | Full model + YAML + tests from source |
| `/add-tests` | Comprehensive tests for any model |
| `/document-model` | Descriptions for model + columns |
| `/generate-unit-tests` | Unit tests for computed columns |
| `/generate-verified-model` | Manifest-validated model generation |
| `/generate-exposure` | Exposure from plain-English description |

**Use when:** task is user-initiated, needs an explicit argument, and follows a predictable, templated output pattern.

<!-- Speaker notes: These are the generation commands — they take an argument and produce or modify files. Any developer can use them without knowing the project patterns by heart. -->

---

# Skills

| Skill | What it does |
|-------|-------------|
| `dbt-explain-model` | Plain-English model explanation |
| `dbt-impact-analysis` | Downstream dependency analysis |
| `dbt-review-sql` | BigQuery performance review |
| `dbt-suggest-tests` | Propose missing tests |

**Use when:** task encodes how Claude thinks about a class of problem — a multi-step protocol reusable across projects, invokable naturally or via slash command.

> Also invokable as `/explain-model`, `/impact-analysis`, `/review-sql`, `/suggest-tests`

<!-- Speaker notes: Skills are behavioral protocols, not just prompt templates. They live in ~/.claude/skills/ so they work in any dbt project, not just this one. Claude can also invoke them proactively without the user typing a slash command. -->

---

# dbt Unit Tests (v1.8+)

Test transformation logic with **mock data — no database needed**:

```yaml
unit_tests:
  - name: test_is_round_trip_true
    model: fct_trips
    given:
      - input: ref('int_trips_unioned')
        rows:
          - {start_station_id: "s1", end_station_id: "s1"}
    expect:
      rows:
        - {is_round_trip: true}
```

- Tests computed columns: `is_round_trip`, `is_weekend`, `day_of_week`
- Claude generates them via `/generate-unit-tests`
- Runs locally in seconds — fast feedback loop

<!-- Speaker notes: Unit tests are new in dbt 1.8. They let you test business logic without hitting the database. Claude can generate them automatically by reading your SQL. ~1.5 minutes -->

---

# Claude PR Review

Every PR gets reviewed by Claude as a **senior dbt engineer**:

- SQL style compliance
- Naming convention violations
- Missing tests and documentation
- Performance concerns (full scans, wrong materializations)
- Business logic correctness
- **Always posts a summary comment** — visible trace on every PR

```yaml
# .github/workflows/claude_pr_review.yml
uses: anthropics/claude-code-action@v1
with:
  prompt: |
    Review this PR as a senior dbt/analytics engineer...
```

A fallback step posts "No issues found" if Claude has no feedback — so you always know the review ran.

<!-- Speaker notes: This runs on every PR via GitHub Actions. It's not a replacement for human review — it's a first pass that catches the mechanical stuff so your human reviewers can focus on design and logic. A fallback step ensures every review leaves a visible comment, even when nothing is flagged. ~1.5 minutes -->

---

<!-- _class: lead -->

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

# Data Quality Monitoring

```
Weekly cron ──→ Query BigQuery metrics
                       │
              Compare vs 30-day baseline
                       │
                z-score > 2?
                       │
              Claude analyzes anomalies
                       │
              Create GitHub Issue
              (Alert / Warning / Info)
```

- Trip volume spikes or drops
- Duration anomalies by city
- Data freshness (>3 days stale)
- Station count changes

<!-- Speaker notes: This is the newest workflow. It queries production data, not code. Claude analyzes statistical anomalies and creates categorized issues. It catches problems that code review never will. ~1.5 minutes -->

---

# Claude Code Hooks

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "command": "sqlfmt --check $FILE"
      }]
    }]
  }
}
```

- **PostToolUse**: Auto-checks SQL formatting after every edit
- Hooks fire automatically — no manual step needed
- Catches issues before they reach pre-commit

<!-- Speaker notes: Hooks wire AI into your git workflow. When Claude edits a SQL file, sqlfmt automatically checks it. The AI sees the feedback and self-corrects. ~1 minute -->

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

# Cutting-Edge "Wow Factors"

**1. Model Context Protocol (MCP)**
Claude reads `target/manifest.json` as a structured graph, enabling hallucination-free questions about lineage and the Semantic layer.

**2. Anti-Hallucination Harness**
New `/generate-verified-model` explicitly validates required upstream schemas against the compiled manifest before writing SQL.

**3. Automated CI Documentation (diff2docs)**
Forget to update YAML? Claude reads the SQL diff and automatically pushes new column descriptions directly to your PR branch.

**4. Real-time Cost Estimation Agent**
GitHub Actions runs a BQ dry-run on every PR. Claude analyzes the resulting bytes processed and comments on the PR with the estimated cost and optimization tips.

<!-- Speaker notes: These are features we are rolling out now based on what we saw at Coalesce. By hooking Claude up to the dbt MCP server and building agentic workflows on top of BigQuery's dry-run API, the AI isn't just generating text; it's reasoning with perfect project context. ~2 minutes -->

---

<!-- _class: lead -->
<!-- _paginate: false -->

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

- "`GROUP BY total_trips` treats the metric as a grouping key — use `SUM()` instead"
- "Global `tests: +severity: warn` suppresses all test failures — scope to staging"
- "`cloud_event["data"]` raises TypeError — use `.data` attribute access"

**No issues?** Claude still posts:

> **Claude Code Review** — No issues found. Reviewed for SQL style, naming conventions, tests, documentation, performance, business logic, and materializations.

<!-- Speaker notes: BACKUP SLIDE. Show a real PR with Claude's review comments. These are actual issues caught on our PR. Point out how it found a real SQL bug (wrong GROUP BY), a config issue (global severity), and a runtime error (CloudEvent access). Even when nothing is found, a comment is always posted. ~1.5 minutes -->

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
- Unit tests catch logic bugs before they hit the warehouse
- Data quality monitoring catches issues that code review never will

**What to watch out for:**
- AI can be confidently wrong — always review generated code
- Token costs add up with large diffs
- Keep CLAUDE.md updated as conventions evolve
- Unit test mock data needs to match your column types exactly
- Public data quality issues cascade through all layers — scope `severity: warn` accordingly
- Formatter vs convention conflicts (e.g. sqlfmt lowercase vs CLAUDE.md uppercase) — pick one source of truth

<!-- Speaker notes: Be honest about limitations. AI is a teammate, not a replacement. The cost is real but worth it for the time saved. We learned the hard way that null values in public datasets cascade from staging through marts, so you need to set test severity globally rather than per-layer. Also, automated formatters like sqlfmt can conflict with your stated conventions — make sure CLAUDE.md reflects your actual enforced style. ~2 minutes -->

---

# Getting Started

1. **Add `CLAUDE.md`** to your dbt project with your conventions
2. **Install dbt-agent-skills** in Claude Code
3. **Create slash commands and skills** for your common patterns
4. **Add PR review workflow** (< 20 lines of YAML)
5. **Start with one agentic workflow** and expand

**Repository:** [github.com/pgoslatara/dbt-ai](https://github.com/pgoslatara/dbt-ai)

<!-- Speaker notes: Encourage people to start small. CLAUDE.md alone is a massive improvement. ~1 minute -->

---

<!-- _class: lead -->
<!-- _paginate: false -->

# Questions?

**Padraic Slattery** — Analytics Engineer @ Xebia Data

GitHub: [@pgoslatara](https://github.com/pgoslatara)

Repo: [github.com/pgoslatara/dbt-ai](https://github.com/pgoslatara/dbt-ai)

<!-- Speaker notes: Open for Q&A. Have the repo open for reference. -->
