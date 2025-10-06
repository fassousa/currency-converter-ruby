# Deployment Guide

> 🌍 **Language:** **English** | [Português](DEPLOYMENT.pt-BR.md)

The Currency Converter API is deployed to Digital Ocean with automated CI/CD via GitHub Actions.

## Live Environment

- **URL:** https://currencyconverter.duckdns.org
- **API Docs:** https://currencyconverter.duckdns.org/api-docs  
- **Platform:** Digital Ocean Droplet (Ubuntu 22.04)
- **Stack:** Nginx + Puma + PostgreSQL + Redis
- **SSL:** Let's Encrypt (auto-renewing)

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

## HTTPS Setup

The application is secured with HTTPS using a free SSL certificate from Let's Encrypt.

### Initial Setup Steps

1. **Domain Configuration:**
   - Free domain from DuckDNS: `currencyconverter.duckdns.org`
   - Pointed to server IP: `161.35.142.103`

2. **Certbot Installation:**
   ```bash
   sudo apt update
   sudo apt install certbot python3-certbot-nginx -y
   ```

3. **Nginx Configuration:**
   - Updated `server_name` in `/etc/nginx/sites-available/currency-converter`
   - Changed from IP to domain: `currencyconverter.duckdns.org`

4. **SSL Certificate Generation:**
   ```bash
   sudo certbot --nginx -d currencyconverter.duckdns.org
   ```
   
   Certbot automatically:
   - Obtains SSL certificate from Let's Encrypt
   - Configures Nginx for HTTPS
   - Sets up HTTP to HTTPS redirect
   - Configures auto-renewal

5. **Verification:**
   ```bash
   curl https://currencyconverter.duckdns.org/api-docs
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
curl https://currencyconverter.duckdns.org/api/v1/health
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
- ✅ HTTPS with Let's Encrypt SSL
- ✅ Auto-renewing SSL certificates

## SSL Certificate Management

The SSL certificate is managed by Let's Encrypt and automatically renews every 90 days.

**Certificate Details:**
- Domain: currencyconverter.duckdns.org
- Provider: Let's Encrypt
- Location: `/etc/letsencrypt/live/currencyconverter.duckdns.org/`
- Auto-renewal: Configured via Certbot

**Manual SSL Renewal (if needed):**
```bash
ssh deploy@161.35.142.103
sudo certbot renew
sudo systemctl reload nginx
```

**Test Auto-renewal:**
```bash
sudo certbot renew --dry-run
```

## Monitoring

- Structured JSON logging (Lograge)
- Slow request detection (>1s)
- Performance metrics per request
- Error tracking via Rails logger

---

**Full CI/CD configuration:** `.github/workflows/ci-cd.yml`
