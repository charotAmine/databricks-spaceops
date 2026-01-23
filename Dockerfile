# SpaceOps Docker Image
# Multi-stage build for minimal image size

# Build stage
FROM python:3.11-slim as builder

WORKDIR /app

# Install build dependencies
RUN pip install --no-cache-dir build

# Copy source
COPY . .

# Build wheel
RUN python -m build --wheel

# Runtime stage
FROM python:3.11-slim

LABEL org.opencontainers.image.title="SpaceOps"
LABEL org.opencontainers.image.description="CI/CD for Databricks Genie spaces"
LABEL org.opencontainers.image.source="https://github.com/charotAmine/databricks-spaceops"

WORKDIR /app

# Install the built wheel
COPY --from=builder /app/dist/*.whl /tmp/
RUN pip install --no-cache-dir /tmp/*.whl && rm /tmp/*.whl

# Create non-root user
RUN useradd --create-home --shell /bin/bash spaceops
USER spaceops

# Set working directory for spaces
WORKDIR /workspace

# Default command
ENTRYPOINT ["spaceops"]
CMD ["--help"]

