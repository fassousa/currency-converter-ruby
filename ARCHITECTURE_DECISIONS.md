# Architecture Decisions — Currency Converter# Architecture Decisions — Currency Converter



## Rails API Setup## Rails API Setup

Choose Rails API mode to provide a focused, minimal backend offering JSON endpoints and Rails conventions (controllers, models, services) without view layers — speeds development and reduces attack surface.Choose Rails API mode to provide a focused, minimal backend offering JSON endpoints and Rails conventions (controllers, models, services) without view layers — speeds development and reduces attack surface.



## Database Setup## Database Setup

Use PostgreSQL in production for robustness and SQLite for local dev to remove friction; decimal columns with explicit precision (4 decimals for currency values, 8 for rates) ensure monetary accuracy and DB indexes speed common queries; enforce NOT NULL and foreign key constraints at database level.Use PostgreSQL in production for robustness and SQLite for local dev to remove friction; decimal columns with explicit precision (4 decimals for currency values, 8 for rates) ensure monetary accuracy and DB indexes speed common queries; enforce NOT NULL and foreign key constraints at database level.



## Docker Configuration## Docker Configuration

Docker-compose models the production stack (web, db, redis) for reproducible environments and onboarding; local sqlite supports quick development without containers when desired; Procfile.dev enables local development with Foreman or Overmind.Docker-compose models the production stack (web, db, redis) for reproducible environments and onboarding; local sqlite supports quick development without containers when desired; Procfile.dev enables local development with Foreman or Overmind.



## Authentication & Security## Authentication & Security

Use Devise + devise-jwt for token-based authentication with JWT storage in database (JTIMatcher strategy); implement rate limiting via Rack::Attack (5 reqs/sec per IP, 100/min for auth) to prevent abuse; enable CORS for controlled frontend access and disable rate limiting in test environment for reliable specs.Use Devise + devise-jwt for token-based authentication with JWT storage in database (JTIMatcher strategy); implement rate limiting via Rack::Attack (5 reqs/sec per IP, 100/min for auth) to prevent abuse; enable CORS for controlled frontend access and disable rate limiting in test environment for reliable specs.



## Currency API Integration## Currency API Integration

Implement ExchangeRateProvider service with Faraday HTTP client for CurrencyAPI.com integration; add retry logic with exponential backoff (3 retries, 2x backoff) for transient failures (429, 500, 502, 503, 504); use WebMock in tests to stub external API calls and ensure test isolation; support 4 currencies (BRL, USD, EUR, JPY).Implement ExchangeRateProvider service with Faraday HTTP client for CurrencyAPI.com integration; add retry logic with exponential backoff (3 retries, 2x backoff) for transient failures (429, 500, 502, 503, 504); use WebMock in tests to stub external API calls and ensure test isolation; support 4 currencies (BRL, USD, EUR, JPY).



## Transaction Management## Transaction Management

Business logic lives in service objects (Transactions::Create) so controllers remain thin, logic is testable, and transaction persistence is clearly separated from API concerns; validate currencies against supported list and enforce decimal precision for monetary values; transactions are immutable once created (audit trail).Business logic lives in service objects (Transactions::Create) so controllers remain thin, logic is testable, and transaction persistence is clearly separated from API concerns; validate currencies against supported list and enforce decimal precision for monetary values; transactions are immutable once created (audit trail).



## API Endpoints & Versioning## API Endpoints & Versioning

Namespace all endpoints under `/api/v1/` for future versioning; implement RESTful routes for authentication (`POST /api/v1/auth`, `POST /api/v1/auth/sign_in`, `DELETE /api/v1/auth/sign_out`) and transactions (`GET/POST /api/v1/transactions`) with JWT authentication requirement; health check endpoint at `/api/v1/health` for monitoring.Namespace all endpoints under `/api/v1/` for future versioning; implement RESTful routes for authentication (`POST /api/v1/auth`, `POST /api/v1/auth/sign_in`, `DELETE /api/v1/auth/sign_out`) and transactions (`GET/POST /api/v1/transactions`) with JWT authentication requirement; health check endpoint at `/api/v1/health` for monitoring.



## Serialization & Responses## Serialization & Responses

Use dedicated serializer classes (TransactionSerializer) for consistent JSON formatting with decimal precision preserved as strings; extract Paginatable concern for reusable pagination logic; implement pagination metadata (`meta`) with Kaminari (default 20/page, max 100/page) following JSON:API best practices; standardize error responses with ErrorResponses concern including error codes and HTTP status.Use dedicated serializer classes (TransactionSerializer) for consistent JSON formatting with decimal precision preserved as strings; extract Paginatable concern for reusable pagination logic; implement pagination metadata (`meta`) with Kaminari (default 20/page, max 100/page) following JSON:API best practices; standardize error responses with ErrorResponses concern including error codes and HTTP status.



