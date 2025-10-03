# Deployment Guide

The Currency Converter API is deployed to Digital Ocean with automated CI/CD via GitHub Actions.

## Live Environment

- **URL:** http://161.35.142.103
- **API Docs:** http://161.35.142.103/api-docs  
- **Platform:** Digital Ocean Droplet (Ubuntu 22.04)
- **Stack:** Nginx + Puma + PostgreSQL + Redis

## Automated Deployment

Production deployment happens automatically when code is pushed to `main` branch:

1. **Tests Run** - RSpec (190 tests), RuboCop, Brakeman
2. **Security Scan** - Bundler Audit  
3. **Deploy** - SSH to server, pull code, migrate DB, restart Puma
4. **Health Check** - Verify /api/v1/health endpoint

## Manual Deployment

```bash
ssh deploy@161.35.142.103
cd /home/deploy/currency-converter-ruby/backend
git pull origin main
bundle install
RAILS_ENV=production rails db:migrate
sudo systemctl restart puma
```

## Environment Configuration

```bash
# Required environment variables
RAILS_ENV=production
DATABASE_URL=postgresql://user:pass@localhost/currency_converter_production
REDIS_URL=redis://localhost:6379/0
CURRENCY_API_KEY=your_api_key
DEVISE_JWT_SECRET_KEY=your_jwt_secret
SECRET_KEY_BASE=your_secret_key_base
```

## Server Stack

**Web Server:** Nginx (reverse proxy)  
**App Server:** Puma (2 workers, 5 threads)  
**Database:** PostgreSQL 14  
**Cache:** Redis 7  

## Health Check

```bash
curl http://161.35.142.103/api/v1/health
```

Expected:
```json
{
  "status": "healthy",
  "services": {
    "database": {"status": "up"},
    "cache": {"status": "up"},
    "external_api": {"status": "configured"}
  }
}
```

## CI/CD Pipeline

Automated via GitHub Actions (`.github/workflows/ci-cd.yml`):
- Runs tests and security scans on every push
- Deploys to production on main branch
- Verifies health check after deployment

## Security

- ✅ Rate limiting (100 req/min)
- ✅ CORS configured  
- ✅ Security headers
- ✅ Automated vulnerability scanning
- ✅ HTTPS ready (currently HTTP for demo)

## Monitoring

- Structured JSON logging (Lograge)
- Slow request detection (>1s)
- Performance metrics per request
- Error tracking via Rails logger

---

**Full CI/CD configuration:** `.github/workflows/ci-cd.yml`
