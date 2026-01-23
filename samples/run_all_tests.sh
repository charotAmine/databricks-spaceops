#!/bin/bash
# Run All SpaceOps Tests
# ======================

set -e

cd "$(dirname "$0")"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           SpaceOps Test Suite                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Configuration - Set these environment variables before running
if [ -z "$DATABRICKS_HOST" ] || [ -z "$DATABRICKS_TOKEN" ]; then
    echo "❌ Error: DATABRICKS_HOST and DATABRICKS_TOKEN must be set"
    echo ""
    echo "   export DATABRICKS_HOST='https://your-workspace.cloud.databricks.com'"
    echo "   export DATABRICKS_TOKEN='your-token'"
    echo "   export WAREHOUSE_ID='your-warehouse-id'"
    echo "   export SOURCE_SPACE_ID='existing-space-id'  # For snapshot test"
    exit 1
fi

# Track results
PASSED=0
FAILED=0
CREATED_SPACES=()

cleanup() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🧹 CLEANUP"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for space_id_file in ./output/*/space_id.txt; do
        if [ -f "$space_id_file" ]; then
            SPACE_ID=$(cat "$space_id_file")
            echo "Deleting space: $SPACE_ID"
            spaceops delete "$SPACE_ID" -y 2>/dev/null || true
        fi
    done
    echo "✅ Cleanup complete"
}

# Trap to cleanup on exit
trap cleanup EXIT

run_test() {
    local test_name=$1
    local test_script=$2
    
    echo ""
    echo "┌──────────────────────────────────────────────────────────────┐"
    echo "│ Running: $test_name"
    echo "└──────────────────────────────────────────────────────────────┘"
    
    if bash "$test_script"; then
        echo "✅ $test_name PASSED"
        ((PASSED++))
    else
        echo "❌ $test_name FAILED"
        ((FAILED++))
    fi
}

# Create output directory
mkdir -p ./output

# ============================================================
# TEST 1: Full Lifecycle (includes cleanup)
# ============================================================
run_test "Full Lifecycle Test" "./test_full_lifecycle.sh"

# ============================================================
# TEST 2: Snapshot Workflow
# ============================================================
run_test "Snapshot Workflow Test" "./test_snapshot_workflow.sh"

# ============================================================
# TEST 3: From Scratch
# ============================================================
run_test "From Scratch Test" "./test_from_scratch.sh"

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    TEST RESULTS                              ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  ✅ Passed: $PASSED                                            ║"
echo "║  ❌ Failed: $FAILED                                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "🎉 All tests passed!"
    exit 0
else
    echo ""
    echo "⚠️  Some tests failed. Check output above."
    exit 1
fi

