Generate dbt unit tests for the model `$ARGUMENTS`.

1. Read the model's SQL file and identify columns with computed logic (CASE expressions, IF/IFF, arithmetic, EXTRACT, boolean comparisons, COALESCE, window functions).
2. Read the model's YAML file to understand column types and existing tests.
3. For each computed column, generate unit tests with:
   - A descriptive test name: `test_<column>_<scenario>` (e.g., `test_is_round_trip_true`).
   - Mock input rows in the `given:` block that exercise the logic.
   - Expected output rows in the `expect:` block with only the columns being tested.
   - Cover both the "true" and "false" / "happy" and "edge" cases.
4. Add the unit tests to the model's YAML file under a `unit_tests:` key at the top level (same level as `models:`).
5. Use this format:

```yaml
unit_tests:
  - name: test_descriptive_name
    description: What this test verifies
    model: model_name
    given:
      - input: ref('upstream_model')
        rows:
          - {col1: val1, col2: val2}
    expect:
      rows:
        - {computed_col: expected_value}
```

6. Only generate tests for columns with actual computation — skip pass-through columns.
7. Follow alphabetical ordering for test names.
