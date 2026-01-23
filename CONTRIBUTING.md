# Contributing to SpaceOps

Thank you for your interest in contributing to SpaceOps! This document provides guidelines and instructions for contributing.

## Development Setup

### Prerequisites

- Python 3.10 or higher
- Git
- Make (optional, but recommended)

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/charotAmine/databricks-spaceops.git
   cd databricks-spaceops
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install development dependencies**
   ```bash
   make install-dev
   # Or without make:
   pip install -e ".[dev]"
   pip install ruff mypy
   ```

4. **Run tests**
   ```bash
   make test
   # Or: pytest tests/ -v
   ```

5. **Run linting**
   ```bash
   make lint
   # Or: ruff check spaceops/
   ```

## Code Style

We use [Ruff](https://github.com/astral-sh/ruff) for linting and formatting.

### Format code
```bash
make format
# Or: ruff format spaceops/
```

### Check style
```bash
make lint
```

### Type checking
```bash
make typecheck
# Or: mypy spaceops/
```

## Testing

### Run all tests
```bash
make test
```

### Run with coverage
```bash
make test-cov
```

### Run specific tests
```bash
pytest tests/test_models.py -v
pytest tests/ -k "test_diff" -v
```

## Pull Request Process

1. **Fork the repository** and create your branch from `main`
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make your changes** with appropriate tests

3. **Ensure all checks pass**
   ```bash
   make lint test
   ```

4. **Commit with clear messages**
   ```bash
   git commit -m "feat: add new command for X"
   ```
   
   We follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation
   - `refactor:` - Code refactoring
   - `test:` - Adding tests
   - `chore:` - Maintenance

5. **Push and create a PR**
   ```bash
   git push origin feature/my-feature
   ```

6. **Fill out the PR template** with:
   - Description of changes
   - Related issues
   - Testing performed

## Project Structure

```
spaceops/
├── spaceops/
│   ├── __init__.py      # Package version
│   ├── cli.py           # Click CLI commands
│   ├── client.py        # Databricks API client
│   ├── models.py        # Pydantic data models
│   ├── diff.py          # Configuration diff utilities
│   └── benchmark.py     # Benchmark test runner
├── tests/
│   ├── test_models.py
│   ├── test_diff.py
│   └── ...
├── samples/             # Example configurations
├── .github/workflows/   # CI/CD pipelines
└── ...
```

## Adding New Features

### Adding a new CLI command

1. Add the command function in `spaceops/cli.py`:
   ```python
   @main.command()
   @click.argument("arg")
   @click.option("--option", help="...")
   def my_command(arg, option):
       """Command description."""
       # Implementation
   ```

2. Add tests in `tests/test_cli.py`

3. Update `README.md` with usage examples

### Adding new models

1. Add Pydantic models in `spaceops/models.py`
2. Add tests in `tests/test_models.py`
3. Update serialization if needed

## Release Process

Releases are automated via GitHub Actions when a version tag is pushed.

### Creating a release

1. **Bump version**
   ```bash
   make bump-patch  # 0.1.0 -> 0.1.1
   make bump-minor  # 0.1.0 -> 0.2.0
   make bump-major  # 0.1.0 -> 1.0.0
   ```

2. **Update CHANGELOG.md** with release notes

3. **Commit and tag**
   ```bash
   git add -A
   git commit -m "chore: release v0.2.0"
   make tag
   git push origin main --tags
   ```

4. **GitHub Actions** will automatically:
   - Run tests on all platforms
   - Build distribution packages
   - Publish to PyPI
   - Create GitHub Release with binaries

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/charotAmine/databricks-spaceops/issues)
- **Discussions**: [GitHub Discussions](https://github.com/charotAmine/databricks-spaceops/discussions)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

