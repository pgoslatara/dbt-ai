"""Find BigQuery datasets/tables that exist but are not defined in the dbt manifest."""

import json
import logging
import subprocess
import sys
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger(__name__)


def get_manifest_models(manifest_path: Path) -> set[str]:
    """Extract model names from the dbt manifest."""
    with manifest_path.open() as f:
        manifest = json.load(f)

    models = set()
    for node in manifest.get("nodes", {}).values():
        if node["resource_type"] == "model":
            schema = node.get("schema", "")
            name = node.get("name", "")
            models.add(f"{schema}.{name}")

    return models


def get_bigquery_tables(project_id: str, dataset: str) -> set[str]:
    """List tables in a BigQuery dataset using bq CLI."""
    try:
        result = subprocess.run(  # noqa: S603
            ["bq", "ls", "--format=json", f"{project_id}:{dataset}"],  # noqa: S607
            capture_output=True,
            check=True,
            text=True,
        )
        tables = json.loads(result.stdout) if result.stdout.strip() else []
        return {f"{dataset}.{t['tableReference']['tableId']}" for t in tables}
    except subprocess.CalledProcessError:
        logger.warning("Could not list tables in %s.%s", project_id, dataset)
        return set()


def main() -> None:
    """Compare manifest models against BigQuery tables and report abandoned ones."""
    manifest_path = Path("target/manifest.json")
    if not manifest_path.exists():
        logger.error("manifest.json not found. Run 'dbt parse' first.")
        sys.exit(1)

    project_id = subprocess.run(
        ["gcloud", "config", "get-value", "project"],  # noqa: S607
        capture_output=True,
        check=True,
        text=True,
    ).stdout.strip()

    manifest_models = get_manifest_models(manifest_path)
    datasets = {"dbt_ai_prod", "dbt_ai_dev"}

    all_bq_tables: set[str] = set()
    for dataset in sorted(datasets):
        all_bq_tables.update(get_bigquery_tables(project_id, dataset))

    abandoned = all_bq_tables - manifest_models

    if not abandoned:
        logger.info("No abandoned models found.")
        return

    logger.info("# Abandoned Models Report\n")
    logger.info("The following BigQuery tables exist but are not defined in the dbt manifest:\n")

    drop_statements = []
    for table in sorted(abandoned):
        dataset, name = table.split(".", 1)
        logger.info("- `%s.%s.%s`", project_id, dataset, name)
        drop_statements.append(f"DROP TABLE IF EXISTS `{project_id}.{dataset}.{name}`;")

    logger.info("\n## Suggested cleanup SQL\n")
    logger.info("```sql")
    for stmt in drop_statements:
        logger.info(stmt)
    logger.info("```")


if __name__ == "__main__":
    main()
