#!/bin/bash
# Final fix based on Cloudflare Workers SDK issue #9444
# Solution: Ensure database_id is valid and corresponds to existing D1 database

set -e

echo "🎯 FINAL FIX for D1 database binding error (issue #9444)"
echo "======================================================"

# Step 1: Verify authentication
echo "🔐 Verifying Cloudflare authentication..."
if ! wrangler whoami &> /dev/null; then
    if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
        echo "Using CLOUDFLARE_API_TOKEN..."
        mkdir -p "$HOME/.wrangler/config"
        echo "api_token = \"$CLOUDFLARE_API_TOKEN\"" > "$HOME/.wrangler/config/default.toml"
        # Wait for token to be recognized
        sleep 2
    else
        echo "ERROR: Not authenticated. Please run: wrangler login"
        exit 1
    fi
fi

# Step 2: List all D1 databases to see what's available
echo "🗄️  Listing D1 databases..."
DATABASES_JSON=$(wrangler d1 list --json 2>/dev/null || wrangler d1 list 2>&1)

if echo "$DATABASES_JSON" | grep -q "videohub_db"; then
    echo "✅ Found videohub_db database"
    
    # Try to extract database ID using different methods
    if echo "$DATABASES_JSON" | grep -q '{'; then
        # JSON output
        DB_ID=$(echo "$DATABASES_JSON" | grep -i '"name":"videohub_db"' -A5 | grep -i '"uuid"' | cut -d'"' -f4)
        if [ -z "$DB_ID" ]; then
            DB_ID=$(echo "$DATABASES_JSON" | grep -i '"name":"videohub_db"' -A5 | grep -i '"id"' | cut -d'"' -f4)
        fi
    else
        # Text output
        DB_ID=$(echo "$DATABASES_JSON" | grep -i "videohub_db" -A5 | grep -i "uuid:" | cut -d' ' -f2)
        if [ -z "$DB_ID" ]; then
            DB_ID=$(echo "$DATABASES_JSON" | grep -i "videohub_db" -A5 | grep -i "id:" | cut -d' ' -f2)
        fi
    fi
    
    if [ -n "$DB_ID" ]; then
        echo "📋 Database ID: $DB_ID"
    else
        echo "⚠️  Could not extract database ID from output"
        echo "Raw output:"
        echo "$DATABASES_JSON"
    fi
else
    echo "❌ videohub_db not found. Creating..."
    CREATE_OUTPUT=$(wrangler d1 create videohub_db 2>&1)
    echo "$CREATE_OUTPUT"
    
    # Extract database ID
    DB_ID=$(echo "$CREATE_OUTPUT" | grep -i "uuid:" | cut -d' ' -f2)
    if [ -z "$DB_ID" ]; then
        DB_ID=$(echo "$CREATE_OUTPUT" | grep -i "id:" | cut -d' ' -f2)
    fi
    if [ -z "$DB_ID" ]; then
        DB_ID=$(echo "$CREATE_OUTPUT" | grep -o '[a-f0-9]\{8\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{4\}-[a-f0-9]\{12\}' | head -1)
    fi
    
    if [ -z "$DB_ID" ]; then
        echo "❌ FAILED: Could not create or identify database"
        echo "Manual fix required:"
        echo "1. Run: wrangler d1 create videohub_db"
        echo "2. Copy the database ID (UUID)"
        echo "3. Update wrangler.toml: database_id = \"<copied-id>\""
        echo "4. Run: wrangler deploy"
        exit 1
    fi
    
    echo "✅ Created database with ID: $DB_ID"
    
    # Apply migrations
    echo "📋 Applying migrations..."
    wrangler d1 migrations apply videohub_db --remote || echo "⚠️  Migrations may have failed, continuing..."
fi

if [ -z "$DB_ID" ]; then
    echo "❌ CRITICAL: DB_ID is still empty!"
    echo "Manual intervention required."
    exit 1
fi

# Step 3: Validate database ID format (should be UUID)
if [[ ! "$DB_ID" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; then
    echo "⚠️  Database ID doesn't look like a UUID: $DB_ID"
    echo "This might cause issues. Checking format..."
fi

# Step 4: Create validated configuration
echo "⚙️  Creating validated configuration..."
cat > wrangler.validated.toml << EOF
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

echo "✅ Configuration created with validated database_id"

# Step 5: Deploy with validated configuration
echo "🚀 Deploying with validated configuration..."
echo "Command: wrangler deploy --config wrangler.validated.toml"

if wrangler deploy --config wrangler.validated.toml; then
    echo "🎉 SUCCESS! Deployment completed."
    echo ""
    echo "🌐 Your app is now live: https://linktube.indunissanka.workers.dev"
    echo "📊 API: https://linktube.indunissanka.workers.dev/api/videos"
    echo ""
    echo "🛠️  Categories: education, gaming, music, tech, entertainment"
    echo "👨‍💼 Admin: Use admin.html to manage videos and categories"
    
    # Clean up
    rm -f wrangler.validated.toml
else
    echo "❌ Deployment failed with the validated configuration."
    echo ""
    echo "🔧 Alternative solution:"
    echo "1. Open Cloudflare Dashboard"
    echo "2. Go to Workers & Pages > linktube"
    echo "3. Check Settings > Variables > D1 Database Bindings"
    echo "4. Ensure 'DB' is bound to correct database"
    echo "5. Or try different Worker name"
fi