## Caching & Performance## Caching & Performance

Redis cache for exchange rates (24-hour TTL, daily cache keys: `exchange_rate:FROM:TO:YYYY-MM-DD`); performance monitoring middleware logs all API requests and warns on slow requests (>1000ms threshold); implements cache hit/miss logging for observability; Bullet gem detects N+1 queries in development/test.Redis cache for exchange rates (24-hour TTL, daily cache keys: `exchange_rate:FROM:TO:YYYY-MM-DD`); performance monitoring middleware logs all API requests and warns on slow requests (>1000ms threshold); implements cache hit/miss logging for observability; Bullet gem detects N+1 queries in development/test.



## Logging & Monitoring## Logging & Monitoring

ApiCallLogger service provides structured JSON logging for external API calls (request/response/duration); performance monitoring middleware tracks request duration and logs slow requests; cache operations logged (hit/miss events); error responses include correlation data for debugging; all logs timestamped in ISO8601 format.ApiCallLogger service provides structured JSON logging for external API calls (request/response/duration); performance monitoring middleware tracks request duration and logs slow requests; cache operations logged (hit/miss events); error responses include correlation data for debugging; all logs timestamped in ISO8601 format.



## Error Handling## Error Handling

Custom error hierarchy (ApplicationError base class) with specific errors: CurrencyNotSupportedError, ExchangeRateUnavailableError, RateLimitExceededError; ExchangeRateProvider implements retry logic with exponential backoff and timeout handling (10s timeout); errors include structured details and proper HTTP status codes; ErrorResponses concern standardizes JSON error format.Custom error hierarchy (ApplicationError base class) with specific errors: CurrencyNotSupportedError, ExchangeRateUnavailableError, RateLimitExceededError; ExchangeRateProvider implements retry logic with exponential backoff and timeout handling (10s timeout); errors include structured details and proper HTTP status codes; ErrorResponses concern standardizes JSON error format.



## Testing## Testing

Comprehensive RSpec test suite (117 examples, 0 failures) with FactoryBot for test data, Shoulda Matchers for model validations, and WebMock for API stubbing; achieve 79.51% test coverage with SimpleCov (322/405 lines); use Bullet for N+1 query detection; organize specs by type (models, services, requests, middleware) and use shared examples to reduce duplication; refactored specs for conciseness (e.g., transaction_spec: 338→140 lines, 49→22 tests).Comprehensive RSpec test suite (117 examples, 0 failures) with FactoryBot for test data, Shoulda Matchers for model validations, and WebMock for API stubbing; achieve 79.51% test coverage with SimpleCov (322/405 lines); use Bullet for N+1 query detection; organize specs by type (models, services, requests, middleware) and use shared examples to reduce duplication; refactored specs for conciseness (e.g., transaction_spec: 338→140 lines, 49→22 tests).



## CI/CD and Deployment## CI/CD and Deployment

GitHub Actions workflow for CI/CD with PostgreSQL and Redis services; automated testing, linting (RuboCop), and coverage reporting; deployment to DigitalOcean App Platform with automatic migrations; Docker-based deployment with health checks; environment-specific configurations.GitHub Actions workflow for CI/CD with PostgreSQL and Redis services; automated testing, linting (RuboCop), and coverage reporting; deployment to DigitalOcean App Platform with automatic migrations; Docker-based deployment with health checks; environment-specific configurations.



## Code Quality & Linting## Code Quality & Linting

RuboCop with rails, performance, and rspec extensions; consistent code style enforced in CI; automated fixes for safe offenses; comprehensive coverage tracking with SimpleCov; code organized in concerns for reusability (Paginatable, ErrorResponses).RuboCop with rails, performance, and rspec extensions; consistent code style enforced in CI; automated fixes for safe offenses; comprehensive coverage tracking with SimpleCov; code organized in concerns for reusability (Paginatable, ErrorResponses).



## Frontend (Optional)## Frontend (Optional)

API-first design enables any frontend framework; comprehensive API documentation with Swagger/OpenAPI via rswag; CORS configured for controlled access; pagination metadata and error responses follow industry standards for easy consumption.API-first design enables any frontend framework; comprehensive API documentation with Swagger/OpenAPI via rswag; CORS configured for controlled access; pagination metadata and error responses follow industry standards for easy consumption.



## Secrets and Environment## Secrets and Environment

