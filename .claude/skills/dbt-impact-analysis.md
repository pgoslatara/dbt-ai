---
name: dbt-impact-analysis
description: Analyze the downstream impact of changing a dbt model. Use when asked about impact, downstream dependencies, what would break, or what models consume a given model.
---

# dbt-impact-analysis

Analyse the downstream impact of changing the dbt model `$ARGUMENTS`.

1. Search the entire `models/` directory for all files containing `ref('$ARGUMENTS')` to find direct dependents.
2. For each direct dependent, recursively search for its own dependents to build the full downstream chain. Track already-visited models to avoid infinite loops — if a model has already been processed, skip it.
3. Search for all exposure files by globbing `models/**/*exposures*.yml` and check each one for exposures that depend on any model in the chain.
4. For each affected model, check its YAML for:
   - Contract enforcement (would a column change break the contract?)
   - Tests that validate the relationship.
5. Present the results as:
   - **Direct dependents**: Models that directly reference `$ARGUMENTS`.
   - **Transitive dependents**: Models further downstream.
   - **Affected exposures**: Dashboards or reports that consume downstream models.
   - **Safety nets**: Contracts and tests that would catch breakage.
   - **Risk assessment**: What would break if you changed column names, types, or removed columns.
