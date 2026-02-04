# Deployment Guide for YouTube Video Listing App

This guide explains how to deploy the YouTube Video Listing app to Cloudflare Workers with automatic D1 database creation.

## Configuration Files

### 1. `wrangler.toml` (Primary Configuration)
The `wrangler.toml` file is configured to automatically create the D1 database on first deployment:

```toml
name = "videohub-assets"
compatibility_date = "2026-02-04"
main = "src/worker.js"

[assets]
directory = "./"

[[d1_databases]]
binding = "DB"
database_name = "videohub_db"
database_id = ""  # Empty string = create automatically on first deploy
preview_database_id = "local"  # Use local database for development
migrations_dir = "migrations"
```

### 2. `migrations/0001_initial.sql`
Contains the database schema and sample data that will be automatically applied during deployment.

## Deployment Steps

### Prerequisites
- Cloudflare account with Workers enabled
- Wrangler CLI installed (`npm install -g wrangler`)
- Logged in to Cloudflare (`wrangler login`)

### Automatic Deployment (Recommended)

1. **Deploy to Cloudflare Workers:**
   ```bash
   wrangler deploy
   ```

   On first deployment:
   - Wrangler will automatically create a D1 database named `videohub_db`
   - Apply migrations from `migrations/` folder
   - Deploy the Worker with assets binding

2. **Verify Deployment:**
   - Worker URL will be shown in output (e.g., `https://videohub-assets.<your-subdomain>.workers.dev`)
   - Test API: `https://videohub-assets.<your-subdomain>.workers.dev/api/videos`
   - Test frontend: Visit the Worker URL in browser

### Manual Database Creation (Alternative)

If automatic creation doesn't work:

1. **Create D1 database manually:**
   ```bash
   wrangler d1 create videohub_db
   ```

2. **Update `wrangler.toml` with the database ID:**
   ```toml
   database_id = "<your-database-id>"
   ```

3. **Apply migrations:**
   ```bash
   wrangler d1 migrations apply videohub_db --remote
   ```

4. **Deploy:**
   ```bash
   wrangler deploy
   ```

## Local Development

For local development with the same configuration:

```bash
wrangler dev --local
```

This will:
- Use `preview_database_id = "local"` (local SQLite database)
- Serve assets from current directory
- Apply migrations to local database

## CI/CD Integration

For automated deployments (GitHub Actions, etc.):

1. Set Cloudflare API token as secret
2. Use environment variable for database ID:
   ```toml
   database_id = "${DB_ID}"
   ```
3. In CI, create database and set DB_ID environment variable

## Troubleshooting

### Database Creation Fails
- Ensure you have D1 database permissions in Cloudflare dashboard
- Check Wrangler version: `wrangler --version` (should be 4.0+)

### Migrations Not Applying
- Verify `migrations_dir` points to correct folder
- Check SQL syntax in migration files
- Run `wrangler d1 migrations list videohub_db --remote` to see applied migrations

### Assets Not Serving
- Ensure `directory = "./"` includes all static files
- Check file permissions
- Verify Worker has assets binding enabled

## Post-Deployment

1. **Customize Domain:** Add custom domain in Cloudflare dashboard
2. **Environment Variables:** Set any needed environment variables via `wrangler secret put`
3. **Monitoring:** Use Cloudflare dashboard to monitor Worker performance and errors

## Rollback

If deployment fails:
```bash
wrangler deployments list
wrangler rollback --version <version-id>
```

For more details, refer to [Cloudflare Workers documentation](https://developers.cloudflare.com/workers/).