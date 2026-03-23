Review the SQL in the current file or model for BigQuery performance and best practices.

1. Read the SQL file content.
2. Check for these anti-patterns:
   - **SELECT ***: Should explicitly list columns in staging/intermediate models.
   - **Missing partition filters**: Queries on large tables without WHERE on partition columns.
   - **Cartesian products**: JOINs without ON conditions or CROSS JOINs.
   - **Expensive window functions**: Window functions without PARTITION BY scanning entire table.
   - **Unnecessary DISTINCT**: Using DISTINCT to mask a join issue.
   - **Subqueries over CTEs**: Nested subqueries that should be CTEs for readability.
   - **Missing incremental logic**: Large fact tables materialized as `table` that could benefit from `incremental` with a `merge` strategy.
   - **Unqualified column references**: Columns in JOINs not prefixed with table alias.
3. Check for BigQuery-specific optimizations:
   - Clustering opportunities on high-cardinality filter columns.
   - Appropriate use of CAST vs implicit type coercion.
   - Efficient date/timestamp operations.
4. Present findings as a categorized list (Critical, Warning, Suggestion) with specific line references and recommended fixes.
5. If the SQL follows best practices, say so — don't invent issues.
