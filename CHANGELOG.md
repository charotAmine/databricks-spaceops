# Changelog

All notable changes to SpaceOps will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of SpaceOps CLI
- Full support for Genie space management via API
- Snapshot command to export space configurations
- Push command to create/update spaces
- Diff command to compare local vs remote
- Validate command for schema validation
- Benchmark command for accuracy testing
- Promote command for multi-environment deployment
- Support for all Genie features:
  - Data sources (tables with column configs)
  - Text instructions
  - Example queries (question + SQL)
  - Join specifications
  - SQL snippets (filters, expressions, measures)
- GitHub Actions workflows for CI/CD
- Docker support
- Cross-platform support (Linux, macOS, Windows)

## [0.1.0] - 2026-01-23

### Added
- Initial public release
- Core CLI commands: snapshot, push, diff, validate, benchmark, promote, list, delete
- Pydantic models for type-safe configuration
- Rich CLI output with tables and progress indicators
- YAML and JSON support for space definitions
- Environment-specific configuration files
- Multi-workspace promotion pipeline
- Benchmark testing framework
- Comprehensive documentation

### Technical
- Python 3.10+ support
- httpx for async-ready HTTP client
- Pydantic v2 for data validation
- Click for CLI framework
- Rich for terminal UI

[Unreleased]: https://github.com/charotAmine/databricks-spaceops/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/charotAmine/databricks-spaceops/releases/tag/v0.1.0

