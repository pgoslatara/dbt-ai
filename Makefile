.DEFAULT_GOAL := help

.PHONY: clean docs format freshness help lint run setup slides slides-pdf slides-watch test

clean: ## Remove build artifacts
	rm -rf target/ dbt_packages/ logs/ presentation/dist/

docs: ## Generate dbt docs
	uv run dbt docs generate
	uv run dbt docs serve

format: ## Format code
	uv run ruff check --fix .
	uv run ruff format .
	uv run sqlfmt .
	uv run yamlfix .

freshness: ## Check source freshness
	uv run dbt source freshness

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint: ## Run all linters
	uv run prek run -a
	uv run pytest

run: ## Run dbt build
	uv run dbt build

setup: ## Install dependencies and set up project
	uv sync
	uv run dbt deps
	uv run prek install

slides: ## Build presentation HTML
	npx @marp-team/marp-cli presentation/slides.md -o presentation/dist/slides.html

slides-pdf: ## Build presentation PDF
	npx @marp-team/marp-cli --pdf presentation/slides.md -o presentation/dist/slides.pdf

slides-watch: ## Watch and rebuild presentation
	npx @marp-team/marp-cli -w presentation/slides.md

test: ## Run dbt and Python tests
	uv run dbt test
	uv run pytest --no-header -q || [ $$? -eq 5 ]
