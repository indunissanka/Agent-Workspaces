#!/bin/bash
# Deployment script for YouTube Video Listing app (linktube)
# This script handles D1 database creation and deployment to Cloudflare Workers

set -e  # Exit on error

echo "🚀 Starting deployment process..."

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "Installing wrangler..."
    npm install -g wrangler
fi

# Login if not already logged in
if ! wrangler whoami &> /dev/null; then
    echo "Please log in to Cloudflare..."
    wrangler login
fi

# Check if we're deploying to production or preview
if [ "$1" = "--preview" ]; then
    echo "🔧 Deploying to preview environment..."
    DEPLOY_ENV="preview"
else
    echo "🚀 Deploying to production..."
    DEPLOY_ENV="production"
fi

# Handle D1 database
if [ -z "$DB_ID" ]; then
    echo "📦 DB_ID not set. Checking for existing database..."
    
    # List existing databases
    DB_EXISTS=$(wrangler d1 list --json | jq -r '.[] | select(.name == "videohub_db") | .uuid' 2>/dev/null || true)
    
    if [ -n "$DB_EXISTS" ]; then
        echo "✅ Found existing D1 database: $DB_EXISTS"
        export DB_ID="$DB_EXISTS"
    else
        echo "🆕 Creating new D1 database..."
        DB_CREATE_OUTPUT=$(wrangler d1 create videohub_db --json)
        NEW_DB_ID=$(echo "$DB_CREATE_OUTPUT" | jq -r '.uuid // .id' 2>/dev/null || echo "")
        
        if [ -z "$NEW_DB_ID" ]; then
            # Try parsing different output format
            NEW_DB_ID=$(echo "$DB_CREATE_OUTPUT" | grep -o 'uuid: [a-f0-9-]*' | cut -d' ' -f2)
        fi
        
        if [ -z "$NEW_DB_ID" ]; then
            echo "❌ Failed to create database. Please create manually:"
            echo "   wrangler d1 create videohub_db"
            echo "   Then set DB_ID environment variable"
            exit 1
        fi
        
        echo "✅ Created new D1 database: $NEW_DB_ID"
        export DB_ID="$NEW_DB_ID"
        
        # Apply migrations
        echo "📋 Applying database migrations..."
        wrangler d1 migrations apply videohub_db --remote
    fi
else
    echo "✅ Using provided DB_ID: $DB_ID"
fi

# Update wrangler.toml with database ID if needed
# Note: wrangler.toml uses ${DB_ID} variable, so we just need to ensure it's set

# Deploy the Worker
echo "🚀 Deploying Worker..."

# Use CI configuration if DB_ID is set (for consistency)
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
    echo "🔧 Using CI configuration..."
    wrangler deploy --config wrangler.ci.toml
elif [ "$DEPLOY_ENV" = "preview" ]; then
    wrangler deploy --env preview
else
    wrangler deploy
fi

echo "✅ Deployment complete!"
echo ""
echo "📊 Your Worker is now live:"
echo "   - Frontend: https://linktube.<your-subdomain>.workers.dev"
echo "   - API: https://linktube.<your-subdomain>.workers.dev/api/videos"
echo ""
echo "🔧 To update database schema in the future:"
echo "   1. Create new migration: wrangler d1 migrations create videohub_db <name>"
echo "   2. Apply migrations: wrangler d1 migrations apply videohub_db --remote"
echo "   3. Redeploy: wrangler deploy"