Store secrets outside the repository; provide `.env.example` for local onboarding and ensure `.env` is gitignored to avoid leaking credentials; required secrets: DATABASE_URL, REDIS_URL, CURRENCY_API_KEY, DEVISE_JWT_SECRET_KEY.Store secrets outside the repository; provide `.env.example` for local onboarding and ensure `.env` is gitignored to avoid leaking credentials; required secrets: DATABASE_URL, REDIS_URL, CURRENCY_API_KEY, DEVISE_JWT_SECRET_KEY.



## Trade-offs## Trade-offs

Favor pragmatic, well-tested solutions over premature optimization: simple service objects, Redis caching for external API calls (24hr TTL), and Rails conventions to keep the codebase maintainable; extracted concerns (Paginatable, ErrorResponses) for reusability; refactored test suite for conciseness while maintaining coverage; comprehensive logging and monitoring for production observability.Favor pragmatic, well-tested solutions over premature optimization: simple service objects, Redis caching for external API calls (24hr TTL), and Rails conventions to keep the codebase maintainable; extracted concerns (Paginatable, ErrorResponses) for reusability; refactored test suite for conciseness while maintaining coverage; comprehensive logging and monitoring for production observability.



------



## Key Design Decisions Explained## Key Design Decisions Explained



### Why Redis Caching with 24-Hour TTL?### Why Redis Caching with 24-Hour TTL?

**Decision**: Cache exchange rates in Redis with 24-hour expiration and daily cache keys.**Decision**: Cache exchange rates in Redis with 24-hour expiration and daily cache keys.



**Rationale**:**Rationale**:

- Reduces external API calls and costs (CurrencyAPI rate limits)- Reduces external API calls and costs (CurrencyAPI rate limits)

- Exchange rates don't change frequently enough to warrant real-time fetching- Exchange rates don't change frequently enough to warrant real-time fetching

- Daily cache keys (`exchange_rate:FROM:TO:YYYY-MM-DD`) ensure automatic invalidation- Daily cache keys (`exchange_rate:FROM:TO:YYYY-MM-DD`) ensure automatic invalidation

- Redis provides fast reads and scales horizontally- Redis provides fast reads and scales horizontally

- Cache hit/miss logging enables monitoring cache effectiveness- Cache hit/miss logging enables monitoring cache effectiveness



**Implementation**: ExchangeRateProvider checks cache first, falls back to API; structured logging tracks cache performance.**Implementation**: ExchangeRateProvider checks cache first, falls back to API; structured logging tracks cache performance.



**Trade-off**: Rates may be up to 24 hours old, but acceptable for most use cases. Could reduce TTL for real-time trading apps.**Trade-off**: Rates may be up to 24 hours old, but acceptable for most use cases. Could reduce TTL for real-time trading apps.



### Why Concerns for Pagination and Error Responses?### Why Concerns for Pagination and Error Responses?

**Decision**: Extract Paginatable and ErrorResponses into controller concerns.**Decision**: Extract Paginatable and ErrorResponses into controller concerns.



**Rationale**:**Rationale**:

- DRY principle: reusable across multiple controllers- DRY principle: reusable across multiple controllers

- Separates cross-cutting concerns from business logic- Separates cross-cutting concerns from business logic

- Makes controllers thinner and easier to test- Makes controllers thinner and easier to test

- Consistent pagination and error handling across API- Consistent pagination and error handling across API



**Pattern Used**: Rails concerns with `included` hook and helper methods.**Pattern Used**: Rails concerns with `included` hook and helper methods.



**Achievement**: TransactionsController reduced from 60→42 lines by extracting pagination logic.**Achievement**: TransactionsController reduced from 60→42 lines by extracting pagination logic.



### Why Pagination with Meta?### Why Pagination with Meta?

**Decision**: Return pagination metadata in a separate `meta` object rather than mixing with data.**Decision**: Return pagination metadata in a separate `meta` object rather than mixing with data.



**Rationale**:**Rationale**:

- Separates concerns: data vs. information about data- Separates concerns: data vs. information about data

- Follows JSON:API specification and industry standards (GitHub, Stripe APIs)- Follows JSON:API specification and industry standards (GitHub, Stripe APIs)

- Enables frontend pagination UI without extra count queries- Enables frontend pagination UI without extra count queries

- Provides navigation context (current_page, next_page, prev_page, total_pages, total_count)- Provides navigation context (current_page, next_page, prev_page, total_pages, total_count)



