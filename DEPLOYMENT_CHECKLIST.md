# Deployment Checklist

## Pre-Deployment

- [ ] All tests passing locally (`bundle exec rspec`)
- [ ] RuboCop has no offenses (`bundle exec rubocop`)
- [ ] Security scan clean (`bundle exec brakeman`)
- [ ] Code committed and pushed to GitHub
- [ ] Environment variables documented
- [ ] Database migrations tested

## Digital Ocean Setup

- [ ] Droplet created (Ubuntu 22.04, $12/month recommended)
- [ ] SSH key added to Digital Ocean
- [ ] Firewall configured (ports 22, 80, 443)
- [ ] Domain name configured (optional)
- [ ] DNS A record pointing to droplet IP

## Server Configuration

- [ ] System updated (`apt update && apt upgrade`)
- [ ] Deploy user created
- [ ] Ruby 3.3.5 installed via rbenv
- [ ] PostgreSQL installed and configured
- [ ] Redis installed and running
- [ ] Nginx installed

## Application Deployment

- [ ] Repository cloned to `/home/deploy/currency-converter-ruby`
- [ ] Bundle installed (`bundle install --without development test`)
- [ ] `.env` file created with production values
- [ ] `SECRET_KEY_BASE` generated and set
- [ ] Database created and migrated
- [ ] Puma systemd service configured
- [ ] Nginx reverse proxy configured

## SSL/Security

- [ ] SSL certificate installed (Certbot with Let's Encrypt)
- [ ] HTTPS enforced
- [ ] Fail2Ban configured
- [ ] Regular backups scheduled

## Verification

- [ ] Health endpoint accessible: `/health`
- [ ] API health check works: `/api/v1/health`
- [ ] User registration works
- [ ] User login works
- [ ] Transaction creation works
- [ ] Swagger docs accessible: `/api-docs`
- [ ] Logs are being written
- [ ] Redis cache is working

## Monitoring

- [ ] Application logs accessible
- [ ] Service status checks working
- [ ] Database backups scheduled
- [ ] Uptime monitoring configured (optional)

## Documentation

- [ ] API documentation updated
- [ ] Deployment guide reviewed
- [ ] Team notified of deployment
- [ ] Credentials securely stored

## Post-Deployment

- [ ] Smoke tests passed in production
- [ ] API endpoints tested with Postman/curl
- [ ] Performance monitoring active
- [ ] Error tracking configured (optional)
- [ ] Rollback plan documented

---

**Environment Variables to Set:**
```
RAILS_ENV=production
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
CURRENCY_API_KEY=...
SECRET_KEY_BASE=...
```

**Quick Deploy Command:**
```bash
cd ~/currency-converter-ruby
git pull origin main
cd backend
bundle install --without development test
rails db:migrate RAILS_ENV=production
sudo systemctl restart puma
```
