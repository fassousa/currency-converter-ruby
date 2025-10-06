# Currency Converter API 💱

> **Senior Ruby on Rails Developer - Technical Assessment for Jaya Tech**

Production-ready Rails API for real-time currency conversion with JWT authentication, complete test coverage, and automated CI/CD deployment.

🌐 **Live:** https://currencyconverter.duckdns.org | 📚 **API Docs:** https://currencyconverter.duckdns.org/api-docs | ✅ **190 tests passing** (79% coverage)

---

## ✅ Assessment Requirements Met

| Requirement | Implementation | Evidence |
|------------|----------------|----------|
| **Rails 7.1+** | ✅ Rails 7.1.5 | [Gemfile](backend/Gemfile) |
| **PostgreSQL** | ✅ Production DB | [database.yml](backend/config/database.yml) |
| **Redis** | ✅ Cache & Sidekiq ready | [redis.rb](backend/config/initializers/redis.rb) |
| **RSpec Tests** | ✅ 190 tests, 79% coverage | `bundle exec rspec` |
| **CI/CD** | ✅ GitHub Actions | [.github/workflows/ci-cd.yml](.github/workflows/ci-cd.yml) |
| **Git & Agile** | ✅ PRs, conventional commits | [Commit history](https://github.com/fassousa/currency-converter-ruby/commits/main) |

**Bonus:** Docker ✅ | Security Scans (Brakeman) ✅ | API Documentation (Swagger) ✅ | Production Deployment ✅ | HTTPS/SSL ✅

---

## 🚀 Quick Start (30 seconds)

```bash
cd backend
bundle install
cp .env.example .env  # Add your CURRENCY_API_KEY from currencyapi.com
rails db:setup
rails server
```

**Test login:** `admin@example.com` / `password`  
**Try it:** Visit http://localhost:3000/api-docs for interactive API documentation

---

## 🏗️ Architecture & Technical Decisions

**Design Patterns:**
- Service Objects for business logic isolation
- Repository pattern for external API calls
- Custom error handling with proper HTTP status codes

**Performance:**
- Redis caching (24hr TTL for exchange rates)
- Database indexes on foreign keys and search columns
- N+1 query prevention with eager loading

**Security:**
- JWT authentication (Devise)
- Rate limiting: 100 req/min (Rack::Attack)
- Security scanning: Brakeman + Bundler Audit
- HTTPS with Let's Encrypt SSL

**Quality Assurance:**
- 190 RSpec tests with FactoryBot
- RuboCop linting with Rails best practices
- 79% code coverage (SimpleCov)
- CI/CD pipeline with automated tests

📖 **Deep dive:** [Architecture Decisions](ARCHITECTURE_DECISIONS.md) | [Development Guide](DEVELOPMENT.md) | [Deployment Guide](DEPLOYMENT.md)

---

## 📋 Core Features

- ✅ **10+ currencies** with real-time exchange rates ([CurrencyAPI](https://currencyapi.com))
- ✅ **JWT authentication** for secure API access
- ✅ **Transaction history** with pagination and user isolation
- ✅ **Comprehensive logging** with Lograge (JSON structured logs)
- ✅ **Health checks** for monitoring (database, cache, external API)
- ✅ **Swagger documentation** auto-generated from RSpec tests

---

## 🧪 Testing & Quality

```bash
bundle exec rspec              # Run all tests (190 passing)
bundle exec rubocop            # Lint code style
bundle exec brakeman           # Security vulnerability scan
open coverage/index.html       # View test coverage report
```

**Test Coverage Breakdown:**
- Controllers: Request specs with authentication
- Services: Business logic unit tests
- Models: Validation and association tests
- Serializers: JSON output format tests
- Error handling: Custom exception specs

---

## 📚 Documentation

- 📖 [API Examples](backend/API_DOCUMENTATION.md) - Request/response samples
- 📖 [Architecture Decisions](ARCHITECTURE_DECISIONS.md) - Technical choices & rationale
- 📖 [Development Guide](DEVELOPMENT.md) - Local setup & Docker workflows
- 📖 [Deployment Guide](DEPLOYMENT.md) ([PT-BR](DEPLOYMENT.pt-BR.md)) - Production setup with HTTPS
- 📖 [Interactive API Docs](https://currencyconverter.duckdns.org/api-docs) - Swagger UI

---

## 🛠️ Tech Stack

**Backend:** Rails 7.1 | PostgreSQL | Redis  
**Auth:** Devise + JWT (devise-jwt)  
**Testing:** RSpec | FactoryBot | SimpleCov | Shoulda Matchers  
**Quality:** RuboCop | Brakeman | Bundler Audit  
**DevOps:** GitHub Actions | Docker | Nginx + Puma  
**Monitoring:** Lograge | Rack::Attack | Health Checks  

---

## 🌟 Why This Implementation?

**For Jaya Tech's "Conscious Software Engineering":**

1. **Data-Driven Decisions:** Comprehensive test coverage and monitoring provide confidence
2. **Healthy Relationships:** Clean architecture enables team collaboration
3. **Impact Understanding:** Documentation explains *why*, not just *what*
4. **Self-Awareness:** Each commit follows conventions, tests validate assumptions

**Production-Ready Features:**
- Deployed with CI/CD, not just "works on my machine"
- Security scans in pipeline, not post-deployment surprises
- Real SSL certificate, not self-signed placeholders
- Structured logging for debugging, not `puts` statements

---

**Built with ❤️ using Ruby on Rails** | [View Live Application →](https://currencyconverter.duckdns.org/api-docs)
