# Fully Automated Cloudflare Installation

This guide provides a one-command installation process for deploying the YouTube Video Listing app to Cloudflare Workers with D1 database.

## 🚀 One-Command Installation

### For Most Users (Interactive)
```bash
# Make the script executable and run it
chmod +x install-cloudflare.sh && ./install-cloudflare.sh
```

### For CI/CD (Non-interactive)
```bash
# Set API token and run
export CLOUDFLARE_API_TOKEN="your-api-token"
./install-cloudflare.sh
```

## 📋 What the Automated Script Does

The `install-cloudflare.sh` script performs a complete installation:

1. **Prerequisites Check**
   - Verifies Node.js 16+ and npm are installed
   - Checks Wrangler version and updates if needed

2. **Cloudflare Authentication**
   - Interactive login for manual runs
   - API token authentication for CI/CD

3. **D1 Database Setup**
   - Checks for existing `videohub_db` database
   - Creates new database if needed
   - Applies database migrations automatically

4. **Configuration Generation**
   - Creates `wrangler.automated.toml` with correct database ID
   - Configures assets binding and Worker settings

5. **Deployment**
   - Deploys Worker to Cloudflare
   - Provides live URL after deployment

## 🏗️ Architecture

```
User Runs Script → Checks Prerequisites → Cloudflare Auth → Database Setup → Deploy → Live App
```

## 🔧 Requirements

- **Node.js 16+** and **npm**
- **Cloudflare Account** with Workers enabled
- **Wrangler CLI** (installed automatically if missing)

## 🌐 Output

After successful installation:
- **Frontend**: `https://linktube.<your-subdomain>.workers.dev`
- **API**: `https://linktube.<your-subdomain>.workers.dev/api/videos`
- **Database**: D1 database `videohub_db` with sample videos

## 🛠️ Manual Steps (If Needed)

If the automated script fails, you can:

1. **Check authentication**: `wrangler whoami`
2. **Create database manually**: `wrangler d1 create videohub_db`
3. **Apply migrations**: `wrangler d1 migrations apply videohub_db --remote`
4. **Deploy manually**: `wrangler deploy`

## 🔄 Updating

To update your deployment:
```bash
./install-cloudflare.sh
```
The script will reuse the existing database and update the Worker.

## 🐛 Troubleshooting

### "Not authenticated" error
- Run `wrangler login` manually
- Or set `CLOUDFLARE_API_TOKEN` environment variable

### Database creation fails
- Check Cloudflare dashboard for D1 database limits
- Ensure you have permission to create databases

### Migration errors
- Check `migrations/0001_initial.sql` for SQL syntax errors
- Manual fix: `wrangler d1 execute videohub_db --remote --file=migrations/0001_initial.sql`

### Deployment fails
- Check Worker name availability (change `name` in `wrangler.toml` if needed)
- Verify assets directory contains required files

## 📁 Files Created

- `wrangler.automated.toml` - Generated configuration (can be deleted)
- `.wrangler/` - Wrangler state and configuration

## 🤖 CI/CD Integration

### GitHub Actions Example
```yaml
name: Deploy to Cloudflare
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy
        run: |
          chmod +x install-cloudflare.sh
          ./install-cloudflare.sh
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

### Environment Variables
- `CLOUDFLARE_API_TOKEN`: Cloudflare API token with Workers edit permission
- `CI=true`: Run in non-interactive mode

## 🎯 Success Verification

After installation:
1. Visit your Worker URL
2. Test API endpoint: `/api/videos`
3. Check database binding in Cloudflare dashboard

## 📞 Support

If the automated installation fails:
1. Check the error output
2. Review Cloudflare dashboard for resources
3. Run manual steps from `DEPLOYMENT.md`

---

**Next Steps**: Your app is now live! Customize the videos in `migrations/0001_initial.sql` and redeploy.