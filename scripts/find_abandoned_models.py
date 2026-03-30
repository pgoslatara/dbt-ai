"""Find BigQuery tables that exist but are not defined in the dbt manifest.

Uses dbt's programmatic API to parse the project and resolve model schemas,
then uses the BigQuery Python client to list tables and identify abandoned ones.

Usage:
    # Run against prod target (default)
    uv run python scripts/find_abandoned_models.py

    # Run against a specific target
    uv run python scripts/find_abandoned_models.py --target dev

    # Override the GCP project
    uv run python scripts/find_abandoned_models.py --project-id my-project
"""

import argparse
import json
import logging
import sys
from pathlib import Path

from dbt.cli.main import dbtRunner
from google.api_core.exceptions import GoogleAPIError
from google.cloud import bigquery

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
_handler = logging.StreamHandler(sys.stderr)
_handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s", datefmt="%H:%M:%S"))
logger.addHandler(_handler)
logger.propagate = False


def parse_manifest(target: str) -> dict[str, set[str]]:
    """Parse the dbt project and return a mapping of dataset -> set of table names.

    Args:
        target: The dbt target to parse against (e.g. "prod", "dev").

    Returns:
        A dict mapping dataset names to sets of expected table names.
    """
    logger.info("Running dbt deps...")
    runner = dbtRunner()
    deps_result = runner.invoke(["deps", "--log-level", "error"])
    if not deps_result.success:
        logger.error("dbt deps failed: %s", deps_result.exception)
        sys.exit(1)

    logger.info("Parsing dbt project with target '%s'...", target)
    parse_result = runner.invoke(["parse", "--target", target, "--log-level", "error"])
    if not parse_result.success:
        logger.error("dbt parse failed: %s", parse_result.exception)
        sys.exit(1)

    manifest_path = Path("target/manifest.json")
    with manifest_path.open() as f:
        manifest = json.load(f)

    models: dict[str, set[str]] = {}
    for node in manifest.get("nodes", {}).values():
        if node.get("resource_type") != "model":
            continue

        dataset = node["schema"]
        table_name = node.get("alias") or node["name"]
        models.setdefault(dataset, set()).add(table_name)

    for dataset, tables in sorted(models.items()):
        logger.info("  Dataset '%s': %d model(s) — %s", dataset, len(tables), ", ".join(sorted(tables)))

    logger.info("Found %d model(s) across %d dataset(s)", sum(len(t) for t in models.values()), len(models))
    return models


def get_bigquery_tables(client: bigquery.Client, project_id: str, dataset_id: str) -> set[str]:
    """List all tables in a BigQuery dataset.

    Args:
        client: An authenticated BigQuery client.
        project_id: The GCP project ID.
        dataset_id: The BigQuery dataset ID.

    Returns:
        A set of table names in the dataset.
    """
    dataset_ref = f"{project_id}.{dataset_id}"
    try:
        tables = set()
        for table in client.list_tables(dataset_ref):
            tables.add(table.table_id)
    except GoogleAPIError:
        logger.warning("  Dataset '%s': does not exist or is not accessible", dataset_id)
        return set()
    else:
        logger.info("  Dataset '%s': %d table(s) in BigQuery", dataset_id, len(tables))
        return tables


def generate_report(
    abandoned: dict[str, set[str]],
    project_id: str,
) -> str:
    """Generate a markdown report of abandoned tables.

    Args:
        abandoned: A dict mapping dataset names to sets of abandoned table names.
        project_id: The GCP project ID.

    Returns:
        A markdown-formatted report string.
    """
    total = sum(len(tables) for tables in abandoned.values())
    lines = [
        "# Abandoned Models Report\n",
        f"Found {total} abandoned table(s) across {len(abandoned)} dataset(s).\n",
        "The following BigQuery tables exist but are not defined in the dbt manifest:\n",
    ]

    drop_statements = []
    for dataset in sorted(abandoned):
        for table in sorted(abandoned[dataset]):
            lines.append(f"- `{project_id}.{dataset}.{table}`")
            drop_statements.append(f"DROP TABLE IF EXISTS `{project_id}.{dataset}.{table}`;")

    lines.append("\n## Suggested cleanup SQL\n")
    lines.append("```sql")
    lines.extend(drop_statements)
    lines.append("```")

    return "\n".join(lines)


def main() -> None:
    """Compare dbt manifest models against BigQuery tables and report abandoned ones."""
    parser = argparse.ArgumentParser(description="Find abandoned BigQuery tables not in the dbt manifest.")
    parser.add_argument("--target", default="prod", help="dbt target to parse against (default: prod)")
    parser.add_argument("--project-id", default=None, help="GCP project ID (default: from environment or BQ client)")
    args = parser.parse_args()

    logger.info("=== Finding abandoned models (target: %s) ===", args.target)

    # Step 1: Parse the dbt project to get expected models
    logger.info("--- Step 1: Parsing dbt project ---")
    manifest_models = parse_manifest(args.target)

    if not manifest_models:
        logger.warning("No models found in the manifest. Nothing to check.")
        return

    # Step 2: Connect to BigQuery and list tables
    logger.info("--- Step 2: Listing BigQuery tables ---")
    client = bigquery.Client(project=args.project_id)
    project_id = client.project
    logger.info("Using GCP project: %s", project_id)

    abandoned: dict[str, set[str]] = {}
    for dataset_id, expected_tables in sorted(manifest_models.items()):
        bq_tables = get_bigquery_tables(client, project_id, dataset_id)
        if not bq_tables:
            continue

        unexpected = bq_tables - expected_tables
        if unexpected:
            abandoned[dataset_id] = unexpected
            logger.info(
                "  Dataset '%s': %d abandoned table(s) — %s",
                dataset_id,
                len(unexpected),
                ", ".join(sorted(unexpected)),
            )

    # Step 3: Generate report
    logger.info("--- Step 3: Generating report ---")
    if not abandoned:
        report = "No abandoned models found."
    else:
        total = sum(len(t) for t in abandoned.values())
        logger.warning("Found %d abandoned table(s)!", total)
        report = generate_report(abandoned, project_id)

    print(report)  # noqa: T201
    logger.info("=== Done ===")


if __name__ == "__main__":
    main()
