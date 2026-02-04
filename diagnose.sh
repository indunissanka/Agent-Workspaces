#!/bin/bash
# Diagnostic script for Cloudflare Worker deployment issues

echo "🔍 DIAGNOSTIC CHECK for Cloudflare Worker"
echo "========================================"

# Check authentication
echo "1. Checking authentication..."
if wrangler whoami &> /dev/null; then
    echo "✅ Authenticated with Cloudflare"
    wrangler whoami
else
    echo "❌ NOT authenticated"
    echo "   Run: wrangler login"
    echo "   Or set CLOUDFLARE_API_TOKEN environment variable"
fi

# Check existing Workers
echo ""
echo "2. Checking existing Workers..."
wrangler list 2>&1 | head -20

# Check D1 databases
echo ""
echo "3. Checking D1 databases..."
wrangler d1 list 2>&1

# Check current configuration
echo ""
echo "4. Checking configuration files..."
if [ -f "wrangler.toml" ]; then
    echo "✅ wrangler.toml exists"
    grep -n "database_id" wrangler.toml || echo "   No database_id found"
else
    echo "❌ wrangler.toml missing"
fi

if [ -f "wrangler.ci.toml" ]; then
    echo "✅ wrangler.ci.toml exists"
    grep -n "database_id" wrangler.ci.toml || echo "   No database_id found"
fi

# Check if Worker is already deployed
echo ""
echo "5. Testing Worker URL..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "https://linktube.indunissanka.workers.dev/" 2>&1 | head -5

echo ""
echo "6. Testing API endpoint..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "https://linktube.indunissanka.workers.dev/api/videos" 2>&1 | head -5

echo ""
echo "🔧 RECOMMENDED ACTIONS:"
echo "1. Ensure CLOUDFLARE_API_TOKEN is set and valid"
echo "2. Check if Worker 'linktube' already exists in another account"
echo "3. Try different Worker name in wrangler.toml"
echo "4. Check Cloudflare dashboard for errors"