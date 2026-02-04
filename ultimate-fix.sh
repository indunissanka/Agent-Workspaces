#!/bin/bash
# Ultimate fix for D1 database binding error
# Creates wrangler.toml with actual database ID (not variable)

set -e

echo "🔨 ULTIMATE FIX: Creating wrangler.toml with actual database ID"
echo "=============================================================="

# Step 1: Check if we can authenticate
echo "🔐 Checking authentication..."
if ! command -v wrangler &> /dev/null; then
    npm install -g wrangler
fi

if ! wrangler whoami &> /dev/null; then
    if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
        mkdir -p "$HOME/.wrangler/config"
        echo "api_token = \"$CLOUDFLARE_API_TOKEN\"" > "$HOME/.wrangler/config/default.toml"
        sleep 2
    else
        echo "ERROR: Not authenticated. Set CLOUDFLARE_API_TOKEN or run wrangler login"
        exit 1
    fi
fi

# Step 2: Get database ID (create if needed)
echo "🗄️  Getting database ID..."
DB_OUTPUT=$(wrangler d1 list 2>&1)

if echo "$DB_OUTPUT" | grep -q "videohub_db"; then
    echo "✅ Found existing videohub_db"
    # Extract ID - try multiple patterns
    DB_ID=$(echo "$DB_OUTPUT" | grep -i "videohub_db" -A5 | grep -i "uuid:" | cut -d' ' -f2)
    [ -z "$DB_ID" ] && DB_ID=$(echo "$DB_OUTPUT" | grep -i "videohub_db" -A5 | grep -i "id:" | cut -d' ' -f2)
    [ -z "$DB_ID" ] && DB_ID=$(echo "$DB_OUTPUT" | grep -o '[a-f0-9]\{8\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{12\}' | head -1)
else
    echo "🆕 Creating videohub_db database..."
    CREATE_OUTPUT=$(wrangler d1 create videohub_db 2>&1)
    echo "$CREATE_OUTPUT"
    
    DB_ID=$(echo "$CREATE_OUTPUT" | grep -i "uuid:" | cut -d' ' -f2)
    [ -z "$DB_ID" ] && DB_ID=$(echo "$CREATE_OUTPUT" | grep -i "id:" | cut -d' ' -f2)
    [ -z "$DB_ID" ] && DB_ID=$(echo "$CREATE_OUTPUT" | grep -o '[a-f0-9]\{8\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{12\}' | head -1)
    
    if [ -z "$DB_ID" ]; then
        echo "❌ Could not extract database ID"
        echo "Manual step required:"
        echo "1. Run: wrangler d1 create videohub_db"
        echo "2. Copy the UUID (looks like: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
        echo "3. Edit wrangler.toml and replace database_id with that UUID"
        exit 1
    fi
    
    echo "✅ Created database with ID: $DB_ID"
    
    # Apply migrations
    echo "📋 Applying migrations..."
    wrangler d1 migrations apply videohub_db --remote || echo "⚠️  Migration warning (may already be applied)"
fi

if [ -z "$DB_ID" ]; then
    echo "❌ FATAL: DB_ID is empty"
    exit 1
fi

echo "📋 Database ID: $DB_ID"

# Step 3: BACKUP original wrangler.toml and create new one with actual ID
echo "💾 Backing up original wrangler.toml..."
cp wrangler.toml wrangler.toml.backup 2>/dev/null || true

echo "⚙️  Creating new wrangler.toml with actual database ID..."
cat > wrangler.toml << EOF
# wrangler.toml
# Configuration for YouTube Video Listing App (linktube)
# ULTIMATE FIX: Contains actual database ID, not variable

name = "linktube"
compatibility_date = "2026-02-04"
main = "src/worker.js"

[assets]
directory = "./"

# D1 Database Configuration
# ACTUAL DATABASE ID (not variable)
[[d1_databases]]
binding = "DB"
database_name = "videohub_db"
database_id = "$DB_ID"
preview_database_id = "local"
migrations_dir = "migrations"
EOF

echo "✅ Created wrangler.toml with database_id = \"$DB_ID\""

# Step 4: Deploy
echo "🚀 Deploying with actual database ID..."
if wrangler deploy; then
    echo "🎉 SUCCESS! Deployment completed."
    echo ""
    echo "🌐 Your app is now live: https://linktube.indunissanka.workers.dev"
    echo "📊 API: https://linktube.indunissanka.workers.dev/api/videos"
    echo ""
    echo "🔄 To revert: mv wrangler.toml.backup wrangler.toml"
else
    echo "❌ Deployment failed even with actual database ID."
    echo ""
    echo "🔧 Last resort: Try different Worker name"
    echo "Edit wrangler.toml and change 'name = \"linktube\"' to 'name = \"linktube2\"'"
    echo "Then run: wrangler deploy"
fi