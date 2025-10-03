# Deployment Information

## Server Details

**Digital Ocean Droplet:**
- **IP Address:** 161.35.142.103
- **RAM:** 2GB
- **CPU:** 1 vCPU
- **Location:** NYC3
- **OS:** Ubuntu 22.04

**SSH Access:**
```bash
ssh -i ~/.ssh/digitalocean_deploy root@161.35.142.103
```

## Application Configuration

**Application Path:**
```
/home/rails/currency-converter-ruby/backend
```

**User:** `rails`

**Environment:** Production

**Environment Variables Location:**
```
/home/rails/currency-converter-ruby/backend/.env.production
```

## Services

### PostgreSQL Database
- **Status:** Running
- **Database Name:** `currency_converter_production`
- **User:** `rails`
- **Connection:** via DATABASE_URL in .env.production

### Redis Cache
- **Status:** Running
- **Connection:** `redis://localhost:6379/0`

### Puma Application Server
- **Status:** Running (systemd service)
- **Workers:** 2
- **Threads:** 5 (min and max)
- **Socket:** `unix:///home/rails/currency-converter-ruby/backend/tmp/sockets/puma.sock`
- **Service File:** `/etc/systemd/system/puma.service`

**Puma Commands:**
```bash
sudo systemctl status puma
sudo systemctl restart puma
sudo systemctl stop puma
sudo systemctl start puma
sudo journalctl -u puma -f  # View logs
```

### Nginx Reverse Proxy
- **Status:** Running
- **Port:** 80 (HTTP)
- **Config:** `/etc/nginx/sites-available/currency-converter`
- **Logs:**
  - Access: `/var/log/nginx/currency-converter.access.log`
  - Error: `/var/log/nginx/currency-converter.error.log`

**Nginx Commands:**
```bash
sudo systemctl status nginx
sudo systemctl restart nginx
sudo nginx -t  # Test configuration
sudo tail -f /var/log/nginx/currency-converter.error.log
```

## API Endpoints

**Base URL:** `http://161.35.142.103`

**Important:** All API requests require JSON headers:
```bash
-H "Content-Type: application/json" -H "Accept: application/json"
```

### Health Check
```bash
curl -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     http://161.35.142.103/api/v1/health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-10-03T20:32:31Z",
  "version": "1.0.0",
  "environment": "production",
  "services": {
    "database": {
      "status": "up",
      "message": "Database is accessible"
    },
    "cache": {
      "status": "up",
      "message": "Cache is accessible"
    },
    "external_api": {
      "status": "configured",
      "message": "API key is configured"
    }
  }
}
```

### User Registration
```bash
curl -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     http://161.35.142.103/api/v1/auth \
     -d '{"user":{"email":"test@example.com","password":"password123","password_confirmation":"password123"}}'
```

**Response (Success):**
```json
{
  "status": {
    "code": 201,
    "message": "Signed up successfully"
  },
  "data": {
    "id": 1,
    "email": "test@example.com"
  }
}
```

### User Login
```bash
curl -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     http://161.35.142.103/api/v1/auth/sign_in \
     -d '{"user":{"email":"test@example.com","password":"password123"}}'
```

### Available Routes
All routes are prefixed with `/api/v1`:

- **Authentication:**
  - `POST /api/v1/auth` - Sign up
  - `POST /api/v1/auth/sign_in` - Sign in
  - `DELETE /api/v1/auth/sign_out` - Sign out
  - `PATCH/PUT /api/v1/auth` - Update account
  - `DELETE /api/v1/auth` - Delete account

- **Health:**
  - `GET /api/v1/health` - Health check

- **Transactions:**
  - `GET /api/v1/transactions` - List transactions
  - `POST /api/v1/transactions` - Create transaction
  - `GET /api/v1/transactions/:id` - Show transaction

## Deployment Process

### Deploying Updates

When you need to deploy code changes:

```bash
# SSH into the server
ssh -i ~/.ssh/digitalocean_deploy root@161.35.142.103

# Switch to rails user
su - rails

# Navigate to the application directory
cd currency-converter-ruby/backend

# Pull latest changes
git pull origin fagnner_sousa

# Install new dependencies (if any)
RAILS_ENV=production bundle install --without development test

# Run database migrations (if any)
export $(grep -v "^#" .env.production | grep -v "^$" | xargs)
RAILS_ENV=production bundle exec rails db:migrate

# Exit rails user
exit

# Restart Puma to apply changes
sudo systemctl restart puma

# Check if everything is working
curl -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     http://161.35.142.103/api/v1/health
```

### Database Operations

