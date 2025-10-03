# Development Guide

This guide covers local development setup and workflows for the Currency Converter API.

## Table of Contents

- [Quick Start](#quick-start)
- [Development Workflows](#development-workflows)
- [Running Tests](#running-tests)
- [Code Quality](#code-quality)
- [API Testing](#api-testing)
- [Troubleshooting](#troubleshooting)

## Quick Start

### Prerequisites

- Ruby 3.3.5
- PostgreSQL (for Docker workflow) or SQLite (for quick local dev)
- Redis (optional, for caching)
- Node.js (for some tooling)

### Option 1: Quick Local Development (SQLite)

Fastest way to get started - no Docker required:

```bash
cd backend
bundle install
cp .env.example .env
bin/rails db:create db:migrate db:seed
bin/rails server
```

**Default dev user:** `admin@example.com` / `password` (see `backend/db/seeds.rb`)

Access the API at: `http://localhost:3000`

### Option 2: Docker Compose (PostgreSQL + Redis)

Production-like environment with full services:

```bash
make setup
```

This will:
- Copy `.env.example` to `backend/.env` if missing
- Build Docker images
- Start PostgreSQL + Redis + Rails
- Run `bin/rails db:prepare`

Access the API at: `http://localhost:3000`

## Development Workflows

### Environment Variables

Copy the example environment file and configure:

```bash
cp backend/.env.example backend/.env
```

**Required variables:**
- `CURRENCY_API_KEY` - Get from [CurrencyAPI.com](https://currencyapi.com)
- `DEVISE_JWT_SECRET_KEY` - Generate with `rails secret`
- `DATABASE_URL` - For PostgreSQL (Docker only)

### Database Commands

```bash
# Create database
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Seed with sample data
bin/rails db:seed

# Reset database
bin/rails db:reset

# Rollback last migration
bin/rails db:rollback
```

### Running the Server

```bash
# Development server
bin/rails server

# With specific port
bin/rails server -p 3001

# Background (detached)
bin/rails server -d
```

### Rails Console

```bash
# Start console
bin/rails console

# In console, test the API:
user = User.create!(email: 'test@example.com', password: 'password')
token = user.generate_jwt
```

## Running Tests

### Full Test Suite

```bash
cd backend
bundle exec rspec
```

### Run Specific Tests

```bash
# Single file
bundle exec rspec spec/models/user_spec.rb

# Single example
bundle exec rspec spec/models/user_spec.rb:10

# By pattern
bundle exec rspec spec/models/

# With coverage
COVERAGE=true bundle exec rspec
```

### Test Output Options

```bash
# Detailed output
bundle exec rspec --format documentation

# Failures only
bundle exec rspec --only-failures

# Run failed tests first
bundle exec rspec --order defined
```

## Code Quality

### RuboCop (Linter)

```bash
# Check all files
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -A

# Check specific files
bundle exec rubocop app/models/user.rb

# Generate TODO file for existing offenses
bundle exec rubocop --auto-gen-config
```

### Brakeman (Security Scanner)

```bash
# Run security scan
bundle exec brakeman

# Output to file
bundle exec brakeman -o brakeman-report.html

# Check specific paths
bundle exec brakeman -p app/controllers/
```

### Bundler Audit (Gem Vulnerabilities)

```bash
# Check for vulnerable gems
bundle audit check --update
```

### SimpleCov (Test Coverage)

```bash
# Generate coverage report
COVERAGE=true bundle exec rspec

# Open coverage report
open coverage/index.html
```

Coverage report shows:
- Line coverage percentage
- Branch coverage
- Uncovered lines highlighted

## API Testing

### Using cURL

**Register a user:**
```bash
curl -X POST http://localhost:3000/api/v1/auth \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com","password":"password123","password_confirmation":"password123"}}'
```

**Login:**
```bash
curl -i -X POST http://localhost:3000/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com","password":"password123"}}'
```

**Convert currency:**
```bash
curl -X POST http://localhost:3000/api/v1/transactions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"from_currency":"USD","to_currency":"EUR","from_value":"100.00"}'
```

**Get user transactions:**
```bash
curl http://localhost:3000/api/v1/transactions \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Using Swagger UI

Access interactive API documentation:

```
http://localhost:3000/api-docs
```

Features:
- Try out all endpoints
- View request/response schemas
- No need for cURL commands

### Using HTTPie (Alternative)

```bash
# Install HTTPie
pip install httpie

# Register
http POST localhost:3000/api/v1/auth user[email]=user@example.com user[password]=pass123 user[password_confirmation]=pass123

# Login
http POST localhost:3000/api/v1/auth/sign_in user[email]=user@example.com user[password]=pass123

# Convert (with token)
http POST localhost:3000/api/v1/transactions from_currency=USD to_currency=EUR from_value=100 "Authorization: Bearer TOKEN"
```

## Troubleshooting

### Common Issues

**Port already in use:**
```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 PID
```

**Database connection errors:**
```bash
# Check PostgreSQL is running
pg_isready

# Restart PostgreSQL (Mac)
brew services restart postgresql

# Restart PostgreSQL (Linux)
sudo systemctl restart postgresql
```

**Redis connection errors:**
```bash
# Check Redis is running
redis-cli ping

# Start Redis (Mac)
brew services start redis

# Start Redis (Linux)
sudo systemctl start redis
```

**Bundle install fails:**
```bash
# Update bundler
gem install bundler

# Clean and reinstall
rm Gemfile.lock
bundle install
```

**Migrations fail:**
```bash
# Drop and recreate database
bin/rails db:drop db:create db:migrate db:seed
```

**Tests fail randomly:**
```bash
# Clear test database
RAILS_ENV=test bin/rails db:reset

# Clear cache
bin/rails tmp:cache:clear
```

### Logs

**View development logs:**
```bash
tail -f log/development.log
```

**View test logs:**
```bash
tail -f log/test.log
```

**Clear logs:**
```bash
bin/rails log:clear
```

### Performance Monitoring

**Check for N+1 queries:**

Bullet gem is configured in development. Watch for console warnings about:
- N+1 queries
- Unused eager loading
- Missing counter caches

**View slow queries:**
```bash
# In development.log, search for queries taking > 100ms
grep "Completed in" log/development.log | sort -k3 -n
```

## Development Best Practices

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push and create PR
git push origin feature/your-feature
```

### Before Committing

```bash
# Run all checks
bundle exec rubocop
bundle exec brakeman
bundle exec rspec
```

Or use the Makefile:
```bash
make test
```

### Database Schema Changes

1. Create migration: `bin/rails g migration AddColumnToTable`
2. Edit migration file
3. Run: `bin/rails db:migrate`
4. Update model validations/associations
5. Add tests for new behavior
6. Update API documentation if needed

### Adding New Endpoints

1. Add route in `config/routes.rb`
2. Create controller action
3. Add request spec in `spec/requests/`
4. Update Swagger docs in `spec/swagger_helper.rb`
5. Test with Swagger UI

## Useful Make Commands

```bash
# Setup project
make setup

# Run tests
make test

# Start server
make server

# Open Rails console
make console

# View logs
make logs

# Clean up
make clean
```

See `Makefile` for all available commands.

## Additional Resources

- [Rails Guides](https://guides.rubyonrails.org/)
- [RSpec Documentation](https://rspec.info/)
- [Devise Documentation](https://github.com/heartcombo/devise)
- [RuboCop Ruby Style Guide](https://rubocop.org/)
- [API Documentation](backend/API_DOCUMENTATION.md)
- [Deployment Guide](DEPLOYMENT.md)
