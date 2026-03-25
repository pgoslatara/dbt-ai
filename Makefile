.DEFAULT_GOAL := help

.PHONY: clean format freshness lint run setup

clean: ## Remove build artifacts
	rm -rf target/ dbt_packages/ logs/

format: ## Format code
	uv run ruff check --fix .
	uv run ruff format .
	uv run sqlfmt .
	uv run yamlfix .

freshness: ## Check source freshness
	uv run dbt source freshness

lint: ## Run all linters
	uv run prek run -a
	uv run pytest || [ $$? -eq 5 ]

setup: ## Install dependencies and set up project
	uv sync
	uv run dbt deps
	uv run prek install
