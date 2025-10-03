# Deployment Guide

This guide covers deploying the Currency Converter API to production.

## Prerequisites

- Git repository pushed to GitHub
- Heroku CLI installed (for Heroku deployment)
- Production database (PostgreSQL)
- Production Redis instance
- CurrencyAPI API key

## Deployment Options

### Option 1: Heroku (Recommended)

#### 1. Create Heroku App

```bash
# Login to Heroku
heroku login

# Create app
heroku create currency-converter-api

# Add PostgreSQL addon
heroku addons:create heroku-postgresql:mini

# Add Redis addon
heroku addons:create heroku-redis:mini
```

#### 2. Configure Environment Variables

```bash
# Set Rails environment
heroku config:set RAILS_ENV=production

# Generate and set secret key
heroku config:set SECRET_KEY_BASE=$(rails secret)

# Set API key
heroku config:set CURRENCY_API_KEY=your_actual_api_key

# Optional: Set log level
heroku config:set RAILS_LOG_LEVEL=info

# Optional: Set max threads
heroku config:set RAILS_MAX_THREADS=5
```

#### 3. Deploy

```bash
# Deploy to Heroku
git push heroku fagnner_sousa:main

# Run database migrations
heroku run rails db:migrate

# (Optional) Seed database
heroku run rails db:seed

# Check logs
heroku logs --tail

# Open app
heroku open
```

#### 4. Verify Deployment

```bash
# Health check
curl https://your-app.herokuapp.com/health

# API documentation
curl https://your-app.herokuapp.com/api-docs
```

### Option 2: Fly.io

#### 1. Install Fly CLI

```bash
# macOS
brew install flyctl

# Login
fly auth login
```

#### 2. Initialize Fly App

```bash
# Launch app (from project root)
fly launch

# Follow prompts:
# - Choose app name
# - Select region
# - Add PostgreSQL? Yes
# - Add Redis? Yes
```

#### 3. Configure Secrets

```bash
# Generate secret key
rails secret

# Set secrets
fly secrets set SECRET_KEY_BASE=<generated_secret>
fly secrets set CURRENCY_API_KEY=your_actual_api_key
fly secrets set RAILS_ENV=production
```

#### 4. Deploy

```bash
# Deploy app
fly deploy

# Run migrations
fly ssh console -C "cd backend && rails db:migrate"

# Check status
fly status

# Open app
fly open
```

## Environment Variables Reference

Required environment variables for production:

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | Auto-set by Heroku/Fly |
| `REDIS_URL` | Redis connection string | Auto-set by Heroku/Fly |
| `SECRET_KEY_BASE` | Rails secret key | Generate with `rails secret` |
| `CURRENCY_API_KEY` | CurrencyAPI key | Your API key |
| `RAILS_ENV` | Rails environment | `production` |
| `RAILS_LOG_LEVEL` | Log verbosity | `info` (optional) |
| `RAILS_MAX_THREADS` | Puma threads | `5` (optional) |

## Database Setup

### Initial Setup

```bash
# Heroku
heroku run rails db:migrate
heroku run rails db:seed  # Optional

# Fly.io
fly ssh console -C "cd backend && rails db:migrate"
fly ssh console -C "cd backend && rails db:seed"  # Optional
```

### Backup

```bash
# Heroku
heroku pg:backups:capture
heroku pg:backups:download

# Fly.io
fly postgres backup create
fly postgres backup list
```

## Monitoring & Logs

### View Logs

```bash
# Heroku
heroku logs --tail
heroku logs --source app --tail

# Fly.io
fly logs
```

### Scale Dynos/Machines

```bash
# Heroku
heroku ps:scale web=2

# Fly.io
fly scale count 2
```

## Post-Deployment Checklist

- [ ] Verify health endpoint: `/health`
- [ ] Test authentication endpoints: `/api/v1/auth/sign_up`, `/api/v1/auth/sign_in`
- [ ] Test currency conversion: `/api/v1/transactions`
- [ ] Check API documentation: `/api-docs`
- [ ] Verify Redis caching is working (check logs for cache hits)
- [ ] Monitor error logs for issues
- [ ] Test rate limiting functionality
- [ ] Verify SSL/HTTPS is enabled
- [ ] Update frontend environment variables with production API URL

## Troubleshooting

### Database Connection Issues

```bash
# Check database status
heroku pg:info  # Heroku
fly postgres status  # Fly.io

# Connect to database
heroku pg:psql  # Heroku
fly postgres connect -a <app-name>  # Fly.io
```

### Redis Connection Issues

```bash
# Check Redis status
heroku redis:info  # Heroku
fly redis status  # Fly.io
```

### Application Errors

```bash
# Check logs
heroku logs --tail --source app
fly logs

# Run Rails console
heroku run rails console
fly ssh console -C "cd backend && rails console"

# Restart app
heroku restart
fly apps restart
```

### Clear Cache

```bash
# Heroku
heroku run rails cache:clear

# Fly.io
fly ssh console -C "cd backend && rails cache:clear"
```

## SSL/HTTPS

Both Heroku and Fly.io provide free SSL certificates:

- **Heroku**: Automatic SSL (Let's Encrypt) for all apps
- **Fly.io**: Automatic SSL for custom domains

## Custom Domain

### Heroku

```bash
heroku domains:add www.yourdomain.com
# Follow DNS configuration instructions
```

### Fly.io

```bash
fly certs create www.yourdomain.com
# Follow DNS configuration instructions
```

## Performance Optimization

### Database Indexing

Already configured in migrations:
- `users.email` (unique)
- `transactions.user_id`
- `transactions.created_at`

### Connection Pooling

Configured in `database.yml`:
```yaml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

### Caching

- Redis caching enabled
- Exchange rates cached for 24 hours
- HTTP cache headers configured

## Maintenance

### Update Dependencies

```bash
# Update gems
bundle update

# Deploy updates
git push heroku main  # or: fly deploy
```

### Database Migrations

```bash
# Run migrations
heroku release  # Automatic via Procfile
# or manually:
heroku run rails db:migrate
fly ssh console -C "cd backend && rails db:migrate"
```

## Cost Estimates

### Heroku (Hobby Tier)
- Dyno (web): $7/month
- PostgreSQL (mini): $5/month
- Redis (mini): $3/month
- **Total**: ~$15/month

### Fly.io (Free Tier Available)
- App: Free tier available
- PostgreSQL: Free tier (1GB)
- Redis: Free tier available
- **Total**: Free (with limitations) or ~$10-15/month

## Security Checklist

- [x] Force SSL enabled (`config.force_ssl = true`)
- [x] CORS configured with specific origins
- [x] Rate limiting implemented (Rack::Attack)
- [x] SQL injection protection (ActiveRecord)
- [x] XSS protection (Rails default)
- [x] CSRF protection (Rails API mode)
- [x] Secure password storage (bcrypt)
- [x] Environment variables for secrets
- [x] Security headers configured

## Support

For issues:
1. Check logs first
2. Review configuration
3. Test locally with production settings
4. Contact platform support if needed
