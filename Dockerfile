# Stage 1: Build
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

WORKDIR /app

COPY pyproject.toml ./
RUN uv sync --frozen --no-dev --no-install-project

COPY dbt_project.yml packages.yml profiles.yml ./
COPY models/ models/
COPY seeds/ seeds/
COPY tests/ tests/

RUN uv run dbt deps && uv run dbt parse --target prod

# Stage 2: Runtime
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

WORKDIR /app

COPY --from=builder /app /app

ENTRYPOINT ["uv", "run", "dbt"]
CMD ["build", "--target", "prod"]
