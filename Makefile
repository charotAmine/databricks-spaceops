# SpaceOps Makefile
# Common development and release tasks

.PHONY: help install install-dev test lint format build clean release docker

PYTHON := python3
VERSION := $(shell grep -m1 'version' pyproject.toml | cut -d'"' -f2)

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install:  ## Install package
	$(PYTHON) -m pip install -e .

install-dev:  ## Install package with dev dependencies
	$(PYTHON) -m pip install -e ".[dev]"
	$(PYTHON) -m pip install ruff mypy build twine

test:  ## Run tests
	pytest tests/ -v

test-cov:  ## Run tests with coverage
	pytest tests/ --cov=spaceops --cov-report=html --cov-report=term

lint:  ## Run linter
	ruff check spaceops/
	ruff format --check spaceops/

format:  ## Format code
	ruff format spaceops/
	ruff check --fix spaceops/

typecheck:  ## Run type checker
	mypy spaceops/ --ignore-missing-imports

build:  ## Build distribution packages
	$(PYTHON) -m build
	twine check dist/*

clean:  ## Clean build artifacts
	rm -rf build/ dist/ *.egg-info/ .pytest_cache/ .coverage htmlcov/ .mypy_cache/ .ruff_cache/
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

docker:  ## Build Docker image
	docker build -t spaceops:$(VERSION) -t spaceops:latest .

docker-run:  ## Run Docker container
	docker run --rm -it -v $(PWD)/spaces:/workspace/spaces spaceops:latest

# Release tasks
bump-patch:  ## Bump patch version (0.1.0 -> 0.1.1)
	@echo "Current version: $(VERSION)"
	@NEW_VERSION=$$(echo $(VERSION) | awk -F. '{print $$1"."$$2"."$$3+1}') && \
	sed -i.bak "s/version = \"$(VERSION)\"/version = \"$$NEW_VERSION\"/" pyproject.toml && \
	sed -i.bak "s/__version__ = \"$(VERSION)\"/__version__ = \"$$NEW_VERSION\"/" spaceops/__init__.py && \
	rm -f pyproject.toml.bak spaceops/__init__.py.bak && \
	echo "Bumped to: $$NEW_VERSION"

bump-minor:  ## Bump minor version (0.1.0 -> 0.2.0)
	@echo "Current version: $(VERSION)"
	@NEW_VERSION=$$(echo $(VERSION) | awk -F. '{print $$1"."$$2+1".0"}') && \
	sed -i.bak "s/version = \"$(VERSION)\"/version = \"$$NEW_VERSION\"/" pyproject.toml && \
	sed -i.bak "s/__version__ = \"$(VERSION)\"/__version__ = \"$$NEW_VERSION\"/" spaceops/__init__.py && \
	rm -f pyproject.toml.bak spaceops/__init__.py.bak && \
	echo "Bumped to: $$NEW_VERSION"

bump-major:  ## Bump major version (0.1.0 -> 1.0.0)
	@echo "Current version: $(VERSION)"
	@NEW_VERSION=$$(echo $(VERSION) | awk -F. '{print $$1+1".0.0"}') && \
	sed -i.bak "s/version = \"$(VERSION)\"/version = \"$$NEW_VERSION\"/" pyproject.toml && \
	sed -i.bak "s/__version__ = \"$(VERSION)\"/__version__ = \"$$NEW_VERSION\"/" spaceops/__init__.py && \
	rm -f pyproject.toml.bak spaceops/__init__.py.bak && \
	echo "Bumped to: $$NEW_VERSION"

tag:  ## Create git tag for current version
	git tag -a "v$(VERSION)" -m "Release v$(VERSION)"
	@echo "Created tag: v$(VERSION)"
	@echo "Push with: git push origin v$(VERSION)"

release: clean lint test build  ## Full release process (lint, test, build)
	@echo "Ready to release v$(VERSION)"
	@echo "1. git add -A && git commit -m 'Release v$(VERSION)'"
	@echo "2. make tag"
	@echo "3. git push origin main --tags"

