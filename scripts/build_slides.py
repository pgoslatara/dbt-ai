"""Build the Amsterdam dbt Meetup Google Slides deck from the Xebia template.

Usage:
    python scripts/build_slides.py

Requires the `gws` CLI authenticated with Google Workspace scopes.
Replaces all existing slides in the target presentation with the SLIDES
list defined below, preserving the Xebia master and layouts.
"""

import json
import subprocess
import sys

PRES_ID = "1jWjz7QxmWajZzxfElCxzrX_sCVKndjzLZxRqE1Cq22w"

# Layouts from the Xebia template with their placeholder objectIds:
#   p140 (Intro #2):      title=p140_i165  body=p140_i169
#   p145 (Text 100% #2):  title=p145_i3    body=p145_i6
#   p147 (Chapter #4):    title=p147_i165  body=p147_i169
#   p173 (Intro #1):      title=p173_i165  body=p173_i169  (same structure as p140)

SLIDES = [
    {
        "id": "slide00",
        "layout": "p140",
        "layout_title": "p140_i165",
        "layout_body": "p140_i169",
        "title": "AI-Powered dbt",
        "body": ("From Code Review to Agentic Workflows\n\nAmsterdam dbt Meetup — 26 March 2026\n\nPadraic Slattery"),
    },
    {
        "id": "slide01",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "About Me",
        "body": (
            "Padraic Slattery — Analytics Engineer @ Xebia Data\n"
            "Building data platforms with dbt, BigQuery, and friends\n"
            "Passionate about developer experience and automation\n"
            "GitHub: @pgoslatara"
        ),
    },
    {
        "id": "slide02",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Agenda",
        "body": (
            "1. The problem: dbt at scale\n"
            "2. AI as a teammate (not a tool)\n"
            "3. Teaching AI your conventions\n"
            "4. Automated code review\n"
            "5. Agentic workflows & data quality monitoring\n"
            "6. Unit tests & hooks\n"
            "7. Cutting-edge Wow Factors (MCP, Auto-Docs, Cost Agents)\n"
            "8. Live demo\n"
            "9. Lessons learned"
        ),
    },
    {
        "id": "slide03",
        "layout": "p147",
        "layout_title": "p147_i165",
        "layout_body": "p147_i169",
        "title": "The Problem: dbt at Scale",
        "body": (
            "Code review burden — every PR needs SQL style checks, test coverage review, "
            "naming convention validation\n"
            "Stale models — BigQuery tables that no longer have a dbt model definition\n"
            "Quality drift — conventions established early get forgotten as the team grows\n"
            "Documentation debt — columns and models without descriptions"
        ),
    },
    {
        "id": "slide04",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "The Solution: AI as a Teammate",
        "body": (
            "Manual → AI-Powered\n"
            "Review PR for style → Claude reviews every PR automatically\n"
            "Check for missing tests → AI flags untested models\n"
            "Find orphaned tables → Weekly automated detection\n"
            "Write boilerplate → Slash commands generate models\n"
            "Document columns → AI generates descriptions\n\n"
            "Key insight: AI handles the repetitive, rule-based work so humans can focus "
            "on business logic and architecture."
        ),
    },
    {
        "id": "slide05",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "CLAUDE.md — Teaching AI Your Conventions",
        "body": (
            "Naming Conventions\n"
            "  Staging: stg_<source>__<entity>.sql\n"
            "  Intermediate: int_<entity>.sql  |  Dimensions: dim_<entity>.sql  |  Facts: fct_<entity>.sql\n\n"
            "SQL Style\n"
            "  Uppercase keywords · One column per line · CTEs over subqueries\n\n"
            "Materializations\n"
            "  Staging/Intermediate → view  ·  Marts → table or incremental\n\n"
            "This file is the secret weapon. Every AI interaction follows these rules."
        ),
    },
    {
        "id": "slide06",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "dbt-agent-skills",
        "body": (
            "Purpose-built AI skills from dbt Labs:\n"
            "  • Understand dbt project structure\n"
            "  • Know about refs, sources, materializations\n"
            "  • Follow dbt best practices by default\n\n"
            "Installed via Claude Code marketplace:\n"
            "  /plugin marketplace add dbt-labs/dbt-agent-skills\n\n"
            "Why it matters: Generic AI knows SQL. dbt-agent-skills know dbt."
        ),
    },
    {
        "id": "slide07",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Custom Slash Commands",
        "body": (
            "/generate-staging-model  Full model + YAML + tests from source\n"
            "/add-tests               Comprehensive tests for any model\n"
            "/document-model          Descriptions for model + columns\n"
            "/generate-unit-tests     Unit tests for computed columns\n"
            "/generate-verified-model Manifest-validated model generation\n"
            "/generate-exposure       Exposure from plain-English description\n\n"
            "Use when: task is user-initiated, needs an explicit argument, "
            "and follows a predictable, templated output pattern."
        ),
    },
    {
        "id": "slide08",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Skills",
        "body": (
            "dbt-explain-model    Plain-English model explanation\n"
            "dbt-impact-analysis  Downstream dependency analysis\n"
            "dbt-review-sql       BigQuery performance review\n"
            "dbt-suggest-tests    Propose missing tests\n\n"
            "Use when: task encodes how Claude thinks about a class of problem — "
            "a multi-step protocol reusable across projects, invokable naturally or via slash command.\n\n"
            "Also invokable as /explain-model, /impact-analysis, /review-sql, /suggest-tests"
        ),
    },
    {
        "id": "slide09",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "dbt Unit Tests (v1.8+)",
        "body": (
            "Test transformation logic with mock data — no database needed:\n\n"
            "unit_tests:\n"
            "  - name: test_is_round_trip_true\n"
            "    model: fct_trips\n"
            "    given:\n"
            "      rows: [{start_station_id: s1, end_station_id: s1}]\n"
            "    expect:\n"
            "      rows: [{is_round_trip: true}]\n\n"
            "• Tests computed columns: is_round_trip, is_weekend, day_of_week\n"
            "• Claude generates them via /generate-unit-tests\n"
            "• Runs locally in seconds — fast feedback loop"
        ),
    },
    {
        "id": "slide10",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Claude PR Review",
        "body": (
            "Every PR reviewed by Claude as a senior dbt engineer:\n"
            "  • SQL style compliance\n"
            "  • Naming convention violations\n"
            "  • Missing tests and documentation\n"
            "  • Performance concerns (full scans, wrong materializations)\n"
            "  • Business logic correctness\n"
            "  • Always posts a summary comment — visible trace on every PR\n\n"
            "A fallback step posts 'No issues found' if Claude has no feedback — "
            "so you always know the review ran."
        ),
    },
    {
        "id": "slide11",
        "layout": "p147",
        "layout_title": "p147_i165",
        "layout_body": "p147_i169",
        "title": "Agentic Workflows",
        "body": (
            "Weekly Abandoned Models Detection\n"
            "Manifest models → Compare ← BigQuery tables → Abandoned? → "
            "GitHub Issue with DROP SQL\n\n"
            "Weekly Codebase Review\n"
            "AI scans the entire project for:\n"
            "  • Models without tests or docs\n"
            "  • Naming violations\n"
            "  • Incorrect materializations\n"
            "  • Missing source freshness checks"
        ),
    },
    {
        "id": "slide12",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Data Quality Monitoring",
        "body": (
            "Weekly cron → Query BigQuery metrics → Compare vs 30-day baseline\n"
            "→ z-score > 2? → Claude analyzes anomalies → GitHub Issue\n\n"
            "  • Trip volume spikes or drops\n"
            "  • Duration anomalies by city\n"
            "  • Data freshness (>3 days stale)\n"
            "  • Station count changes\n\n"
            "Catches problems that code review never will."
        ),
    },
    {
        "id": "slide13",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Claude Code Hooks",
        "body": (
            "hooks:\n"
            "  PostToolUse:\n"
            "    - matcher: Write|Edit\n"
            "      hooks:\n"
            "        - command: sqlfmt --check $FILE\n\n"
            "  • PostToolUse: auto-checks SQL formatting after every edit\n"
            "  • Hooks fire automatically — no manual step needed\n"
            "  • Catches issues before they reach pre-commit"
        ),
    },
    {
        "id": "slide14",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Automated Failure Remediation",
        "body": (
            "CI Pipeline Fails on a PR\n"
            "PR push → CI fails → Fix CI Failure workflow\n"
            "  → Claude analyzes logs → Posts fix suggestion as PR comment\n\n"
            "Cloud Run Job Fails (Daily Build)\n"
            "Cloud Run fails → Cloud Monitoring alert → GitHub repository_dispatch\n"
            "  → Claude creates fix PR\n\n"
            "Self-healing pipelines — failures are analyzed and fixes proposed automatically."
        ),
    },
    {
        "id": "slide15",
        "layout": "p147",
        "layout_title": "p147_i165",
        "layout_body": "p147_i169",
        "title": 'Cutting-Edge "Wow Factors"',
        "body": (
            "1. Model Context Protocol (MCP)\n"
            "   Claude reads target/manifest.json as a structured graph — "
            "hallucination-free lineage queries\n\n"
            "2. Anti-Hallucination Harness\n"
            "   /generate-verified-model validates upstream schemas against the compiled manifest\n\n"
            "3. Automated CI Documentation (diff2docs)\n"
            "   Claude reads the SQL diff and pushes column descriptions to your PR branch\n\n"
            "4. Real-time Cost Estimation Agent\n"
            "   BQ dry-run on every PR → Claude analyzes bytes processed and comments cost + tips"
        ),
    },
    {
        "id": "slide16",
        "layout": "p140",
        "layout_title": "p140_i165",
        "layout_body": "p140_i169",
        "title": "Live Demo",
        "body": "",
    },
    {
        "id": "slide17",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Demo: Project Structure",
        "body": (
            "models/\n"
            "├── staging/\n"
            "│   ├── austin_bikeshare/    # 4 files\n"
            "│   └── new_york_citibike/   # 4 files\n"
            "├── intermediate/            # 4 files\n"
            "└── marts/                   # 4 files\n\n"
            "Two cities → unified analytics\n"
            "Staging (source-specific) → Intermediate (unified) → Marts (business metrics)"
        ),
    },
    {
        "id": "slide18",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Demo: Generating a Staging Model",
        "body": (
            "/generate-staging-model austin_bikeshare.bikeshare_stations\n\n"
            "What happens:\n"
            "1. Claude reads the source schema\n"
            "2. Generates SQL with CTE pattern\n"
            "3. Creates source + model YAML\n"
            "4. Adds tests and descriptions\n"
            "5. Places files correctly"
        ),
    },
    {
        "id": "slide19",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Demo: Claude PR Review in Action",
        "body": (
            "PR opened → Claude comments within minutes:\n"
            '  • "GROUP BY total_trips treats the metric as a grouping key — use SUM() instead"\n'
            '  • "Global tests: +severity: warn suppresses all test failures — scope to staging"\n'
            '  • "cloud_event[\\"data\\"] raises TypeError — use .data attribute access"\n\n'
            "No issues? Claude still posts:\n"
            "  Claude Code Review — No issues found. Reviewed for SQL style, naming conventions, "
            "tests, documentation, performance, business logic, and materializations."
        ),
    },
    {
        "id": "slide20",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Demo: Agentic Workflow Output",
        "body": (
            "GitHub Issue created automatically:\n\n"
            "Abandoned Models Report\n"
            "The following BigQuery tables exist but are not defined in the dbt manifest:\n"
            "  • dbt_ai_prod.old_staging_table\n\n"
            "Suggested cleanup SQL:\n"
            "  DROP TABLE IF EXISTS `project.dbt_ai_prod.old_staging_table`;"
        ),
    },
    {
        "id": "slide21",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Lessons Learned",
        "body": (
            "What works well:\n"
            "  • PR review catches 80% of style/convention issues\n"
            "  • Slash commands dramatically speed up new model creation\n"
            "  • Abandoned model detection prevents BigQuery cost creep\n"
            "  • Unit tests catch logic bugs before they hit the warehouse\n"
            "  • Data quality monitoring catches issues that code review never will\n\n"
            "Watch out for:\n"
            "  • AI can be confidently wrong — always review generated code\n"
            "  • Token costs add up with large diffs\n"
            "  • Keep CLAUDE.md updated as conventions evolve\n"
            "  • Formatter vs convention conflicts — pick one source of truth"
        ),
    },
    {
        "id": "slide22",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "Getting Started",
        "body": (
            "1. Add CLAUDE.md to your dbt project with your conventions\n"
            "2. Install dbt-agent-skills in Claude Code\n"
            "3. Create slash commands and skills for your common patterns\n"
            "4. Add PR review workflow (< 20 lines of YAML)\n"
            "5. Start with one agentic workflow and expand\n\n"
            "Repository: github.com/pgoslatara/dbt-ai"
        ),
    },
    {
        "id": "slideEvals",
        "layout": "p145",
        "layout_title": "p145_i3",
        "layout_body": "p145_i6",
        "title": "What's Next: Evals for AI Skills",
        "body": (
            "Today: you write a skill or update CLAUDE.md and trust it works — "
            "there's no test suite\n\n"
            "Evals change that — structured assertions on AI behaviour:\n"
            "  Input:    SELECT * FROM orders   -- no partition filter\n"
            "  Expected: Claude flags full table scan\n"
            "  Result:   \u2713 pass  /  \u2717 fail\n\n"
            "What you can eval:\n"
            "  \u2022 Skills — does dbt-review-sql catch the anti-patterns it claims to?\n"
            "  \u2022 Slash commands — does /generate-staging-model follow your naming conventions?\n"
            "  \u2022 CLAUDE.md changes — does updating one rule break another?\n\n"
            "CI integration: run evals on every CLAUDE.md or skill change,\n"
            "the same way dbt tests run on every model change\n\n"
            "Tools available today: PromptFoo, Anthropic Evals API"
        ),
    },
    {
        "id": "slide23",
        "layout": "p173",
        "layout_title": "p173_i165",
        "layout_body": "p173_i169",
        "title": "Questions?",
        "body": (
            "Padraic Slattery — Analytics Engineer @ Xebia Data\n\n"
            "GitHub: @pgoslatara\n"
            "Repo: github.com/pgoslatara/dbt-ai"
        ),
    },
]


