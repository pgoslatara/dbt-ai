.DEFAULT_GOAL := help

.PHONY: clean format lint run setup

clean: ## Remove build artifacts
	rm -rf target/ dbt_packages/ logs/

format: ## Format code
	uv run ruff check --fix .
	uv run ruff format .
	uv run sqlfmt .
	uv run yamlfix .

lint: ## Run all linters
	uv run prek run -a

setup: ## Install dependencies and set up project
	uv sync
	uv run dbt deps
	uv run prek install
