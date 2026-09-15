# Currency Converter API 💱

> 🌍 **Language:** **English** | [Português](README.pt-BR.md)

> **Senior Ruby on Rails Developer Showcase Project**
>
> A production-ready Rails 7.1 API for real-time currency conversion with JWT authentication, comprehensive test coverage (TDD), and cloud deployment featuring automated Scale-to-Zero orchestration.

🌐 **Live Application:** https://currency-converter-ruby.fly.dev | 📚 **Interactive API Docs:** https://currency-converter-ruby.fly.dev/api-docs | ✅ **190 tests passing** (79% coverage)

---

## 🌟 Technical Highlights & Engineering Standards

| Dimension | Architecture & Implementation | Evidence / Code |
| :--- | :--- | :--- |
| **Clean Rails 7.1 Architecture** | API-only mode, Bootsnap optimization, Puma web server, and Service Objects pattern isolating business logic | [Gemfile](backend/Gemfile) • [Services](backend/app/services/) |
| **Relational Database** | Managed PostgreSQL (Supabase) via Supavisor Transaction Pooler, SSL encryption, and auto-migrations on deploy | [database.yml](backend/config/database.yml) • [Schema](backend/db/schema.rb) |
| **Resilient Caching Strategy** | Fault-tolerant 24h caching for exchange rates with graceful fallback from Redis to memory store | [ExchangeRateProvider](backend/app/services/exchange_rate_provider.rb) • [redis.rb](backend/config/initializers/redis.rb) |
| **Test-Driven Development (TDD)** | 190+ specs (Request, Service, Model, Serializer) with 79% code coverage via RSpec & FactoryBot | `bundle exec rspec` • [spec/](backend/spec/) |
| **Cloud Native & DevOps** | Multi-stage Docker container deployed to **Fly.io** with automated **Scale-to-Zero** architecture | [Dockerfile](backend/Dockerfile) • [fly.toml](backend/fly.toml) |
| **Defense-in-Depth Security** | Devise JWT stateless authentication, Rack::Attack rate limiting, Brakeman static analysis & Bundler Audit | [rack_attack.rb](backend/config/initializers/rack_attack.rb) • [Devise](backend/config/initializers/devise.rb) |
| **Observability & Reliability** | JSON-structured logging via Lograge, dual health-check probes (`/up` & `/api/v1/health`), strict RuboCop linting | [HealthController](backend/app/controllers/api/v1/health_controller.rb) • [.rubocop.yml](backend/.rubocop.yml) |
| **Interactive API Spec** | OpenAPI 3.0 specification with live Swagger UI allowing interactive browser testing | [Swagger UI](https://currency-converter-ruby.fly.dev/api-docs) • [swagger.yaml](backend/swagger/v1/swagger.yaml) |

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
- 📖 [Interactive API Docs](https://currency-converter-ruby.fly.dev/api-docs) - Swagger UI

---

## 🛠️ Tech Stack

**Backend:** Rails 7.1 | PostgreSQL (Supabase) | Redis / Memory Store  
**Auth:** Devise + JWT (devise-jwt)  
**Testing:** RSpec | FactoryBot | SimpleCov | Shoulda Matchers  
**Quality:** RuboCop | Brakeman | Bundler Audit  
**DevOps:** Fly.io (Scale-to-Zero) | Docker | Puma | GitHub Actions  
**Monitoring:** Lograge | Rack::Attack | Health Checks  

---

## 🏛️ Engineering Philosophy & Best Practices

This microservice reflects senior-level conscious software engineering principles:

1. **Data-Driven Decisions:** Comprehensive test coverage (79%), structured performance logging, and explicit health monitoring ensure measurable reliability.
2. **Clean System Relationships:** Clear boundaries between controllers, service objects, serializers, and external API gateways foster long-term maintainability.
3. **Impact & Intent Understanding:** Thorough architectural documentation and clean git history explain *why* technical decisions were made, not just *what* code was written.
4. **Continuous Quality & Awareness:** Automated CI/CD pipelines validate linters, vulnerability scanners, and full test suites before any code touches production.

**Production-Grade Capabilities:**
- Cloud-native deployment with automated Scale-to-Zero (cost-effective and efficient)
- Automated vulnerability scanning integrated into CI/CD
- Encrypted SSL/TLS traffic termination via Fly Proxy
- Structured JSON logging (Lograge) optimized for centralized log aggregators

---

**Built with ❤️ using Ruby on Rails** | [View Live Application →](https://currency-converter-ruby.fly.dev/api-docs)
