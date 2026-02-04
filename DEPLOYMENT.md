# Deployment Guide for YouTube Video Listing App (linktube)

This guide explains how to deploy the YouTube Video Listing app to Cloudflare Workers with proper D1 database binding.

## Configuration Files

### 1. `wrangler.toml` (Primary Configuration for Local Development)
```toml
name = "linktube"
compatibility_date = "2026-02-04"
main = "src/worker.js"

[assets]
directory = "./"

[[d1_databases]]
binding = "DB"
database_name = "videohub_db"
database_id = "REPLACE_WITH_DATABASE_ID"  # Replace with actual D1 database ID for production
preview_database_id = "local"  # Used for wrangler dev --local
migrations_dir = "migrations"
```

### 2. `wrangler.ci.toml` (CI/CD Configuration)
```toml
name = "linktube"
compatibility_date = "2026-02-04"
main = "src/worker.js"

[assets]
directory = "./"

[[d1_databases]]
binding = "DB"
database_name = "videohub_db"
database_id = "${DB_ID}"  # Must be set in CI environment
preview_database_id = "local"
migrations_dir = "migrations"
```

### 3. `migrations/0001_initial.sql`
Contains the database schema and sample data.

### 4. `deploy.sh` (Automated Deployment Script)
Handles database creation and deployment.

## Deployment Methods

### Method 1: Automated Script (Recommended)

```bash
chmod +x deploy.sh
./deploy.sh
```

The script:
1. Checks for existing D1 database or creates new one
2. Applies migrations
3. Deploys Worker

### Method 2: Manual Deployment

#### Step 1: Create D1 Database
```bash
wrangler d1 create videohub_db
```
Copy the database ID from output.

#### Step 2: Update Configuration
Edit `wrangler.toml` and replace `REPLACE_WITH_DATABASE_ID` with the actual database ID.

#### Step 3: Apply Migrations
```bash
wrangler d1 migrations apply videohub_db --remote
```

#### Step 4: Deploy
```bash
wrangler deploy
```

### Method 3: CI/CD Deployment

#### Option A: Using Environment Variable
1. Set `DB_ID` environment variable in CI with your D1 database ID
2. Deploy with CI configuration:
   ```bash
   wrangler deploy --config wrangler.ci.toml
   ```

#### Option B: Using Deployment Script
1. Set `CLOUDFLARE_API_TOKEN` in CI
2. Run:
   ```bash
   ./deploy.sh
   ```

## Fixing "D1 database not properly binded" Error

This error occurs when:
1. `database_id` is empty or invalid
2. Environment variable `DB_ID` is not set in CI
3. Using wrong configuration file

**Solution:**
1. **For CI/CD:** Set `DB_ID` environment variable with valid D1 database ID
2. **For manual deployment:** Replace `REPLACE_WITH_DATABASE_ID` in `wrangler.toml`
3. **For local development:** Use `wrangler dev --local` (uses `preview_database_id = "local"`)

## Local Development

```bash
wrangler dev --local
```
- Uses local SQLite database
- Available at http://localhost:8787
- Database binding works as `env.DB (local)`

## Verification

After deployment:
1. **Check binding:** Worker logs should show `env.DB (videohub_db)` not `env.DB (local)`
2. **Test API:** `https://linktube.<your-subdomain>.workers.dev/api/videos`
3. **Test frontend:** Visit Worker URL

## Troubleshooting

### Database Binding Shows as `(local)`
- Means `database_id` is empty or "local"
- For production: set valid `database_id` or `DB_ID` environment variable

### "binding DB of type d1 must have a valid `id` specified"
- `database_id` is missing or invalid
- Set `DB_ID` environment variable or update configuration

### Migrations Not Applying
```bash
wrangler d1 migrations apply videohub_db --remote
```

### Worker Name Mismatch
- CI expects "linktube" - already configured in both TOML files

## Files

- `wrangler.toml` - Local development configuration
- `wrangler.ci.toml` - CI/CD configuration (environment variables)
- `deploy.sh` - Deployment automation script
- `migrations/0001_initial.sql` - Database schema
- `DEPLOYMENT.md` - This guide

## Quick CI Setup

```yaml
# GitHub Actions example
- name: Deploy
  run: |
    npm install -g wrangler
    wrangler deploy --config wrangler.ci.toml
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
    DB_ID: ${{ secrets.DB_ID }}
```

The D1 database binding will work correctly when `database_id` is properly set to a valid D1 database ID.