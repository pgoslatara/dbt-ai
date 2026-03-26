---
name: dbt-review-sql
description: Review a SQL file for BigQuery performance anti-patterns and best practices. Use when asked to review, check, audit, or assess SQL quality or performance.
---

# dbt-review-sql

Review the SQL in the file at `$ARGUMENTS` (if provided), or the current file if no argument is given.

1. Read the SQL file content. If `$ARGUMENTS` is a file path, read that file; otherwise read the file currently open in the editor.
2. Check for these anti-patterns:
   - **SELECT ***: Should explicitly list columns in staging/intermediate models.
   - **Missing partition filters**: Queries on large tables without WHERE on partition columns.
   - **Cartesian products**: JOINs without ON conditions or CROSS JOINs.
   - **Expensive window functions**: Window functions without PARTITION BY scanning entire table.
   - **Unnecessary DISTINCT**: Using DISTINCT to mask a join issue.
   - **Subqueries over CTEs**: Nested subqueries that should be CTEs for readability.
   - **Missing incremental logic**: Large fact tables materialised as `table` that could benefit from `incremental` with a `merge` strategy.
   - **Unqualified column references**: Columns in JOINs not prefixed with table alias.
3. Check for BigQuery-specific optimisations:
   - Clustering opportunities on high-cardinality filter columns.
   - Appropriate use of CAST vs implicit type coercion.
   - Efficient date/timestamp operations.
4. Present findings as a categorised list using project severity labels — 🔴 **Issue** (must fix), 🟡 **Suggestion** (recommended improvement) — with specific line references and recommended fixes. If there are no issues, say ✅ **All clear** rather than inventing problems.
