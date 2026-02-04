# Deployment Guide for YouTube Video Listing App (linktube)

This guide explains how to deploy the YouTube Video Listing app to Cloudflare Workers with D1 database automation.

## Configuration Files

### 1. `wrangler.toml` (Primary Configuration)
Updated to work with CI/CD and automatic database creation:

```toml
name = "linktube"
compatibility_date = "2026-02-04"
main = "src/worker.js"

[assets]
directory = "./"

[[d1_databases]]
binding = "DB"
database_name = "videohub_db"
database_id = "${DB_ID}"  # Set DB_ID environment variable for deployment
preview_database_id = "local"  # Use local database for development
migrations_dir = "migrations"
```

### 2. `migrations/0001_initial.sql`
Contains the database schema and sample data that will be automatically applied during deployment.

### 3. `deploy.sh` (Automated Deployment Script)
Bash script that handles database creation and deployment automatically.

## Deployment Methods

### Method 1: Automated Script (Recommended)

```bash
# Make script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh

# For preview deployment
./deploy.sh --preview
```

The script will:
1. Check if wrangler is installed and logged in
2. Look for existing D1 database or create a new one
3. Apply database migrations
4. Deploy the Worker to Cloudflare

### Method 2: Manual Deployment

#### Prerequisites
- Cloudflare account with Workers enabled
- Wrangler CLI installed (`npm install -g wrangler`)
- Logged in to Cloudflare (`wrangler login`)

#### Steps:

1. **Create D1 database (if not exists):**
   ```bash
   wrangler d1 create videohub_db
   ```

2. **Set database ID as environment variable:**
   ```bash
   export DB_ID="your-database-id-here"
   ```

3. **Apply migrations:**
   ```bash
   wrangler d1 migrations apply videohub_db --remote
   ```

4. **Deploy Worker:**
   ```bash
   wrangler deploy
   ```

### Method 3: CI/CD Integration

For GitHub Actions, Netlify, or other CI/CD platforms:

1. Set environment variables in CI:
   - `CLOUDFLARE_API_TOKEN` - Cloudflare API token
   - `DB_ID` - (Optional) D1 database ID

2. Use the deployment script or run commands directly:

```yaml
# Example GitHub Actions workflow
- name: Deploy to Cloudflare Workers
  run: |
    npm install -g wrangler
    ./deploy.sh
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

## Local Development

```bash
# Start local development server
wrangler dev --local

# This will:
# - Use local SQLite database (preview_database_id = "local")
# - Serve assets from current directory
# - Apply migrations to local database
# - Available at http://localhost:8787
```

## Verification

After deployment:

1. **Check Worker URL:** Output will show your Worker URL (e.g., `https://linktube.<your-subdomain>.workers.dev`)
2. **Test API:** `https://linktube.<your-subdomain>.workers.dev/api/videos`
3. **Test Frontend:** Visit the Worker URL in browser

## Troubleshooting

### Database Creation Fails in CI
- Ensure `CLOUDFLARE_API_TOKEN` has D1 database permissions
- Check Wrangler version: `wrangler --version` (should be 4.0+)
- The `deploy.sh` script includes fallback logic for database creation

### "binding DB of type d1 must have a valid `id` specified"
- Set `DB_ID` environment variable with valid D1 database ID
- Or let the deployment script create one automatically

### Migrations Not Applying
- Verify `migrations_dir` points to correct folder
- Check SQL syntax in migration files
- Run `wrangler d1 migrations list videohub_db --remote` to see applied migrations

### Worker Name Mismatch
- CI expects Worker name "linktube" (configured in wrangler.toml)
- If you need a different name, update `name = "linktube"` in wrangler.toml

## Post-Deployment

1. **Custom Domain:** Add custom domain in Cloudflare dashboard
2. **Environment Variables:** Set secrets via `wrangler secret put`
3. **Monitoring:** Use Cloudflare dashboard to monitor Worker performance
4. **Database Management:** Use `wrangler d1` commands to manage your database

## Files Created

- `wrangler.toml` - Main configuration (CI-compatible)
- `migrations/0001_initial.sql` - Database schema
- `deploy.sh` - Automated deployment script
- `DEPLOYMENT.md` - This guide

For more details, refer to [Cloudflare Workers documentation](https://developers.cloudflare.com/workers/).