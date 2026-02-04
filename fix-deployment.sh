#!/bin/bash
# Fix deployment for linktube.indunissanka.workers.dev
# This script fixes the D1 database binding issue

set -e

echo "🔧 Fixing deployment for linktube.indunissanka.workers.dev"

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "Installing wrangler..."
    npm install -g wrangler
fi

# Check authentication
if ! wrangler whoami &> /dev/null; then
    echo "Please log in to Cloudflare..."
    wrangler login
fi

# Get current database ID or create new one
echo "📦 Checking D1 database..."

# Try with jq first, then grep fallback
if command -v jq &> /dev/null; then
    DB_ID=$(wrangler d1 list --json 2>/dev/null | jq -r '.[] | select(.name == "videohub_db") | .uuid' 2>/dev/null || true)
else
    DB_ID=$(wrangler d1 list 2>/dev/null | grep -A5 "videohub_db" | grep -o 'uuid: [a-f0-9-]*' | cut -d' ' -f2 || true)
fi

if [ -z "$DB_ID" ]; then
    echo "🆕 Creating D1 database 'videohub_db'..."
    DB_CREATE_OUTPUT=$(wrangler d1 create videohub_db 2>&1)
    DB_ID=$(echo "$DB_CREATE_OUTPUT" | grep -o 'uuid: [a-f0-9-]*' | cut -d' ' -f2)
    
    if [ -z "$DB_ID" ]; then
        DB_ID=$(echo "$DB_CREATE_OUTPUT" | grep -o 'ID: [a-f0-9-]*' | cut -d' ' -f2)
    fi
    
    if [ -z "$DB_ID" ]; then
        echo "❌ Failed to create database. Please create manually: wrangler d1 create videohub_db"
        exit 1
    fi
    
    echo "✅ Created database with ID: $DB_ID"
    
    # Apply migrations
    echo "📋 Applying database migrations..."
    wrangler d1 migrations apply videohub_db --remote
else
    echo "✅ Found existing database: $DB_ID"
fi

# Create fixed configuration
echo "⚙️ Creating fixed configuration..."
cat > wrangler.fixed.toml << EOF
# Fixed configuration for linktube
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

# Deploy with fixed configuration
echo "🚀 Deploying with fixed configuration..."
wrangler deploy --config wrangler.fixed.toml

echo "✅ Deployment fixed!"
echo "🌐 Your app should now work at: https://linktube.indunissanka.workers.dev"
echo "📊 API endpoint: https://linktube.indunissanka.workers.dev/api/videos"

# Clean up
rm -f wrangler.fixed.toml

echo ""
echo "🔧 If issues persist, check Cloudflare dashboard for Worker logs."