**Alternative Considered**: Embedding page info in headers (Link, X-Total-Count) — rejected because headers are harder to access in frontend frameworks and less discoverable.**Alternative Considered**: Embedding page info in headers (Link, X-Total-Count) — rejected because headers are harder to access in frontend frameworks and less discoverable.



### Why Custom Serializers over ActiveModel Serializers?### Why Custom Serializers over ActiveModel Serializers?

**Decision**: Build lightweight serializer classes instead of using the heavy active_model_serializers gem.**Decision**: Build lightweight serializer classes instead of using the heavy active_model_serializers gem.



**Rationale**:**Rationale**:

- Simpler, faster, and more maintainable for small projects- Simpler, faster, and more maintainable for small projects

- No external gem dependency to manage- No external gem dependency to manage

- Full control over JSON structure- Full control over JSON structure

- Easy to test and debug- Easy to test and debug

- Avoids gem deprecation issues- Avoids gem deprecation issues

- Preserves decimal precision by converting to strings- Preserves decimal precision by converting to strings



**Trade-off**: Less feature-rich than AMS, but our needs are simple (basic JSON formatting).**Trade-off**: Less feature-rich than AMS, but our needs are simple (basic JSON formatting).



### Why Service Objects for Business Logic?### Why Service Objects for Business Logic?

**Decision**: Extract transaction creation logic into `Transactions::Create` service object.**Decision**: Extract transaction creation logic into `Transactions::Create` service object.



**Rationale**:**Rationale**:

- Keeps controllers thin (Single Responsibility Principle)- Keeps controllers thin (Single Responsibility Principle)

- Makes business logic testable in isolation- Makes business logic testable in isolation

- Reusable across different contexts (API, console, background jobs)- Reusable across different contexts (API, console, background jobs)

- Clear separation: controllers handle HTTP, services handle business rules- Clear separation: controllers handle HTTP, services handle business rules

- Encapsulates multi-step processes (validate → fetch rate → calculate → persist)- Encapsulates multi-step processes (validate → fetch rate → calculate → persist)



**Pattern Used**: Command pattern with `call` method returning result and exposing `errors`.**Pattern Used**: Command pattern with `call` method returning result and exposing `errors`.



**Achievement**: 80-line service handles complex transaction creation with rate fetching and calculation.**Achievement**: 80-line service handles complex transaction creation with rate fetching and calculation.



### Why Devise + JWT over Custom Auth?### Why Devise + JWT over Custom Auth?

**Decision**: Use Devise with devise-jwt for authentication instead of building custom solution.**Decision**: Use Devise with devise-jwt for authentication instead of building custom solution.



**Rationale**:**Rationale**:

- Battle-tested gem with security best practices built-in- Battle-tested gem with security best practices built-in

- Handles password hashing, token revocation, session management- Handles password hashing, token revocation, session management

- JWT stored in database (JTIMatcher whitelist strategy) for better security- JWT stored in database (JTIMatcher whitelist strategy) for better security

- Saves development time while maintaining security- Saves development time while maintaining security

- Integrates seamlessly with Rails- Integrates seamlessly with Rails



**Trade-off**: Slightly heavier than custom solution, but security is critical and shouldn't be DIY.**Trade-off**: Slightly heavier than custom solution, but security is critical and shouldn't be DIY.



### Why Kaminari for Pagination?### Why Kaminari for Pagination?

**Decision**: Use Kaminari gem with configurable limits (default 20, max 100).**Decision**: Use Kaminari gem with configurable limits (default 20, max 100).



**Rationale**:**Rationale**:

- Industry standard pagination gem for Rails- Industry standard pagination gem for Rails

- Works seamlessly with ActiveRecord- Works seamlessly with ActiveRecord

- Provides rich metadata (total_count, total_pages, etc.)- Provides rich metadata (total_count, total_pages, etc.)

- Prevents accidental large queries that could DOS the API- Prevents accidental large queries that could DOS the API



**Alternative Considered**: Manual LIMIT/OFFSET — rejected because error-prone and lacks metadata.**Alternative Considered**: Manual LIMIT/OFFSET — rejected because error-prone and lacks metadata.



### Why RSpec over Minitest?### Why RSpec over Minitest?

**Decision**: Use RSpec for testing with FactoryBot, Shoulda Matchers, and WebMock.**Decision**: Use RSpec for testing with FactoryBot, Shoulda Matchers, and WebMock.



**Rationale**:**Rationale**:

- More expressive syntax (describe, context, it)- More expressive syntax (describe, context, it)

- Better ecosystem for request specs and API testing- Better ecosystem for request specs and API testing

- Shared examples reduce duplication- Shared examples reduce duplication

- Industry preference for API testing- Industry preference for API testing

