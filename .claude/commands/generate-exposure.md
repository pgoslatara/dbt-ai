Generate a dbt exposure definition based on this description: $ARGUMENTS

1. Parse the plain-English description to understand what kind of downstream consumer this is (dashboard, analysis, application, ML model, notebook).
2. Read all models in `models/marts/` to understand which mart models contain columns relevant to the described consumer.
3. Select the appropriate `depends_on` refs based on column relevance.
4. Generate an exposure definition and add it to `models/marts/_marts__exposures.yml` (create the file if it does not exist).
5. Use this format:

```yaml
exposures:
  - name: snake_case_name
    description: >
      Clear description of what this consumer does.
    type: dashboard|analysis|application|ml|notebook
    maturity: high|medium|low
    depends_on:
      - ref('model_name')
    owner:
      name: Philip Oslatara
      email: philip@example.com
```

6. If `_marts__exposures.yml` already exists, append to the existing `exposures:` list (do not overwrite).
7. Keep the exposure name concise and descriptive in snake_case.
