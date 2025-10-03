# Deployment Guide - Digital Ocean Droplet

This guide walks you through deploying the Currency Converter API to a Digital Ocean Droplet.

## Prerequisites

- Digital Ocean account
- Domain name (optional, but recommended)
- SSH key generated on your local machine
- CurrencyAPI key

## Step 1: Create Digital Ocean Droplet

### 1.1 Droplet Configuration
- **Image**: Ubuntu 22.04 LTS
- **Plan**: Basic - $12/month (2 GB RAM / 1 CPU / 50 GB SSD)
- **Location**: Choose closest to your users (e.g., NYC3)
- **Authentication**: SSH Key (RECOMMENDED)

### 1.2 Generate SSH Key (if you don't have one)
```bash
# On your local machine
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# Copy the output and add it to Digital Ocean
```

### 1.3 Create Droplet
- Add your SSH key during creation
- Note the IP address once created

## Step 2: Initial Server Setup

### 2.1 Connect to Your Droplet
```bash
ssh root@your_droplet_ip
```

### 2.2 Update System
```bash
apt update && apt upgrade -y
```

### 2.3 Create Deploy User
```bash
# Create a new user (more secure than using root)
adduser deploy
usermod -aG sudo deploy

# Copy SSH keys to deploy user
rsync --archive --chown=deploy:deploy ~/.ssh /home/deploy
```

### 2.4 Configure Firewall
```bash
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### 2.5 Switch to Deploy User
```bash
su - deploy
```

## Step 3: Install Dependencies

### 3.1 Install Ruby (via rbenv)
```bash
# Install dependencies
sudo apt install -y git curl libssl-dev libreadline-dev zlib1g-dev \
  autoconf bison build-essential libyaml-dev libreadline-dev \
  libncurses5-dev libffi-dev libgdbm-dev

# Install rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Add to PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby 3.3.5
rbenv install 3.3.5
rbenv global 3.3.5

# Verify
ruby -v
```

### 3.2 Install Node.js (for asset compilation if needed)
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

### 3.3 Install PostgreSQL
```bash
sudo apt install -y postgresql postgresql-contrib libpq-dev

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database user
sudo -u postgres createuser -s deploy
sudo -u postgres psql -c "ALTER USER deploy WITH PASSWORD 'your_secure_password';"

# Create production database
sudo -u postgres createdb -O deploy currency_converter_production
```

### 3.4 Install Redis
```bash
sudo apt install -y redis-server

# Start Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Verify
redis-cli ping  # Should return PONG
```

### 3.5 Install Nginx
```bash
sudo apt install -y nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

## Step 4: Deploy Application

### 4.1 Clone Repository
```bash
cd ~
git clone https://github.com/fassousa/currency-converter-ruby.git
cd currency-converter-ruby/backend
```

### 4.2 Install Bundler and Dependencies
```bash
gem install bundler
bundle install --without development test
```

### 4.3 Configure Environment Variables
```bash
# Create .env file
cat > .env << 'EOF'
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true

# Database
DATABASE_URL=postgresql://deploy:your_secure_password@localhost/currency_converter_production

# Redis
REDIS_URL=redis://localhost:6379/0

# API Keys
CURRENCY_API_KEY=your_actual_currencyapi_key

# Rails Secret (generate with: rails secret)
SECRET_KEY_BASE=your_generated_secret_key_base

# Server
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
EOF

# Generate secret key base
SECRET_KEY_BASE=$(rails secret)
sed -i "s/your_generated_secret_key_base/$SECRET_KEY_BASE/" .env
```

### 4.4 Setup Database
```bash
# Load environment
export $(cat .env | xargs)

# Create and migrate database
rails db:create db:migrate

# Optional: Load seed data
rails db:seed
```

### 4.5 Precompile Assets (if any)
```bash
rails assets:precompile
```

### 4.6 Test the Application
```bash
# Test server runs correctly
rails server -e production -b 0.0.0.0 -p 3000

# In another terminal, test:
curl http://your_droplet_ip:3000/health
```

## Step 5: Configure Systemd Service

### 5.1 Create Puma Service
```bash
sudo nano /etc/systemd/system/puma.service
```

Add this content:
```ini
[Unit]
Description=Puma Rails Server
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/currency-converter-ruby/backend
EnvironmentFile=/home/deploy/currency-converter-ruby/backend/.env
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 5.2 Start Puma Service
```bash
sudo systemctl daemon-reload
sudo systemctl start puma
sudo systemctl enable puma

# Check status
sudo systemctl status puma
```

## Step 6: Configure Nginx

### 6.1 Create Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/currency-converter
```

