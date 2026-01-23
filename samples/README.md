# SpaceOps Sample Tests

This folder contains sample tests demonstrating all SpaceOps capabilities.

## Setup

Set your Databricks credentials before running tests:

```bash
export DATABRICKS_HOST="https://your-workspace.cloud.databricks.com"
export DATABRICKS_TOKEN="your-personal-access-token"
export WAREHOUSE_ID="your-warehouse-id"
export SOURCE_SPACE_ID="existing-space-id"  # For snapshot test
```

## Tests

| Script | Description |
|--------|-------------|
| `test_snapshot_workflow.sh` | Clone existing space via snapshot → modify → push |
| `test_from_scratch.sh` | Create a brand new space from YAML definition |
| `test_full_lifecycle.sh` | Complete lifecycle: create → update → diff → delete |

## Run Individual Tests

```bash
cd samples

# Test full lifecycle (auto-cleans up)
./test_full_lifecycle.sh

# Test snapshot workflow
./test_snapshot_workflow.sh

# Test from scratch
./test_from_scratch.sh
```

## Run All Tests

```bash
cd samples
./run_all_tests.sh
```

## Cleanup

Test scripts that create spaces will print cleanup commands at the end:

```bash
spaceops delete <space_id> -y
```
