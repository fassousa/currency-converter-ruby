# Deployment Guide

This guide covers deploying the Currency Converter API to Digital Ocean App Platform.

## Prerequisites

- Git repository pushed to GitHub
- Digital Ocean account
- Production PostgreSQL database
- Production Redis instance
- CurrencyAPI API key

## Digital Ocean App Platform Deployment

### Option 1: Deploy via App Spec (Recommended)

The repository includes a `.do/app.yaml` configuration file for one-click deployment.

#### 1. Create App from GitHub

1. Log in to [Digital Ocean](https://cloud.digitalocean.com/)
2. Navigate to **App Platform** → **Create App**
3. Select **GitHub** and authorize Digital Ocean
4. Choose repository: `fassousa/currency-converter-ruby`
5. Select branch: `main`
6. Digital Ocean will auto-detect the app spec file

#### 2. Configure Resources

The app spec includes:
- **PostgreSQL 15** database (managed)
- **Redis 7** cache (managed)
- **Ruby on Rails** API service
- **Pre-deploy job** for database migrations

Estimated cost: ~$12-15/month (Basic tier)

#### 3. Set Environment Secrets

In the App Platform dashboard, add these **encrypted** environment variables:

```bash
SECRET_KEY_BASE=<generate with: rails secret>
CURRENCY_API_KEY=<your CurrencyAPI key>
```

#### 4. Configure Allowed Origins (CORS)

Update the `ALLOWED_ORIGINS` variable with your frontend domain:

```bash
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

#### 5. Deploy

Click **Create Resources** and wait for deployment (~5-10 minutes).

The API will be available at: `https://your-app-name.ondigitalocean.app`

### Option 2: Manual Setup via CLI

### Option 2: Manual Setup via CLI

#### 1. Install doctl CLI

```bash
# macOS
brew install doctl

# Linux
cd ~
wget https://github.com/digitalocean/doctl/releases/download/v1.98.0/doctl-1.98.0-linux-amd64.tar.gz
tar xf ~/doctl-1.98.0-linux-amd64.tar.gz
sudo mv ~/doctl /usr/local/bin

# Authenticate
doctl auth init
```

#### 2. Create Database and Redis

```bash
# Create PostgreSQL database
doctl databases create currency-db \
  --engine pg \
  --version 15 \
  --region nyc1 \
  --size db-s-1vcpu-1gb

# Create Redis cache
doctl databases create currency-redis \
  --engine redis \
  --version 7 \
  --region nyc1 \
  --size db-s-1vcpu-1gb

# Get connection details
doctl databases get currency-db
doctl databases get currency-redis
```

#### 3. Create App

```bash
# Create from app spec
doctl apps create --spec .do/app.yaml

# Or create interactively
doctl apps create
```

#### 4. Configure Secrets

```bash
# Generate secret key
cd backend
bundle exec rails secret

# Set via dashboard or CLI
doctl apps update <app-id> \
  --env "SECRET_KEY_BASE=<generated-secret>"
```

### Health Check Endpoint

The API includes a comprehensive health check endpoint that verifies:
- Database connectivity
- Redis cache connectivity
- Application status

```bash
# Check app health
curl https://your-app.ondigitalocean.app/api/v1/health

# Expected response:
{
  "status": "ok",
  "timestamp": "2025-10-03T17:30:00Z",
  "services": {
    "database": "ok",
    "cache": "ok"
  }
}
```

Digital Ocean's health check uses this endpoint to monitor the app.

### Post-Deployment Verification

#### 1. Test API Endpoints

```bash
# Set your app URL
export API_URL=https://your-app.ondigitalocean.app

# Health check
curl $API_URL/api/v1/health

# Register user
curl -X POST $API_URL/api/v1/auth/sign_up \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }'

# Login
curl -X POST $API_URL/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }'

# Test conversion (use token from login)
curl -X POST $API_URL/api/v1/transactions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-token>" \
  -d '{
    "transaction": {
      "from_currency": "USD",
      "to_currency": "BRL",
      "from_value": "100"
    }
  }'
```

#### 2. Check Application Logs

```bash
# Via CLI
doctl apps logs <app-id> --type=run

# Or via dashboard
# Apps → Your App → Runtime Logs
```

#### 3. Monitor Performance

- Navigate to App → Insights tab
- Monitor CPU, memory, and request metrics
- Set up alerts for downtime or errors

### Scaling

#### Horizontal Scaling

```bash
# Scale to 2 instances
doctl apps update <app-id> --spec .do/app.yaml

# Update instance_count in app.yaml:
instance_count: 2
```

#### Vertical Scaling

Update `instance_size_slug` in `.do/app.yaml`:
- `basic-xxs`: 0.5 GB RAM, 1 vCPU (~$5/month)
- `basic-xs`: 1 GB RAM, 1 vCPU (~$12/month)
- `basic-s`: 2 GB RAM, 1 vCPU (~$25/month)

### Database Backups

Digital Ocean automatically backs up managed databases:
- Daily automated backups (retained for 7 days)
- Point-in-time recovery available
- Manual backups via dashboard

### Custom Domain Setup

#### 1. Add Domain to App

```bash
doctl apps create-domain <app-id> --domain api.yourdomain.com
```

#### 2. Configure DNS

Add CNAME record at your DNS provider:
```
Type: CNAME
Name: api
Value: <provided-by-digital-ocean>
```

#### 3. Enable HTTPS

Digital Ocean automatically provisions SSL certificates via Let's Encrypt.

## Environment Variables Reference

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `REDIS_URL` | Redis connection string | `redis://host:6379/0` |
| `SECRET_KEY_BASE` | Rails secret key | Generate with `rails secret` |
| `CURRENCY_API_KEY` | CurrencyAPI.com API key | Your API key from dashboard |
| `RAILS_ENV` | Rails environment | `production` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ALLOWED_ORIGINS` | CORS allowed origins | `*` (all) |
| `RAILS_LOG_LEVEL` | Log verbosity | `info` |
| `RAILS_MAX_THREADS` | Puma max threads | `5` |
| `WEB_CONCURRENCY` | Puma worker processes | `2` |
| `RACK_TIMEOUT_SERVICE_TIMEOUT` | Request timeout (seconds) | `15` |
| `RAILS_LOG_TO_STDOUT` | Output logs to stdout | `true` |
| `RAILS_SERVE_STATIC_FILES` | Serve static assets | `true` |

## Deployment Checklist

### Pre-Deployment
- [ ] All tests passing locally (`bundle exec rspec`)
- [ ] RuboCop clean (`bundle exec rubocop`)
- [ ] Security scan clean (`bundle exec brakeman`)
- [ ] Environment variables documented
- [ ] Database migrations tested
- [ ] API documentation up to date

### Deployment
- [ ] GitHub repository up to date
- [ ] Digital Ocean app created
- [ ] Database and Redis provisioned
- [ ] Environment secrets configured
- [ ] App deployed successfully
- [ ] Database migrations run
- [ ] Health check endpoint responding

### Post-Deployment
- [ ] All API endpoints tested
- [ ] Authentication working
- [ ] Currency conversion working
- [ ] Caching functioning
- [ ] Logs accessible
- [ ] Monitoring configured
- [ ] Custom domain configured (if applicable)
- [ ] SSL certificate active

## Troubleshooting

### Application Won't Start

**Check build logs:**
```bash
doctl apps logs <app-id> --type=build
```

**Common issues:**
- Missing environment variables
- Database connection failure
- Bundle install errors

### Database Connection Errors

**Verify DATABASE_URL:**
```bash
doctl apps list
doctl databases get currency-db
```

**Check database status:**
- Navigate to Databases → Your Database
- Verify status is "Online"
- Check connection details match app config

### Redis Connection Errors

**Verify REDIS_URL:**
```bash
doctl databases get currency-redis
```

**Test Redis connectivity:**
```bash
# From app console
doctl apps run <app-id> --command "rails console"
> Redis.current.ping
=> "PONG"
```

### Slow API Responses

**Check metrics:**
- App Platform → Insights tab
- Monitor CPU and memory usage
- Check database query performance

**Solutions:**
- Scale up instance size
- Increase Puma workers (`WEB_CONCURRENCY`)
- Add database indexes
- Optimize N+1 queries

### Out of Memory Errors

**Increase instance size:**
Update `.do/app.yaml`:
```yaml
instance_size_slug: basic-xs  # or basic-s
```

**Optimize memory usage:**
- Reduce Puma workers
- Monitor memory leaks
- Use connection pooling

## Cost Estimation

### Basic Setup (~$12-15/month)
- App: Basic XXS instance (~$5/month)
- PostgreSQL: Dev database (~$7/month)
- Redis: Dev cache (~$7/month)
- Bandwidth: Included (1TB)

### Production Setup (~$50-70/month)
- App: Basic S instance (~$25/month)
- PostgreSQL: Basic database (~$15/month)
- Redis: Basic cache (~$15/month)
- Backups: Included
- Monitoring: Included

## Maintenance

### Update Dependencies

```bash
# Update gems
bundle update
git commit -am "Update dependencies"
git push

# Digital Ocean will auto-deploy if configured
```

### Database Migrations

```bash
# Migrations run automatically on deploy via pre-deploy job
# Or run manually:
doctl apps run <app-id> --command "rails db:migrate"
```

### View Logs

```bash
# Real-time logs
doctl apps logs <app-id> --follow

# Specific log types
doctl apps logs <app-id> --type=run
doctl apps logs <app-id> --type=build
doctl apps logs <app-id> --type=deploy
```

## Rollback

### Rollback to Previous Deployment

```bash
# List deployments
doctl apps list-deployments <app-id>

# Rollback to specific deployment
doctl apps create-deployment <app-id> --deployment-id <previous-deployment-id>
```

Or via dashboard:
1. Navigate to your app
2. Go to "Deployments" tab
3. Click "Rollback" on desired deployment

## Support Resources

- [Digital Ocean App Platform Docs](https://docs.digitalocean.com/products/app-platform/)
- [Rails Deployment Guide](https://guides.rubyonrails.org/deployment.html)
- [Puma Configuration](https://github.com/puma/puma/blob/master/docs/deployment.md)
- [doctl CLI Reference](https://docs.digitalocean.com/reference/doctl/)


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
