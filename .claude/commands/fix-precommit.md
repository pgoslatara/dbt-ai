Fix all pre-commit hook failures.

1. Determine whether the project uses `pre-commit` or `prek` by checking `pyproject.toml` and the `Makefile`.
2. Run the hooks against all files (e.g. `prek run --all-files` or `pre-commit run --all-files`).
3. Fix every failure — do **not** modify `.pre-commit-config.yaml`.
4. Re-run the hooks after fixing to confirm all checks pass.
5. Repeat until the full run is clean.