def gws(*args: str, json_body: dict | None = None, params: dict | None = None) -> dict:
    """Run a gws CLI command and return the parsed JSON response."""
    cmd = ["gws", *args]
    if params:
        cmd += ["--params", json.dumps(params)]
    if json_body:
        cmd += ["--json", json.dumps(json_body)]
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)  # noqa: S603
    if result.returncode != 0:
        sys.stderr.write(f"ERROR running {' '.join(cmd[:4])}: {result.stderr[:500]}\n")
        sys.exit(1)
    lines = [line for line in result.stdout.split("\n") if not line.startswith("Using keyring")]
    text = "\n".join(lines).strip()
    if not text:
        return {}
    return json.loads(text)  # type: ignore[no-any-return]


def main() -> None:
    """Build the Google Slides deck from SLIDES, replacing all existing slides."""
    # ── Phase 1: get existing slide IDs to delete ──────────────────────────
    sys.stdout.write("Fetching current presentation...\n")
    pres = gws("slides", "presentations", "get", params={"presentationId": PRES_ID})
    old_slide_ids = [s["objectId"] for s in pres.get("slides", [])]
    sys.stdout.write(f"  Found {len(old_slide_ids)} existing slides to delete\n")

    # ── Phase 2: build one big batchUpdate ─────────────────────────────────
    requests: list[dict] = []

    # 2a. Create slides (appended after existing)
    for slide in SLIDES:
        # layoutPlaceholder uses type+index (index omitted = 0).
        # p140/p173 have two BODY placeholders; index 0 = the main body.
        mappings = [
            {
                "layoutPlaceholder": {"type": "TITLE"},
                "objectId": f"{slide['id']}_title",
            },
            {
                "layoutPlaceholder": {"type": "BODY"},
                "objectId": f"{slide['id']}_body",
            },
        ]
        requests.append(
            {
                "createSlide": {
                    "objectId": slide["id"],
                    "slideLayoutReference": {"layoutId": slide["layout"]},
                    "placeholderIdMappings": mappings,
                }
            }
        )

    # 2b. Delete old slides
    requests.extend({"deleteObject": {"objectId": old_id}} for old_id in old_slide_ids)

    # 2c. Insert text into new slides
    for slide in SLIDES:
        requests.append(
            {
                "insertText": {
                    "objectId": f"{slide['id']}_title",
                    "text": slide["title"],
                    "insertionIndex": 0,
                }
            }
        )
        if slide["body"]:
            requests.append(
                {
                    "insertText": {
                        "objectId": f"{slide['id']}_body",
                        "text": slide["body"],
                        "insertionIndex": 0,
                    }
                }
            )

    sys.stdout.write(f"Sending batchUpdate with {len(requests)} requests...\n")
    gws(
        "slides",
        "presentations",
        "batchUpdate",
        params={"presentationId": PRES_ID},
        json_body={"requests": requests},
    )
    sys.stdout.write(f"Done!\nPresentation: https://docs.google.com/presentation/d/{PRES_ID}/edit\n")


if __name__ == "__main__":
    main()
