#!/bin/bash
# Direct fix for linktube.indunissanka.workers.dev D1 database binding issue

set -e

echo "🔧 DIRECT FIX for D1 database binding error"
echo "=========================================="

# Check prerequisites
if ! command -v wrangler &> /dev/null; then
    echo "Installing wrangler..."
    npm install -g wrangler
fi

# Step 1: Ensure authentication
echo "🔐 Checking authentication..."
if ! wrangler whoami &> /dev/null; then
    if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
        echo "Using CLOUDFLARE_API_TOKEN for authentication..."
        mkdir -p "$HOME/.wrangler/config"
        echo "api_token = \"$CLOUDFLARE_API_TOKEN\"" > "$HOME/.wrangler/config/default.toml"
    else
        echo "ERROR: Not authenticated and no CLOUDFLARE_API_TOKEN set."
        echo "Please run: wrangler login"
        exit 1
    fi
else
    echo "✅ Already authenticated"
fi

# Step 2: Get or create database
echo "🗄️  Checking D1 databases..."
DATABASES=$(wrangler d1 list 2>&1)

if echo "$DATABASES" | grep -q "videohub_db"; then
    echo "✅ Found existing videohub_db database"
    # Extract database ID
    DB_ID=$(echo "$DATABASES" | grep -A5 "videohub_db" | grep -o 'uuid: [a-f0-9-]*' | cut -d' ' -f2)
    if [ -z "$DB_ID" ]; then
        DB_ID=$(echo "$DATABASES" | grep -A5 "videohub_db" | grep -o 'ID: [a-f0-9-]*' | cut -d' ' -f2)
    fi
    echo "Database ID: $DB_ID"
else
    echo "🆕 Creating videohub_db database..."
    CREATE_OUTPUT=$(wrangler d1 create videohub_db 2>&1)
    echo "$CREATE_OUTPUT"
    
    # Extract database ID
    DB_ID=$(echo "$CREATE_OUTPUT" | grep -o 'uuid: [a-f0-9-]*' | cut -d' ' -f2)
    if [ -z "$DB_ID" ]; then
        DB_ID=$(echo "$CREATE_OUTPUT" | grep -o 'ID: [a-f0-9-]*' | cut -d' ' -f2)
    fi
    
    if [ -z "$DB_ID" ]; then
        echo "❌ Failed to extract database ID"
        echo "Please create database manually: wrangler d1 create videohub_db"
        exit 1
    fi
    
    echo "✅ Created database with ID: $DB_ID"
    
    # Apply migrations
    echo "📋 Applying migrations..."
    wrangler d1 migrations apply videohub_db --remote
fi

if [ -z "$DB_ID" ]; then
    echo "❌ ERROR: DB_ID is empty!"
    exit 1
fi

# Step 3: Create correct configuration
echo "⚙️  Creating correct configuration..."
cat > wrangler.direct.toml << EOF
name = "linktube"
compatibility_date = "2026-02-04"
main = "src/worker.js"

[assets]
directory = "./"

[[d1_databases]]
binding = "DB"
database_name = "videohub_db"
database_id = "$DB_ID"
preview_database_id = "local"
migrations_dir = "migrations"
EOF

echo "✅ Configuration created with database_id = \"$DB_ID\""

# Step 4: Deploy
echo "🚀 Deploying with correct database binding..."
DEPLOY_OUTPUT=$(wrangler deploy --config wrangler.direct.toml 2>&1)
DEPLOY_EXIT=$?

if [ $DEPLOY_EXIT -eq 0 ]; then
    echo "✅ DEPLOYMENT SUCCESSFUL!"
    echo ""
    echo "🌐 Your app is now live at: https://linktube.indunissanka.workers.dev"
    echo "📊 API: https://linktube.indunissanka.workers.dev/api/videos"
    echo ""
    echo "🎯 Categories should work: education, gaming, music, tech, entertainment"
    
    # Clean up
    rm -f wrangler.direct.toml
else
    echo "❌ Deployment failed:"
    echo "$DEPLOY_OUTPUT"
    exit 1
fi