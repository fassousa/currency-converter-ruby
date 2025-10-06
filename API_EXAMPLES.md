# API Examples

Quick reference for common API operations. For interactive documentation, visit the [Swagger UI](https://currencyconverter.duckdns.org/api-docs).

## Authentication

### Register New User

```bash
curl -X POST https://currencyconverter.duckdns.org/api/v1/auth \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "Pass123!",
      "password_confirmation": "Pass123!"
    }
  }'
```

**Response (201 Created):**
```json
{
  "status": {
    "code": 201,
    "message": "Signed up successfully."
  },
  "data": {
    "id": 1,
    "email": "user@example.com",
    "created_at": "2025-10-06T10:30:00.000Z"
  }
}
```

### Login (Get JWT Token)

```bash
curl -i -X POST https://currencyconverter.duckdns.org/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "Pass123!"
    }
  }'
```

**Response Headers (200 OK):**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNjk2NTg...
```

**Response Body:**
```json
{
  "status": {
    "code": 200,
    "message": "Logged in successfully."
  },
  "data": {
    "id": 1,
    "email": "user@example.com"
  }
}
```

**Important:** Save the `Authorization` header value for subsequent requests.

## Currency Conversion

### Convert Currency

```bash
curl -X POST https://currencyconverter.duckdns.org/api/v1/transactions \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "from_currency": "USD",
    "to_currency": "EUR",
    "from_value": "100.00"
  }'
```

**Response (201 Created):**
```json
{
  "id": 1,
  "user_id": 1,
  "from_currency": "USD",
  "from_value": "100.00",
  "to_currency": "EUR",
  "to_value": "92.50",
  "exchange_rate": "0.925",
  "created_at": "2025-10-06T10:35:00.000Z"
}
```

### Get Transaction History

```bash
curl -X GET https://currencyconverter.duckdns.org/api/v1/transactions \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**Response (200 OK):**
```json
[
  {
    "id": 2,
    "user_id": 1,
    "from_currency": "BRL",
    "from_value": "500.00",
    "to_currency": "USD",
    "to_value": "100.50",
    "exchange_rate": "0.201",
    "created_at": "2025-10-06T11:00:00.000Z"
  },
  {
    "id": 1,
    "user_id": 1,
    "from_currency": "USD",
    "from_value": "100.00",
    "to_currency": "EUR",
    "to_value": "92.50",
    "exchange_rate": "0.925",
    "created_at": "2025-10-06T10:35:00.000Z"
  }
]
```

### Get Transaction by ID

```bash
curl -X GET https://currencyconverter.duckdns.org/api/v1/transactions/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

**Response (200 OK):**
```json
{
  "id": 1,
  "user_id": 1,
  "from_currency": "USD",
  "from_value": "100.00",
  "to_currency": "EUR",
  "to_value": "92.50",
  "exchange_rate": "0.925",
  "created_at": "2025-10-06T10:35:00.000Z"
}
```

## Supported Currencies

```bash
curl -X GET https://currencyconverter.duckdns.org/api/v1/transactions/currencies \
  -H "Content-Type: application/json"
```

**Response (200 OK):**
```json
{
  "currencies": [
    "USD", "EUR", "BRL", "GBP", "JPY", 
    "AUD", "CAD", "CHF", "CNY", "INR", "MXN"
  ]
}
```

## Health Check

```bash
curl -X GET https://currencyconverter.duckdns.org/api/v1/health \
  -H "Content-Type: application/json"
```

**Response (200 OK):**
```json
{
  "status": "healthy",
  "services": {
    "database": {"status": "up"},
    "cache": {"status": "up"},
    "external_api": {"status": "configured"}
  }
}
```

## Error Responses

### Unauthorized (401)

```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

### Validation Error (422)

```json
{
  "error": "Validation failed",
  "details": {
    "from_value": ["must be greater than 0"],
    "to_currency": ["is not a valid currency"]
  }
}
```

### Currency Not Supported (400)

```json
{
  "error": "Currency XYZ is not supported. Supported currencies: USD, EUR, BRL, ..."
}
```

### Rate Limit Exceeded (429)

```json
{
  "error": "Rate limit exceeded. Try again in 60 seconds."
}
```

## Local Development

For local testing, replace `https://currencyconverter.duckdns.org` with `http://localhost:3000`:

```bash
curl -X POST http://localhost:3000/api/v1/auth \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"Pass123!","password_confirmation":"Pass123!"}}'
```

---

📖 **More documentation:** [README](README.md) | [API Documentation](backend/API_DOCUMENTATION.md) | [Swagger UI](https://currencyconverter.duckdns.org/api-docs)
