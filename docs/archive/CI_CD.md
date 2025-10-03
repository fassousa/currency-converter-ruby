# CI/CD Pipeline

This document describes the Continuous Integration and Deployment pipeline for the Currency Converter API.

## GitHub Actions Workflow

The project uses GitHub Actions for automated testing and quality checks on every push and pull request.

### Workflow: CI (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main`, `develop`, or `fagnner_sousa` branches
- Pull requests to `main` or `develop` branches

**Jobs:**

#### 1. Test & Lint
Runs the test suite and code quality checks with required services.

**Services:**
- PostgreSQL 15 (test database)
- Redis 7 (caching)

**Steps:**
1. Checkout code
2. Set up Ruby 3.3.5
3. Install dependencies
4. Setup test database
5. Run RuboCop linter
6. Run RSpec test suite
7. Upload coverage report

**Environment Variables:**
- `RAILS_ENV`: test
- `DATABASE_URL`: postgresql://postgres:postgres@localhost:5432/currency_converter_test
- `REDIS_URL`: redis://localhost:6379/0
- `CURRENCY_API_KEY`: test_api_key_for_ci

#### 2. Security Scan
Runs security vulnerability checks.

**Steps:**
1. Checkout code
2. Set up Ruby 3.3.5
3. Install dependencies
4. Run Brakeman security scanner
5. Run bundler-audit for gem vulnerabilities

## Local Testing

### Run the full CI suite locally:

```bash
# RuboCop linting
cd backend
bundle exec rubocop --parallel

# Test suite
bundle exec rspec

# Security scan
bundle exec brakeman --no-pager

# Bundler audit
gem install bundler-audit
bundle audit check --update
```

## Security Scanning

### Brakeman
Static analysis security scanner for Rails applications.

**Current Status:** ✅ Clean (1 informational warning about Rails EOL)

```bash
bundle exec brakeman --no-pager
```

### Bundler Audit
Checks for known vulnerabilities in gem dependencies.

```bash
gem install bundler-audit
bundle audit check --update
```

## Code Coverage

Test coverage reports are generated with SimpleCov and uploaded as artifacts on every CI run.

**Current Coverage:** 67.54% (285/422 lines)

Coverage reports are available in:
- Local: `backend/coverage/index.html`
- CI: Artifacts tab in GitHub Actions run

## Badge Status (Future)

Add these badges to README.md once the repository is public:

```markdown
![CI](https://github.com/fassousa/currency-converter-ruby/workflows/CI/badge.svg)
![Coverage](https://img.shields.io/badge/coverage-67.54%25-yellow)
```

## Deployment Preparation

### Environment Variables Required

Create a `.env` file or configure these in your deployment platform:

```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/database_name

# Redis
REDIS_URL=redis://host:6379/0

# External APIs
CURRENCY_API_KEY=your_actual_api_key_here

# Rails
RAILS_ENV=production
SECRET_KEY_BASE=generate_with_rails_secret

# Optional
RAILS_LOG_LEVEL=info
RAILS_MAX_THREADS=5
```

### Generate Secret Key Base

```bash
cd backend
rails secret
```

## Future Enhancements

- [ ] Add automated deployment on successful merge to `main`
- [ ] Integrate with code coverage services (Codecov, Coveralls)
- [ ] Add performance regression testing
- [ ] Automated security dependency updates (Dependabot)
- [ ] Staging environment deployment
