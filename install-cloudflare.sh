#!/bin/bash
# Fully automated Cloudflare installation script for YouTube Video Listing App
# This script handles everything from installation to deployment

set -e  # Exit on error

echo "🚀 Starting fully automated Cloudflare installation..."
echo "======================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if running in CI environment
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
    IS_CI=true
    print_status "Running in CI environment"
else
    IS_CI=false
fi

# Step 1: Check prerequisites
print_status "Checking prerequisites..."

# Check for Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 16+ and try again."
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    print_error "Node.js version must be 16 or higher. Current version: $(node -v)"
    exit 1
fi
print_status "Node.js $(node -v) detected"

# Check for npm
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm and try again."
    exit 1
fi
print_status "npm $(npm -v) detected"

# Step 2: Install/update Wrangler
print_status "Setting up Wrangler..."

if ! command -v wrangler &> /dev/null; then
    print_warning "Wrangler not found. Installing..."
    npm install -g wrangler
else
    print_status "Wrangler found, checking version..."
    WRANGLER_VERSION=$(wrangler --version | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "unknown")
    print_status "Wrangler version $WRANGLER_VERSION"
    
    # Update if older than 4.0
    if [ "$WRANGLER_VERSION" != "unknown" ]; then
        MAJOR_VERSION=$(echo "$WRANGLER_VERSION" | cut -d'.' -f1)
        if [ "$MAJOR_VERSION" -lt 4 ]; then
            print_warning "Wrangler version is older than 4.0. Updating..."
            npm install -g wrangler
        fi
    fi
fi

# Step 3: Cloudflare authentication
print_status "Checking Cloudflare authentication..."

if [ "$IS_CI" = true ] && [ -n "$CLOUDFLARE_API_TOKEN" ]; then
    print_status "Using CI API token for authentication"
    # Configure wrangler with API token
    mkdir -p "$HOME/.wrangler/config"
    echo "api_token = \"$CLOUDFLARE_API_TOKEN\"" > "$HOME/.wrangler/config/default.toml"
elif wrangler whoami &> /dev/null; then
    print_status "Already authenticated with Cloudflare"
else
    if [ "$IS_CI" = true ]; then
        print_error "Not authenticated and no CLOUDFLARE_API_TOKEN set in CI"
        print_error "Please set CLOUDFLARE_API_TOKEN environment variable"
        exit 1
    else
        print_warning "Not authenticated with Cloudflare. Starting login..."
        wrangler login
    fi
fi

# Step 4: Create or get D1 database
print_status "Setting up D1 database..."

# Check if jq is installed for JSON parsing
if ! command -v jq &> /dev/null; then
    if [ "$IS_CI" = true ]; then
        print_warning "jq not installed. Installing..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y jq
        elif command -v yum &> /dev/null; then
            yum install -y jq
        elif command -v apk &> /dev/null; then
            apk add jq
        else
            print_warning "Cannot install jq automatically. Using grep fallback."
        fi
    else
        print_warning "jq not installed. Using grep fallback for database detection."
    fi
fi

# Check if database already exists
if command -v jq &> /dev/null; then
    DB_EXISTS=$(wrangler d1 list --json 2>/dev/null | jq -r '.[] | select(.name == "videohub_db") | .uuid' 2>/dev/null || true)
else
    # Fallback using grep
    DB_EXISTS=$(wrangler d1 list 2>/dev/null | grep -A5 "videohub_db" | grep -o 'uuid: [a-f0-9-]*' | cut -d' ' -f2 || true)
fi

if [ -n "$DB_EXISTS" ]; then
    print_status "Existing D1 database found: $DB_EXISTS"
    DB_ID="$DB_EXISTS"
else
    print_status "Creating new D1 database 'videohub_db'..."
    
    # Try to create database
    DB_CREATE_OUTPUT=$(wrangler d1 create videohub_db 2>&1)
    
    # Extract database ID from output
    DB_ID=$(echo "$DB_CREATE_OUTPUT" | grep -o 'uuid: [a-f0-9-]*' | cut -d' ' -f2)
    
    if [ -z "$DB_ID" ]; then
        # Try alternative pattern
        DB_ID=$(echo "$DB_CREATE_OUTPUT" | grep -o 'ID: [a-f0-9-]*' | cut -d' ' -f2)
    fi
    
    if [ -z "$DB_ID" ]; then
        # Try JSON output
        DB_ID=$(echo "$DB_CREATE_OUTPUT" | jq -r '.uuid // .id' 2>/dev/null || true)
    fi
    
    if [ -z "$DB_ID" ]; then
        print_error "Failed to create database. Output:"
        echo "$DB_CREATE_OUTPUT"
        print_error "Please create database manually: wrangler d1 create videohub_db"
        exit 1
    fi
    
    print_status "Created D1 database with ID: $DB_ID"
fi

# Step 5: Update configuration with database ID
print_status "Updating configuration..."

# Create automated configuration
cat > wrangler.automated.toml << EOF
# Automatically generated configuration for YouTube Video Listing App
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

print_status "Created wrangler.automated.toml with database ID"

# Step 6: Apply database migrations
print_status "Applying database migrations..."

# Check if migrations directory exists
if [ ! -d "migrations" ]; then
    print_error "Migrations directory not found"
    exit 1
fi

# Apply migrations to remote database
MIGRATION_OUTPUT=$(wrangler d1 migrations apply videohub_db --remote 2>&1)
if echo "$MIGRATION_OUTPUT" | grep -q "error\|Error\|ERROR"; then
    print_warning "Migration output:"
    echo "$MIGRATION_OUTPUT"
    print_warning "Continuing deployment despite migration warnings..."
else
    print_status "Migrations applied successfully"
fi

# Step 7: Deploy the Worker
print_status "Deploying to Cloudflare Workers..."

DEPLOY_OUTPUT=$(wrangler deploy --config wrangler.automated.toml 2>&1)
DEPLOY_EXIT_CODE=$?

if [ $DEPLOY_EXIT_CODE -eq 0 ]; then
    # Extract Worker URL from output
    WORKER_URL=$(echo "$DEPLOY_OUTPUT" | grep -o 'https://[^ ]*\.workers\.dev' | head -1)
    
    if [ -n "$WORKER_URL" ]; then
        print_status "✅ Deployment successful!"
        echo ""
        echo "🌐 Your app is now live at:"
        echo "   Frontend: $WORKER_URL"
        echo "   API: $WORKER_URL/api/videos"
        echo ""
        echo "📊 Database:"
        echo "   Name: videohub_db"
        echo "   ID: $DB_ID"
        echo ""
        echo "🔧 To update in the future:"
        echo "   ./install-cloudflare.sh"
    else
        print_status "Deployment completed (URL not detected in output)"
        echo "$DEPLOY_OUTPUT"
    fi
else
    print_error "Deployment failed with exit code $DEPLOY_EXIT_CODE"
    echo "$DEPLOY_OUTPUT"
    exit 1
fi

# Step 8: Cleanup (optional)
if [ "$IS_CI" = true ]; then
    # Keep the automated config in CI for future use
    print_status "Keeping wrangler.automated.toml for CI"
else
    # Ask user if they want to keep the automated config
    echo ""
    read -p "Keep the automated configuration file? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        rm -f wrangler.automated.toml
        print_status "Removed wrangler.automated.toml"
    fi
fi

echo ""
print_status "🎉 Installation complete! Your YouTube Video Listing app is now running on Cloudflare Workers."