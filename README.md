# Currency Converter API 💱

Production-ready Rails API for real-time currency conversion with JWT authentication.

🌐 **Live:** http://161.35.142.103 | 📚 **Docs:** http://161.35.142.103/api-docs | ✅ **Tests:** 190 passing (79% coverage)

## Quick Start

```bash
cd backend
bundle install
cp .env.example .env  # Add your CURRENCY_API_KEY
rails db:setup
rails server
```

**Login:** `admin@example.com` / `password`

## API Examples

**Register:**
```bash
curl -X POST http://161.35.142.103/api/v1/auth \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com","password":"Pass123!","password_confirmation":"Pass123!"}}'
```

**Login (get token):**
```bash
curl -i -X POST http://161.35.142.103/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com","password":"Pass123!"}}'
```

**Convert Currency:**
```bash
curl -X POST http://161.35.142.103/api/v1/transactions \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"from_currency":"USD","to_currency":"EUR","from_value":"100.00"}'
```

## Features

- ✅ 10+ currencies with real-time rates ([CurrencyAPI](https://currencyapi.com))
- ✅ JWT authentication (Devise)
- ✅ Transaction history with pagination
- ✅ Swagger documentation
- ✅ 190 tests (RSpec) - 79% coverage
- ✅ Production deployment (Digital Ocean)
- ✅ CI/CD (GitHub Actions)
- ✅ Security scans (Brakeman, Bundler Audit)

## Tech Stack

**Backend:** Rails 7.1 | PostgreSQL | Redis  
**Auth:** Devise + JWT  
**Testing:** RSpec | FactoryBot | SimpleCov  
**DevOps:** GitHub Actions | Nginx + Puma  

## Architecture

- **Service Objects** - Business logic in `app/services/`
- **Error Handling** - Custom exceptions with proper HTTP codes
- **Caching** - 24hr Redis cache for exchange rates
- **Rate Limiting** - Rack::Attack (100 req/min)
- **Performance** - Database indexes, N+1 prevention

## Testing

```bash
bundle exec rspec              # Run tests
bundle exec rubocop            # Lint
bundle exec brakeman           # Security scan
```

## Documentation

- 📖 [Architecture Decisions](ARCHITECTURE_DECISIONS.md) - Technical choices & rationale
- 📖 [Development Guide](DEVELOPMENT.md) - Setup & workflows
- 📖 [API Reference](backend/API_DOCUMENTATION.md) - Endpoints
- 📖 [Deployment](DEPLOYMENT.md) - Production setup
- 📖 [Swagger UI](http://161.35.142.103/api-docs) - Interactive docs

## Technical Challenge ✅

**Required:** 4+ currencies ✓ | External API ✓ | Persistence ✓ | Tests ✓ | English code ✓

**Bonus:** Logging ✓ | Exceptions ✓ | API docs ✓ | Linter ✓ | Deployment ✓ | CI/CD ✓

**Extra:** JWT auth | Caching | Security scanning | Service pattern | Health checks

---

**Built with ❤️ using Ruby on Rails**
