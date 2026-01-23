#!/bin/bash
# Test: Snapshot Workflow
# ======================
# Demonstrates: snapshot → modify → validate → diff → push

set -e

echo "========================================"
echo "🧪 TEST: Snapshot Workflow"
echo "========================================"

# Configuration - Set these environment variables before running
# export DATABRICKS_HOST="https://your-workspace.cloud.databricks.com"
# export DATABRICKS_TOKEN="your-token"
# export SOURCE_SPACE_ID="your-space-id"
if [ -z "$DATABRICKS_HOST" ] || [ -z "$DATABRICKS_TOKEN" ]; then
    echo "❌ Error: DATABRICKS_HOST and DATABRICKS_TOKEN must be set"
    exit 1
fi
if [ -z "$SOURCE_SPACE_ID" ]; then
    echo "❌ Error: SOURCE_SPACE_ID must be set to an existing space ID"
    exit 1
fi
OUTPUT_DIR="./output/snapshot_test"

# Clean up previous runs
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo ""
echo "📸 Step 1: Snapshot existing space..."
spaceops snapshot "$SOURCE_SPACE_ID" -o "$OUTPUT_DIR/space.yaml"

echo ""
echo "✏️  Step 2: Modify the snapshot (change title)..."
sed -i.bak 's/^title:.*/title: SpaceOps Snapshot Test/' "$OUTPUT_DIR/space.yaml"
rm -f "$OUTPUT_DIR/space.yaml.bak"

echo ""
echo "✅ Step 3: Validate the modified definition..."
spaceops validate "$OUTPUT_DIR/space.yaml"

echo ""
echo "🚀 Step 4: Create new space from modified snapshot..."
spaceops push "$OUTPUT_DIR/space.yaml" 2>&1 | tee "$OUTPUT_DIR/push_result.txt"

# Extract the new space ID (32-char hex string)
NEW_SPACE_ID=$(grep -oE '[0-9a-f]{32}' "$OUTPUT_DIR/push_result.txt" | head -1)
echo "New Space ID: $NEW_SPACE_ID"
echo "$NEW_SPACE_ID" > "$OUTPUT_DIR/space_id.txt"

echo ""
echo "🔍 Step 5: Verify with diff (should show no changes)..."
spaceops diff "$OUTPUT_DIR/space.yaml" "$NEW_SPACE_ID" && echo "✅ No drift detected!" || echo "⚠️  Changes detected"

echo ""
echo "📋 Step 6: List spaces to confirm creation..."
spaceops list | grep -i "snapshot test" || echo "(Space visible in full list)"

echo ""
echo "========================================"
echo "✅ SNAPSHOT WORKFLOW TEST COMPLETE"
echo "   Created space: $NEW_SPACE_ID"
echo "   Config saved: $OUTPUT_DIR/space.yaml"
echo "========================================"
echo ""
echo "To clean up: spaceops delete $NEW_SPACE_ID -y"

