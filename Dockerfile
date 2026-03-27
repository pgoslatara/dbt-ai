# Stage 1: Build
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY dbt_project.yml packages.yml package-lock.yml profiles.yml ./
COPY macros/ macros/
COPY models/ models/
COPY seeds/ seeds/
COPY tests/ tests/

RUN uv run dbt deps && uv run dbt parse --target prod

# Stage 2: Runtime
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

WORKDIR /app

COPY --from=builder /app /app

RUN useradd -r -m -s /usr/sbin/nologin dbt && chown -R dbt:dbt /app
USER dbt

ENTRYPOINT ["uv", "run", "dbt"]
CMD ["build", "--target", "prod"]
