# 🏗️ Currency Converter - Complete Codebase Guide

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture & Tech Stack](#architecture--tech-stack)
3. [Application Flow](#application-flow)
4. [Database Schema](#database-schema)
5. [Core Components](#core-components)
6. [API Endpoints](#api-endpoints)
7. [Security & Authentication](#security--authentication)
8. [Testing Strategy](#testing-strategy)
9. [How to Use](#how-to-use)

---

## 🎯 Project Overview

This is a **Currency Converter API** built with Ruby on Rails in API-only mode. It allows users to:
- Convert amounts between different currencies (BRL, USD, EUR, JPY)
- Track all conversion transactions
- Secure access with JWT-based authentication
- Rate limiting to prevent abuse

**Business Purpose**: Provide a reliable currency conversion service that records every transaction for auditing and history purposes.

---

## 🏛️ Architecture & Tech Stack

### Technology Stack
```
Backend Framework:  Rails 7.1.5 (API-only mode)
Language:           Ruby 3.3.5
Database:           SQLite3 (dev/test), PostgreSQL (production)
Authentication:     Devise + devise-jwt
External API:       CurrencyAPI.com
HTTP Client:        Faraday (with retry logic)
Testing:            RSpec + WebMock + FactoryBot
Rate Limiting:      Rack::Attack
```

### Architecture Pattern
```
┌─────────────────────────────────────────────────┐
│              CLIENT REQUESTS                    │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│        RACK MIDDLEWARE LAYER                    │
│  - CORS (Cross-Origin)                          │
│  - Rack::Attack (Rate Limiting)                 │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│           AUTHENTICATION LAYER                  │
│  - Devise (User Management)                     │
│  - JWT (Stateless Tokens)                       │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│            CONTROLLERS LAYER                    │
│  - SessionsController (Login/Logout)            │
│  - RegistrationsController (Sign Up)            │
│  - TransactionsController (Conversions)         │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│            SERVICES LAYER                       │
│  - ExchangeRateProvider (Fetch rates)           │
│  - Transactions::Create (Convert & Save)        │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│            MODELS LAYER                         │
│  - User (Devise model)                          │
│  - Transaction (Conversion records)             │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│              DATABASE                           │
│  - users table                                  │
│  - transactions table                           │
│  - jwt_denylist table                           │
└─────────────────────────────────────────────────┘
```

---

## 🔄 Application Flow

### 1. User Registration Flow
```
User → POST /signup
       ↓
   RegistrationsController
       ↓
   Create User (Devise)
       ↓
   Save to Database
       ↓
   Return User JSON + JWT Token
```

### 2. User Login Flow
```
User → POST /login (email + password)
       ↓
   SessionsController
       ↓
   Devise Authentication
       ↓
   Generate JWT Token
       ↓
   Return JWT in Authorization Header
```

### 3. Currency Conversion Flow (Main Business Logic)
```
Authenticated User → POST /api/v1/transactions
                     { from_currency: "USD",
                       to_currency: "BRL", 
                       from_value: 100 }
       ↓
   JWT Validation (Devise + JWT)
       ↓
   TransactionsController#create
       ↓
   Transactions::Create Service
       ├─ Validate Input (currencies, amount)
       ├─ Fetch Exchange Rate
       │    ├─ ExchangeRateProvider
       │    ├─ HTTP Request to CurrencyAPI.com
       │    ├─ Retry Logic (3 attempts)
       │    └─ Parse Response
       ├─ Calculate Conversion
       │    └─ from_value × exchange_rate = to_value
       └─ Save Transaction to Database
       ↓
   Return Transaction JSON
   { transaction_id: 42,
     from_currency: "USD",
     to_currency: "BRL",
     from_value: 100.00,
     to_value: 525.00,
     rate: 5.25,
     timestamp: "2025-10-02T..." }
```

### 4. View Transactions Flow
```
Authenticated User → GET /api/v1/transactions
       ↓
   JWT Validation
       ↓
   TransactionsController#index
       ↓
   Query: current_user.transactions
       ↓
   Return Array of Transactions JSON
```

---

## 💾 Database Schema

### Users Table
```ruby
create_table "users" do |t|
  t.string   "email",              null: false    # User email (unique)
  t.string   "encrypted_password", null: false    # Bcrypt hashed password
  t.datetime "created_at",         null: false
  t.datetime "updated_at",         null: false
  
  # Indexes
  t.index ["email"], unique: true
end
```

### Transactions Table
```ruby
create_table "transactions" do |t|
  t.bigint   "user_id",        null: false    # Foreign key to users
  t.string   "from_currency",  null: false    # Source currency (USD, BRL, EUR, JPY)
  t.string   "to_currency",    null: false    # Target currency
  t.decimal  "from_value",     precision: 12, scale: 4, null: false  # Original amount
  t.decimal  "to_value",       precision: 12, scale: 4, null: false  # Converted amount
  t.decimal  "rate",           precision: 12, scale: 8, null: false  # Exchange rate used
  t.datetime "timestamp",      null: false    # UTC timestamp of conversion
  t.datetime "created_at",     null: false
  t.datetime "updated_at",     null: false
  
  # Foreign Keys
  t.foreign_key "users"
  
  # Indexes for performance
  t.index ["user_id"]
  t.index ["timestamp"]
  t.index ["from_currency", "to_currency"]
end
```

### JWT Denylist Table (for logout/revoked tokens)
```ruby
create_table "jwt_denylist" do |t|
  t.string   "jti",        null: false    # JWT ID (unique token identifier)
  t.datetime "exp",        null: false    # Expiration time
  t.datetime "created_at", null: false
  
  # Indexes
  t.index ["jti"], unique: true
end
```

**Supported Currencies**: `['BRL', 'USD', 'EUR', 'JPY']` (defined in Transaction model)

---

## 🧩 Core Components

### 1. Models

#### User Model (`app/models/user.rb`)
```ruby
class User < ApplicationRecord
  # Devise modules for authentication
  devise :database_authenticatable,      # Login with email/password
         :registerable,                  # User registration
         :jwt_authenticatable,           # JWT token generation
         jwt_revocation_strategy: JwtDenylist  # Token blacklist on logout
  
  # Associations
  has_many :transactions, dependent: :destroy
  
  # Validations (handled by Devise)
  # - Email presence and uniqueness
  # - Password minimum length
end
```

**Purpose**: Manages user authentication and owns all transactions.

#### Transaction Model (`app/models/transaction.rb`)
```ruby
class Transaction < ApplicationRecord
  # Supported currencies constant
  SUPPORTED_CURRENCIES = %w[BRL USD EUR JPY].freeze
  
  # Associations
  belongs_to :user
  
  # Validations
  validates :from_currency, :to_currency, presence: true,
            inclusion: { in: SUPPORTED_CURRENCIES }
  validates :from_value, :to_value, :rate, presence: true,
            numericality: { greater_than: 0 }
  validates :timestamp, presence: true
  
  # Prevent modifying historical records
  before_update :prevent_updates
  
  private
  
  def prevent_updates
    raise ActiveRecord::ReadOnlyRecord if persisted?
  end
end
```

**Purpose**: Immutable record of each currency conversion transaction.

---

### 2. Controllers

#### Base Controller (`app/controllers/api/v1/base_controller.rb`)
```ruby
class Api::V1::BaseController < ApplicationController
  # Require authentication for all API endpoints
  before_action :authenticate_user!
  
  # Custom error handling
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  
  private
  
  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
  
  def unprocessable_entity(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
```

**Purpose**: Shared authentication and error handling for all API endpoints.

#### Transactions Controller (`app/controllers/api/v1/transactions_controller.rb`)
```ruby
class Api::V1::TransactionsController < Api::V1::BaseController
  # GET /api/v1/transactions
  def index
    transactions = current_user.transactions.order(timestamp: :desc)
    render json: transactions
  end
  
  # POST /api/v1/transactions
  def create
    service = Transactions::Create.new(
      user: current_user,
      exchange_rate_provider: ExchangeRateProvider.new
    )
    
    transaction = service.call(
      from_currency: params[:from_currency],
      to_currency: params[:to_currency],
      from_value: params[:from_value]
    )
    
    if service.success?
      render json: transaction, status: :created
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end
end
```

**Purpose**: Handle transaction creation and listing for authenticated users.

#### Sessions Controller (`app/controllers/users/sessions_controller.rb`)
```ruby
class Users::SessionsController < Devise::SessionsController
  respond_to :json
  
  private
  
  # Called after successful login
  def respond_with(resource, _opts = {})
    render json: {
      message: 'Logged in successfully',
      user: { id: resource.id, email: resource.email }
    }, status: :ok
  end
  
  # Called after logout
  def respond_to_on_destroy
    head :no_content
  end
end
```

**Purpose**: Handle user login/logout with JWT token management.

---

### 3. Services (Business Logic)

#### ExchangeRateProvider (`app/services/exchange_rate_provider.rb`)
```ruby
class ExchangeRateProvider
  BASE_URL = 'https://api.currencyapi.com/v3'
  TIMEOUT_SECONDS = 10
  MAX_RETRIES = 3
  
  # Custom error classes
  class ApiError < StandardError; end
  class InvalidCurrencyError < ApiError; end
  class TimeoutError < ApiError; end
  
  def initialize(api_key: nil)
    @api_key = api_key || ENV['CURRENCY_API_KEY']
    raise ArgumentError, 'API key required' if @api_key.blank?
  end
  
  # Fetch exchange rate for a currency pair
  # Returns: BigDecimal (e.g., 5.25 for USD→BRL)
  def fetch_rate(from:, to:)
    validate_currencies!(from, to)
    
    # Same currency = 1.0 rate
    return BigDecimal('1.0') if from == to
    
    # Make API request with retries
    response = fetch_latest_rates(base_currency: from, currencies: [to])
    parse_rate(response, from, to)
  rescue Faraday::TimeoutError => e
    raise TimeoutError, "API timeout: #{e.message}"
  rescue Faraday::Error => e
    raise ApiError, "API error: #{e.message}"
  end
  
  private
  
  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |conn|
      conn.request :url_encoded
      conn.request :retry, {
        max: MAX_RETRIES,              # Retry up to 3 times
        interval: 0.5,                  # Wait 0.5s between retries
        backoff_factor: 2,              # Double wait time each retry
        retry_statuses: [429, 500, 502, 503, 504]  # Retry on these HTTP codes
      }
      conn.adapter Faraday.default_adapter
      conn.options.timeout = TIMEOUT_SECONDS
    end
  end
  
  def fetch_latest_rates(base_currency:, currencies:)
    response = connection.get('latest') do |req|
      req.params['apikey'] = @api_key
      req.params['base_currency'] = base_currency
      req.params['currencies'] = currencies.join(',')
    end
    handle_api_response(response)
  end
  
  def parse_rate(response_body, from, to)
    data = response_body.dig('data', to)
    raise ApiError, "No rate found for #{from} → #{to}" if data.nil?
    
    BigDecimal(data['value'].to_s)  # Use BigDecimal for precision
  end
  
  def validate_currencies!(*currencies)
    valid = Transaction::SUPPORTED_CURRENCIES
    currencies.each do |currency|
      unless valid.include?(currency)
        raise InvalidCurrencyError, "Unsupported: #{currency}"
      end
    end
  end
end
```

**Purpose**: 
- Fetch real-time exchange rates from CurrencyAPI.com
- Handle errors, timeouts, retries
- Return precise rates using BigDecimal

**Why BigDecimal?** Prevents floating-point precision errors in financial calculations.

#### Transactions::Create Service (`app/services/transactions/create.rb`)
```ruby
module Transactions
  class Create
    class ConversionError < StandardError; end
    
    def initialize(user:, exchange_rate_provider: nil)
      @user = user
      @exchange_rate_provider = exchange_rate_provider || ExchangeRateProvider.new
      @errors = []
    end
    
    def call(from_currency:, to_currency:, from_value:)
      # Step 1: Validate input
      validate_input!(from_currency, to_currency, from_value)
      
      # Step 2: Fetch exchange rate from external API
      rate = fetch_exchange_rate(from_currency, to_currency)
      
      # Step 3: Calculate converted value
      to_value = calculate_converted_value(from_value, rate)
      
      # Step 4: Build and save transaction
      transaction = build_transaction(
        from_currency: from_currency,
        to_currency: to_currency,
        from_value: from_value,
        to_value: to_value,
        rate: rate
      )
      
      if transaction.save
        transaction
      else
        @errors = transaction.errors.full_messages
        nil
      end
    rescue ExchangeRateProvider::ApiError => e
      @errors << "Failed to fetch exchange rate: #{e.message}"
      nil
    rescue StandardError => e
      @errors << "Transaction failed: #{e.message}"
      nil
    end
    
    def success?
      @errors.empty?
    end
    
    attr_reader :errors
    
    private
    
    def validate_input!(from_currency, to_currency, from_value)
      @errors = []
      @errors << 'Source currency required' if from_currency.blank?
      @errors << 'Target currency required' if to_currency.blank?
      @errors << 'Amount must be > 0' if from_value.blank? || from_value.to_f <= 0
      @errors << 'Currencies must be different' if from_currency == to_currency
      
      raise ConversionError, @errors.join(', ') if @errors.any?
    end
    
    def fetch_exchange_rate(from_currency, to_currency)
      @exchange_rate_provider.fetch_rate(
        from: from_currency,
        to: to_currency
      )
    end
    
    def calculate_converted_value(from_value, rate)
      from_decimal = BigDecimal(from_value.to_s)
      converted = from_decimal * rate
      converted.round(4)  # Round to 4 decimal places (matches DB precision)
    end
    
    def build_transaction(from_currency:, to_currency:, from_value:, to_value:, rate:)
      @user.transactions.build(
        from_currency: from_currency,
        to_currency: to_currency,
        from_value: BigDecimal(from_value.to_s),
        to_value: to_value,
        rate: rate,
        timestamp: Time.current.utc  # UTC timestamp
      )
    end
  end
end
```

**Purpose**:
- Orchestrate the entire conversion process
- Validate input → Fetch rate → Calculate → Save
- Handle all errors gracefully (returns nil + sets errors)
- Never raises exceptions to controller (defensive programming)

**Design Pattern**: Service Object Pattern (encapsulates business logic)

---

### 4. Security & Configuration

#### JWT Configuration (`config/initializers/devise.rb`)
```ruby
Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = ENV.fetch('JWT_SECRET_KEY')  # Secret key for signing tokens
    jwt.dispatch_requests = [
      ['POST', %r{^/login$}]  # Generate token on login
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/logout$}]  # Revoke token on logout
    ]
    jwt.expiration_time = 1.day.to_i  # Tokens expire after 24 hours
  end
  
  # API mode - no HTML responses
  config.navigational_formats = []
end
```

#### Rate Limiting (`config/initializers/rack_attack.rb`)
```ruby
Rack::Attack.throttle('requests by ip', limit: 100, period: 1.minute) do |req|
  req.ip  # Limit 100 requests per minute per IP
end

Rack::Attack.throttle('logins per email', limit: 5, period: 20.seconds) do |req|
  if req.path == '/login' && req.post?
    req.params['email'].to_s.downcase  # Limit 5 login attempts per 20 seconds
  end
end
```

#### CORS Configuration (`config/initializers/cors.rb`)
```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3001').split(',')
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],  # Expose JWT token header
      credentials: true
  end
end
```

---

## 🔌 API Endpoints

### Authentication Endpoints

#### Sign Up
```http
POST /signup
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}

Response: 201 Created
{
  "status": { "code": 201, "message": "Signed up successfully" },
  "data": {
    "id": 1,
    "email": "user@example.com"
  }
}
Headers:
  Authorization: Bearer <JWT_TOKEN>
```

#### Login
```http
POST /login
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}

Response: 200 OK
{
  "message": "Logged in successfully",
  "user": {
    "id": 1,
    "email": "user@example.com"
  }
}
Headers:
  Authorization: Bearer <JWT_TOKEN>
```

#### Logout
```http
DELETE /logout
Authorization: Bearer <JWT_TOKEN>

Response: 204 No Content
```

### Transaction Endpoints

#### Create Transaction (Convert Currency)
```http
POST /api/v1/transactions
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "from_currency": "USD",
  "to_currency": "BRL",
  "from_value": 100
}

Response: 201 Created
{
  "id": 42,
  "user_id": 1,
  "from_currency": "USD",
  "to_currency": "BRL",
  "from_value": "100.0000",
  "to_value": "525.0000",
  "rate": "5.25000000",
  "timestamp": "2025-10-02T14:30:00.000Z",
  "created_at": "2025-10-02T14:30:00.123Z",
  "updated_at": "2025-10-02T14:30:00.123Z"
}
```

#### List User's Transactions
```http
GET /api/v1/transactions
Authorization: Bearer <JWT_TOKEN>

Response: 200 OK
[
  {
    "id": 42,
    "user_id": 1,
    "from_currency": "USD",
    "to_currency": "BRL",
    "from_value": "100.0000",
    "to_value": "525.0000",
    "rate": "5.25000000",
    "timestamp": "2025-10-02T14:30:00.000Z",
    "created_at": "2025-10-02T14:30:00.123Z",
    "updated_at": "2025-10-02T14:30:00.123Z"
  },
  // ... more transactions
]
```

---

## 🧪 Testing Strategy

### Test Structure
```
spec/
├── models/
│   ├── user_spec.rb              # User model validations
│   └── transaction_spec.rb       # Transaction model validations
├── services/
│   ├── exchange_rate_provider_spec.rb    # External API integration
│   └── transactions/
│       └── create_spec.rb        # Conversion business logic
├── requests/
│   ├── authentication_spec.rb    # Login/logout flows
│   └── transactions_spec.rb      # API endpoint behavior
├── factories/
│   ├── users.rb                  # Test user data
│   └── transactions.rb           # Test transaction data
└── support/
    ├── factory_bot.rb
    ├── shoulda_matchers.rb
    └── webmock.rb                # HTTP stubbing config
```

### Test Coverage (28 tests, 100% passing)

**ExchangeRateProvider (11 tests)**:
- Successful rate fetching
- Decimal precision handling
- API error responses (401, 500)
- Invalid currency handling
- Missing data scenarios
- Network timeouts
- Connection failures

**Transactions::Create (17 tests)**:
- Valid transaction creation
- Currency conversion calculations
- Validation errors (missing fields, invalid amounts)
- Same currency rejection
- Exchange rate provider failures
- Decimal rounding to 4 places

### Running Tests
```bash
# All tests
bundle exec rspec

# Specific test file
bundle exec rspec spec/services/exchange_rate_provider_spec.rb

# With documentation format
bundle exec rspec --format documentation

# With coverage
bundle exec rspec --format documentation --profile
```

---

## 🚀 How to Use

### 1. Setup Environment
```bash
# Clone repository
git clone <repo-url>
cd currency-converter-ruby/backend

# Install dependencies
bundle install

# Copy environment file
cp .env.example .env

# Edit .env and add your API keys
# CURRENCY_API_KEY=<your-key-from-currencyapi.com>
# JWT_SECRET_KEY=<generate-with: rails secret>

# Setup database
rails db:create db:migrate

# Run tests
bundle exec rspec
```

### 2. Start Server
```bash
# Development
rails server -p 3000

# Or with Docker
docker-compose up
```

### 3. Example Usage (with curl)

**Register a user:**
```bash
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }'
```

**Login:**
```bash
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }' \
  -i  # Shows headers including Authorization token
```

**Convert currency (save the JWT token from login):**
```bash
curl -X POST http://localhost:3000/api/v1/transactions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>" \
  -d '{
    "from_currency": "USD",
    "to_currency": "BRL",
    "from_value": 100
  }'
```

**View your transactions:**
```bash
curl -X GET http://localhost:3000/api/v1/transactions \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>"
```

---

## 🎓 Key Concepts & Design Decisions

### 1. **API-Only Mode**
- No views, no sessions, no cookies
- Stateless authentication with JWT
- RESTful JSON responses only

### 2. **Service Objects**
- Business logic separated from controllers
- Reusable, testable, single responsibility
- Controllers are thin (just routing)

### 3. **BigDecimal for Money**
- Prevents floating-point errors (0.1 + 0.2 ≠ 0.3 problem)
- Precise calculations for financial data
- Rounded to 4 decimal places

### 4. **Immutable Transactions**
- Once created, cannot be modified
- Audit trail for compliance
- Historical accuracy guaranteed

### 5. **JWT Strategy**
- Stateless (no server-side sessions)
- Scales horizontally
- Token in Authorization header
- Revocable via denylist

### 6. **Error Handling**
- Services return nil + set errors (don't raise to controller)
- Controllers rescue ActiveRecord exceptions
- External API failures handled gracefully
- Retry logic for transient failures

### 7. **Security Layers**
- JWT authentication (who you are)
- Rate limiting (prevent abuse)
- CORS (restrict origins)
- Input validation (prevent injection)
- Password encryption (bcrypt)

---

## 📊 Data Flow Diagram

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ 1. POST /login {email, password}
       ▼
┌─────────────────────┐
│ SessionsController  │
└──────┬──────────────┘
       │ 2. Devise.authenticate
       ▼
┌─────────────────┐
│   User Model    │
└──────┬──────────┘
       │ 3. Valid? Generate JWT
       ▼
┌─────────────────┐        ┌──────────────────┐
│  Client (JWT)   │───────>│ Rack::Attack     │
└─────────────────┘        └────────┬─────────┘
       │                             │ 4. Rate limit OK?
       │ 5. POST /api/v1/transactions│
       ▼                             ▼
┌────────────────────────────────────────────┐
│      TransactionsController                │
└────────────────┬───────────────────────────┘
                 │ 6. authenticate_user! (JWT)
                 ▼
┌────────────────────────────────────────────┐
│      Transactions::Create Service          │
└────┬───────────────────────────────────────┘
     │ 7. Validate input
     ▼
┌────────────────────────────────────────────┐
│      ExchangeRateProvider                  │
└────┬───────────────────────────────────────┘
     │ 8. HTTP GET to CurrencyAPI.com
     ▼
┌────────────────────────────────────────────┐
│      External API                          │
│      https://api.currencyapi.com/v3/latest │
└────┬───────────────────────────────────────┘
     │ 9. Return rate (e.g., 5.25)
     ▼
┌────────────────────────────────────────────┐
│      Transactions::Create                  │
│      - Calculate: 100 × 5.25 = 525         │
└────┬───────────────────────────────────────┘
     │ 10. Save to database
     ▼
┌────────────────────────────────────────────┐
│      Transaction Model                     │
└────┬───────────────────────────────────────┘
     │ 11. Validate & persist
     ▼
┌────────────────────────────────────────────┐
│      Database (transactions table)         │
└────┬───────────────────────────────────────┘
     │ 12. Success
     ▼
┌────────────────────────────────────────────┐
│      Return JSON response to client        │
└────────────────────────────────────────────┘
```

---

## 🛠️ Troubleshooting

### Common Issues

**1. JWT Token Not Working**
- Check if token is in `Authorization: Bearer <token>` format
- Verify JWT_SECRET_KEY is set in .env
- Check token hasn't expired (24 hour limit)

**2. Currency API Errors**
- Verify CURRENCY_API_KEY is set
- Check API rate limits (free tier)
- Ensure supported currencies (BRL, USD, EUR, JPY)

**3. Database Errors**
- Run migrations: `rails db:migrate`
- Reset test DB: `RAILS_ENV=test rails db:reset`

**4. Tests Failing**
- Check DATABASE_URL points to SQLite: `DATABASE_URL="sqlite3:db/test.sqlite3"`
- Clear WebMock stubs: `bundle exec rspec --format documentation`

---

## 📚 Further Reading

- [Rails API-Only Mode](https://guides.rubyonrails.org/api_app.html)
- [Devise Documentation](https://github.com/heartcombo/devise)
- [devise-jwt Gem](https://github.com/waiting-for-dev/devise-jwt)
- [Service Objects Pattern](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial)
- [BigDecimal in Ruby](https://ruby-doc.org/stdlib-3.0.0/libdoc/bigdecimal/rdoc/BigDecimal.html)
- [CurrencyAPI Documentation](https://currencyapi.com/docs)

---

**Happy Converting! 💱**