- Better output formatting for documentation- Better output formatting for documentation



**Achievement**: 79.51% coverage, 117 passing tests, 0 failures, comprehensive test suite refactored for conciseness.**Achievement**: 79.51% coverage, 117 passing tests, 0 failures, comprehensive test suite refactored for conciseness.



### Why Structured JSON Logging?### Why Structured JSON Logging?

**Decision**: Implement ApiCallLogger service with structured JSON logs for all external calls.**Decision**: Implement ApiCallLogger service with structured JSON logs for all external calls.



**Rationale**:**Rationale**:

- Machine-parseable logs for log aggregation tools (Datadog, Splunk)- Machine-parseable logs for log aggregation tools (Datadog, Splunk)

- Easy to search and filter by fields (service, endpoint, duration, success)- Easy to search and filter by fields (service, endpoint, duration, success)

- Includes correlation data (timestamp, status, error messages)- Includes correlation data (timestamp, status, error messages)

- Enables performance monitoring and debugging- Enables performance monitoring and debugging

- Separate log levels (info for success, error for failures, debug for cache)- Separate log levels (info for success, error for failures, debug for cache)



**Implementation**: Logs all API requests/responses with duration tracking; cache hit/miss events logged separately.**Implementation**: Logs all API requests/responses with duration tracking; cache hit/miss events logged separately.



### Why Retry Logic with Exponential Backoff?### Why Retry Logic with Exponential Backoff?

**Decision**: Faraday retry middleware with 3 attempts, exponential backoff (2x), retry on 429/5xx.**Decision**: Faraday retry middleware with 3 attempts, exponential backoff (2x), retry on 429/5xx.



**Rationale**:**Rationale**:

- Handles transient failures (network glitches, temporary server issues)- Handles transient failures (network glitches, temporary server issues)

- Exponential backoff prevents overwhelming failing services- Exponential backoff prevents overwhelming failing services

- Retries only on retriable status codes (429, 500, 502, 503, 504)- Retries only on retriable status codes (429, 500, 502, 503, 504)

- Configurable timeout (10s) prevents indefinite waiting- Configurable timeout (10s) prevents indefinite waiting

- Logs retry attempts for observability- Logs retry attempts for observability



**Trade-off**: Adds latency on failures, but improves reliability significantly.**Trade-off**: Adds latency on failures, but improves reliability significantly.



### Why Extract Concerns for Code Reusability?### Why Extract Concerns for Code Reusability?

**Decision**: Extract Paginatable and ErrorResponses concerns from controllers.**Decision**: Extract Paginatable and ErrorResponses concerns from controllers.



**Rationale**:**Rationale**:

- DRY: Reusable pagination and error handling across all controllers- DRY: Reusable pagination and error handling across all controllers

- Thin controllers: Business logic stays in services, HTTP concerns in concerns- Thin controllers: Business logic stays in services, HTTP concerns in concerns

- Easier testing: Concerns can be tested in isolation- Easier testing: Concerns can be tested in isolation

- Consistent API responses: Same pagination format and error structure everywhere- Consistent API responses: Same pagination format and error structure everywhere



**Achievement**: TransactionsController reduced from 60→42 lines; standardized responses across API.**Achievement**: TransactionsController reduced from 60→42 lines; standardized responses across API.



### Why Refactor Test Specs for Conciseness?### Why Refactor Test Specs for Conciseness?

**Decision**: Systematically refactor test specs to reduce redundancy while maintaining coverage.**Decision**: Systematically refactor test specs to reduce redundancy while maintaining coverage.



**Rationale**:**Rationale**:

- Easier to read and maintain (less code to understand)- Easier to read and maintain (less code to understand)

- Faster test execution (fewer redundant tests)- Faster test execution (fewer redundant tests)

- Focus on meaningful assertions vs. testing framework capabilities- Focus on meaningful assertions vs. testing framework capabilities

- Use shoulda-matchers for common validations (no need to manually test numericality)- Use shoulda-matchers for common validations (no need to manually test numericality)

- Combine related assertions (e.g., decimal precision tests)- Combine related assertions (e.g., decimal precision tests)



**Achievement**: transaction_spec reduced from 338→140 lines (58%), 49→22 tests; create_spec 217→160 lines; coverage maintained at 79.51%.**Achievement**: transaction_spec reduced from 338→140 lines (58%), 49→22 tests; create_spec 217→160 lines; coverage maintained at 79.51%.



**Trade-off**: Fewer individual test cases, but more focused and meaningful tests.**Trade-off**: Fewer individual test cases, but more focused and meaningful tests.


