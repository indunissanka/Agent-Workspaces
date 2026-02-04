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

### 4. `install-cloudflare.sh` (Fully Automated Installation Script)
Handles complete installation: prerequisites, authentication, database creation, migrations, and deployment. Generates `wrangler.automated.toml` with actual database ID.

### 5. `deploy.sh` (Legacy Deployment Script)
Simpler script that handles database creation and deployment (still works).

## Deployment Methods

### Method 1: Fully Automated Installation (Recommended)

Use the comprehensive `install-cloudflare.sh` script for zero-touch deployment:

```bash
chmod +x install-cloudflare.sh && ./install-cloudflare.sh
```

The script handles everything:
1. **Prerequisites check** - Node.js, npm, Wrangler
2. **Authentication** - Interactive login or API token
3. **Database setup** - Creates D1 database if needed
4. **Migrations** - Applies database schema automatically
5. **Configuration** - Generates proper `wrangler.automated.toml`
6. **Deployment** - Deploys Worker and provides live URL

For CI/CD:
```bash
export CLOUDFLARE_API_TOKEN="your-token"
./install-cloudflare.sh
```

> **Note**: The older `deploy.sh` script is still available but `install-cloudflare.sh` is more comprehensive.

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
- `install-cloudflare.sh` - Fully automated installation script (recommended)
- `deploy.sh` - Legacy deployment script (still works)
- `migrations/0001_initial.sql` - Database schema
- `AUTOMATED_INSTALL.md` - One-command installation guide
- `DEPLOYMENT.md` - This guide

## Quick CI Setup

### Option 1: Using install-cloudflare.sh (Recommended)
```yaml
# GitHub Actions example
- name: Deploy
  run: |
    chmod +x install-cloudflare.sh
    ./install-cloudflare.sh
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
```

### Option 2: Manual Wrangler Deployment
```yaml
- name: Deploy
  run: |
    npm install -g wrangler
    wrangler deploy --config wrangler.ci.toml
  env:
    CLOUDFLARE_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
    DB_ID: ${{ secrets.DB_ID }}
```

The D1 database binding will work correctly when `database_id` is properly set to a valid D1 database ID.