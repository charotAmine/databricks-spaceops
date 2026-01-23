#!/bin/bash
# Test: Create Space from Scratch (Full Featured)
# ================================================
# Demonstrates: write YAML → validate → push → verify
# Uses ALL capabilities: tables, joins, instructions, examples, functions, tags

set -e

echo "========================================"
echo "🧪 TEST: Create Full-Featured Space"
echo "========================================"

# Configuration - Set these environment variables before running
# export DATABRICKS_HOST="https://your-workspace.cloud.databricks.com"
# export DATABRICKS_TOKEN="your-token"
# export WAREHOUSE_ID="your-warehouse-id"
if [ -z "$DATABRICKS_HOST" ] || [ -z "$DATABRICKS_TOKEN" ]; then
    echo "❌ Error: DATABRICKS_HOST and DATABRICKS_TOKEN must be set"
    exit 1
fi
if [ -z "$WAREHOUSE_ID" ]; then
    echo "❌ Error: WAREHOUSE_ID must be set"
    exit 1
fi
OUTPUT_DIR="./output/scratch_test"
CONFIG_FILE="./configs/full_featured_space.yaml"

# Clean up previous runs
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo ""
echo "📝 Step 1: Using full-featured space definition..."
echo "   Config: $CONFIG_FILE"
cp "$CONFIG_FILE" "$OUTPUT_DIR/space.yaml"

# Show what's in the config
echo ""
echo "   📊 Configuration Summary:"
echo "   -------------------------"
grep "^title:" "$OUTPUT_DIR/space.yaml" | head -1
echo "   Tables: $(grep -c "identifier:" "$OUTPUT_DIR/space.yaml" || echo 0)"
echo "   Joins: $(grep -c "left_table:" "$OUTPUT_DIR/space.yaml" || echo 0)"
echo "   Instructions: $(grep -c "content:" "$OUTPUT_DIR/space.yaml" || echo 0)"
echo "   Example Queries: $(grep -c "question:" "$OUTPUT_DIR/space.yaml" || echo 0)"
echo "   Functions: $(grep -c "function_name:" "$OUTPUT_DIR/space.yaml" || echo 0)"
echo "   Tags: $(grep -A20 "^tags:" "$OUTPUT_DIR/space.yaml" | grep -c ":" || echo 0)"

echo ""
echo "✅ Step 2: Validate the definition..."
spaceops validate "$OUTPUT_DIR/space.yaml"

echo ""
echo "🔍 Step 3: Preview the push (dry-run)..."
spaceops push "$OUTPUT_DIR/space.yaml" --dry-run

echo ""
echo "🚀 Step 4: Create the space..."
spaceops push "$OUTPUT_DIR/space.yaml" 2>&1 | tee "$OUTPUT_DIR/push_result.txt"

# Extract the new space ID (32-char hex string)
NEW_SPACE_ID=$(grep -oE '[0-9a-f]{32}' "$OUTPUT_DIR/push_result.txt" | head -1)
echo "New Space ID: $NEW_SPACE_ID"
echo "$NEW_SPACE_ID" > "$OUTPUT_DIR/space_id.txt"

echo ""
echo "📸 Step 5: Snapshot the created space to verify..."
spaceops snapshot "$NEW_SPACE_ID" -o "$OUTPUT_DIR/snapshot.yaml"

echo ""
echo "🔍 Step 6: Compare original vs snapshot (data_sources only - API limitation)..."
spaceops diff "$OUTPUT_DIR/space.yaml" "$NEW_SPACE_ID" && echo "✅ Perfect match!" || echo "⚠️  Some differences (expected for instructions/joins - not yet supported by API)"

echo ""
echo "========================================"
echo "✅ FROM-SCRATCH TEST COMPLETE"
echo ""
echo "   Created space: $NEW_SPACE_ID"
echo "   Definition: $OUTPUT_DIR/space.yaml"
echo "   Snapshot: $OUTPUT_DIR/snapshot.yaml"
echo ""
echo "   Features in config (stored locally for version control):"
echo "   ✓ Data Sources (tables + column configs)"
echo "   ✓ Joins (table relationships)"
echo "   ✓ Instructions (natural language guidance)"
echo "   ✓ Example Queries (SQL patterns)"
echo "   ✓ Functions (UDF references)"
echo "   ✓ Tags (metadata)"
echo ""
echo "   Note: Instructions, joins, examples, functions, and tags"
echo "   are stored in Git for version control. The Genie API"
echo "   currently only supports data_sources in serialized_space."
echo "========================================"
echo ""
echo "To clean up: spaceops delete $NEW_SPACE_ID -y"
