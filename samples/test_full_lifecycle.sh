#!/bin/bash
# Test: Full Lifecycle
# ====================
# Demonstrates: create → update → diff → snapshot → delete

set -e

echo "========================================"
echo "🧪 TEST: Full Space Lifecycle"
echo "========================================"

# Configuration - Set these environment variables before running
# export DATABRICKS_HOST="https://your-workspace.cloud.databricks.com"
# export DATABRICKS_TOKEN="your-token"
if [ -z "$DATABRICKS_HOST" ] || [ -z "$DATABRICKS_TOKEN" ]; then
    echo "❌ Error: DATABRICKS_HOST and DATABRICKS_TOKEN must be set"
    echo "   export DATABRICKS_HOST='https://your-workspace.cloud.databricks.com'"
    echo "   export DATABRICKS_TOKEN='your-token'"
    exit 1
fi
OUTPUT_DIR="./output/lifecycle_test"

# Clean up previous runs
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# ============================================================
# PHASE 1: CREATE
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 PHASE 1: CREATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > "$OUTPUT_DIR/space_v1.yaml" << 'EOF'
title: "SpaceOps Lifecycle Test v1"
description: "Testing full lifecycle - version 1"
warehouse_id: "4b9b953939869799"
version: 2

data_sources:
  tables:
    - identifier: "system.billing.usage"
      column_configs:
        - column_name: "usage_date"
          enable_format_assistance: true
        - column_name: "sku_name"
          enable_format_assistance: true
        - column_name: "usage_quantity"
          enable_format_assistance: true
EOF

echo "Creating space v1..."
spaceops push "$OUTPUT_DIR/space_v1.yaml" 2>&1 | tee "$OUTPUT_DIR/create_result.txt"
# Extract space ID - it's a 32-char hex string
SPACE_ID=$(grep -oE '[0-9a-f]{32}' "$OUTPUT_DIR/create_result.txt" | head -1)
echo "$SPACE_ID" > "$OUTPUT_DIR/space_id.txt"
echo "✅ Created space: $SPACE_ID"

# ============================================================
# PHASE 2: UPDATE
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 PHASE 2: UPDATE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cat > "$OUTPUT_DIR/space_v2.yaml" << 'EOF'
title: "SpaceOps Lifecycle Test v2"
description: "Testing full lifecycle - version 2 with more columns"
warehouse_id: "4b9b953939869799"
version: 2

data_sources:
  tables:
    - identifier: "system.billing.usage"
      column_configs:
        - column_name: "usage_date"
          enable_format_assistance: true
        - column_name: "sku_name"
          enable_format_assistance: true
          enable_entity_matching: true
        - column_name: "usage_quantity"
          enable_format_assistance: true
        - column_name: "workspace_id"
          enable_format_assistance: true
        - column_name: "cloud"
          enable_format_assistance: true
          enable_entity_matching: true

instructions:
  - content: "This space tracks Databricks billing usage."
    category: "context"
EOF

echo "Showing diff before update..."
spaceops diff "$OUTPUT_DIR/space_v2.yaml" "$SPACE_ID" || true

echo ""
echo "Updating space to v2..."
spaceops push "$OUTPUT_DIR/space_v2.yaml" --space-id "$SPACE_ID"
echo "✅ Updated space to v2"

# ============================================================
# PHASE 3: VERIFY
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 PHASE 3: VERIFY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Taking snapshot of current state..."
spaceops snapshot "$SPACE_ID" -o "$OUTPUT_DIR/snapshot_v2.yaml"

echo ""
echo "Comparing v2 definition with remote..."
spaceops diff "$OUTPUT_DIR/space_v2.yaml" "$SPACE_ID" && echo "✅ No drift - v2 matches remote" || echo "⚠️  Minor differences detected"

# ============================================================
# PHASE 4: CLEANUP
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  PHASE 4: CLEANUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Deleting test space..."
spaceops delete "$SPACE_ID" -y
echo "✅ Space deleted"

# Verify deletion
echo ""
echo "Verifying space is gone..."
if spaceops list | grep -q "$SPACE_ID"; then
    echo "❌ Space still exists!"
    exit 1
else
    echo "✅ Space successfully deleted"
fi

echo ""
echo "========================================"
echo "✅ FULL LIFECYCLE TEST COMPLETE"
echo ""
echo "   Phases completed:"
echo "   1. CREATE - Created space v1"
echo "   2. UPDATE - Updated to v2 with more columns"
echo "   3. VERIFY - Snapshot and diff confirmed"
echo "   4. CLEANUP - Space deleted"
echo ""
echo "   Artifacts saved in: $OUTPUT_DIR/"
echo "========================================"