**Run migrations:**
```bash
su - rails
cd currency-converter-ruby/backend
export $(grep -v "^#" .env.production | grep -v "^$" | xargs)
RAILS_ENV=production bundle exec rails db:migrate
```

**Access Rails console:**
```bash
su - rails
cd currency-converter-ruby/backend
export $(grep -v "^#" .env.production | grep -v "^$" | xargs)
RAILS_ENV=production bundle exec rails console
```

**Rollback migration:**
```bash
su - rails
cd currency-converter-ruby/backend
export $(grep -v "^#" .env.production | grep -v "^$" | xargs)
RAILS_ENV=production bundle exec rails db:rollback
```

## Security Considerations

### ⚠️ Current Security Status

1. **SSL/HTTPS Not Configured**
   - Currently using HTTP only
   - Recommendation: Set up Let's Encrypt SSL certificate

2. **Force SSL Disabled**
   - `config.force_ssl = false` in `config/environments/production.rb`
   - Should be enabled after SSL is configured

### Setting Up SSL (Recommended)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain SSL certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com

# Certbot will automatically configure Nginx for HTTPS

# Enable force_ssl in Rails
su - rails
cd currency-converter-ruby/backend
sed -i "s/config.force_ssl = false/config.force_ssl = true/" config/environments/production.rb
exit

# Restart Puma
sudo systemctl restart puma
```

## Monitoring & Troubleshooting

### Check Service Status
```bash
# All services
sudo systemctl status puma nginx postgresql redis

# Individual service
sudo systemctl status puma
```

### View Logs
```bash
# Puma logs (live)
sudo journalctl -u puma -f

# Puma logs (last 100 lines)
sudo journalctl -u puma -n 100

# Nginx error logs
sudo tail -f /var/log/nginx/currency-converter.error.log

# Nginx access logs
sudo tail -f /var/log/nginx/currency-converter.access.log

# Rails logs
su - rails
tail -f currency-converter-ruby/backend/log/production.log
```

### Common Issues

**502 Bad Gateway:**
- Check if Puma is running: `sudo systemctl status puma`
- Check Puma logs: `sudo journalctl -u puma -n 50`
- Check socket permissions: `ls -la /home/rails/currency-converter-ruby/backend/tmp/sockets/`
- Restart Puma: `sudo systemctl restart puma`

**Database Connection Errors:**
- Check PostgreSQL status: `sudo systemctl status postgresql`
- Verify DATABASE_URL in .env.production
- Test database connection via Rails console

**Out of Memory:**
- Check memory usage: `free -h`
- Consider reducing Puma workers in `config/puma.rb`
- Or upgrade droplet size

## Environment Variables

Located in: `/home/rails/currency-converter-ruby/backend/.env.production`

Required variables:
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `CURRENCY_API_KEY` - Currency API key (get from https://currencyapi.com/)
- `SECRET_KEY_BASE` - Rails secret key
- `DEVISE_JWT_SECRET_KEY` - JWT signing key

**⚠️ Never commit .env.production to git!**

## Backup Recommendations

### Database Backups

Create a backup script:
```bash
#!/bin/bash
# /home/rails/backup-db.sh
pg_dump -U rails currency_converter_production > /home/rails/backups/db_$(date +%Y%m%d_%H%M%S).sql
```

Set up daily cron job:
```bash
su - rails
crontab -e

# Add this line for daily backups at 2 AM
0 2 * * * /home/rails/backup-db.sh
```

### Application Backups

Regularly backup:
- Database dumps
- `.env.production` file (store securely!)
- Nginx configuration
- Puma service file

## Cost Information

**Current Droplet:**
- 2GB RAM / 1 vCPU: $12/month

**Recommended for Production:**
- Consider 4GB RAM droplet for better performance: $24/month
- Set up automated backups: +20% of droplet cost

## Next Steps

- [ ] Configure SSL/HTTPS with Let's Encrypt
- [ ] Set up domain name and DNS
- [ ] Enable `force_ssl` in Rails config
- [ ] Set up automated database backups
- [ ] Configure monitoring (e.g., New Relic, Datadog)
- [ ] Set up log rotation for application logs
- [ ] Configure firewall rules (UFW)
- [ ] Set up CI/CD pipeline for automated deployments
- [ ] Add performance monitoring
- [ ] Configure error tracking (e.g., Sentry, Rollbar)

## Support Contacts

- **Digital Ocean Support:** https://www.digitalocean.com/support
- **Rails Documentation:** https://guides.rubyonrails.org/
- **Nginx Documentation:** https://nginx.org/en/docs/

---

**Last Updated:** October 3, 2025
**Deployed By:** Fagnner Sousa
**Application:** Currency Converter API v1.0.0