Add this content:
```nginx
upstream puma {
  server unix:///home/deploy/currency-converter-ruby/backend/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name your_domain.com;  # Replace with your domain or droplet IP

  root /home/deploy/currency-converter-ruby/backend/public;

  location / {
    proxy_pass http://puma;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  location ~ ^/(assets|packs)/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

### 6.2 Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/currency-converter /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl restart nginx
```

### 6.3 Update Puma Configuration
```bash
nano ~/currency-converter-ruby/backend/config/puma.rb
```

Make sure it includes:
```ruby
bind "unix:///home/deploy/currency-converter-ruby/backend/tmp/sockets/puma.sock"
```

Restart Puma:
```bash
sudo systemctl restart puma
```

## Step 7: SSL Certificate (Optional but Recommended)

### 7.1 Install Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 7.2 Obtain Certificate
```bash
# Make sure your domain points to your droplet IP first
sudo certbot --nginx -d your_domain.com
```

### 7.3 Auto-Renewal
```bash
# Test renewal
sudo certbot renew --dry-run
```

## Step 8: Verify Deployment

### 8.1 Test Endpoints
```bash
# Health check
curl http://your_droplet_ip/health

# Or with domain
curl https://your_domain.com/health

# Check API
curl https://your_domain.com/api/v1/health
```

### 8.2 Test Authentication
```bash
# Sign up
curl -X POST https://your_domain.com/api/v1/auth/sign_up \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }'
```

## Step 9: Maintenance & Updates

### 9.1 Deploy Updates
```bash
cd ~/currency-converter-ruby
git pull origin main
cd backend
bundle install --without development test
rails db:migrate RAILS_ENV=production
rails assets:precompile RAILS_ENV=production
sudo systemctl restart puma
```

### 9.2 View Logs
```bash
# Application logs
tail -f ~/currency-converter-ruby/backend/log/production.log

# Puma service logs
sudo journalctl -u puma -f

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

### 9.3 Monitor Services
```bash
# Check service status
sudo systemctl status puma
sudo systemctl status nginx
sudo systemctl status postgresql
sudo systemctl status redis-server

# Check resource usage
htop
df -h
free -m
```

## Step 10: Security Best Practices

### 10.1 Regular Updates
```bash
# Weekly updates
sudo apt update && sudo apt upgrade -y
```

### 10.2 Configure Fail2Ban (Prevent brute force)
```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 10.3 Backup Database
```bash
# Create backup script
nano ~/backup.sh
```

Add:
```bash
#!/bin/bash
BACKUP_DIR="/home/deploy/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
pg_dump currency_converter_production > $BACKUP_DIR/backup_$DATE.sql
# Keep only last 7 days
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
```

Make executable and add to cron:
```bash
chmod +x ~/backup.sh
crontab -e
# Add: 0 2 * * * /home/deploy/backup.sh
```

## Troubleshooting

### Puma won't start
```bash
# Check logs
sudo journalctl -u puma -n 50

# Check permissions
ls -la ~/currency-converter-ruby/backend/tmp/sockets/

# Recreate socket directory
mkdir -p ~/currency-converter-ruby/backend/tmp/sockets
```

### Nginx 502 Bad Gateway
```bash
# Check if Puma is running
sudo systemctl status puma

# Check socket file exists
ls -la ~/currency-converter-ruby/backend/tmp/sockets/puma.sock

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

### Database connection issues
```bash
# Test PostgreSQL connection
psql -U deploy -d currency_converter_production -h localhost

# Check DATABASE_URL in .env
cat ~/currency-converter-ruby/backend/.env | grep DATABASE_URL
```

## Quick Reference

### Important Paths
- Application: `/home/deploy/currency-converter-ruby/backend`
- Logs: `/home/deploy/currency-converter-ruby/backend/log/production.log`
- Nginx config: `/etc/nginx/sites-available/currency-converter`
- Puma service: `/etc/systemd/system/puma.service`

### Common Commands
```bash
# Restart services
sudo systemctl restart puma
sudo systemctl restart nginx

# View logs
tail -f ~/currency-converter-ruby/backend/log/production.log
sudo journalctl -u puma -f

# Rails console
cd ~/currency-converter-ruby/backend
rails console -e production

# Database console
psql -U deploy -d currency_converter_production
```

## Cost Estimation

- Droplet ($12/month): Basic plan with 2GB RAM
- Domain (optional): ~$12/year
- **Total**: ~$12/month + domain cost

## Next Steps

1. ✅ Server setup complete
2. ✅ Application deployed
3. ✅ SSL configured
4. 🔄 Monitor application performance
5. 🔄 Set up monitoring (optional: New Relic, DataDog)
6. 🔄 Configure backups
7. 🔄 Set up CI/CD for automatic deployments

---

**Congratulations!** Your Currency Converter API is now live on Digital Ocean! 🚀
