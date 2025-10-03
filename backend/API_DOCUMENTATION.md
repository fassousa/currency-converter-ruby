# API Documentation

This project uses [Swagger/OpenAPI](https://swagger.io/) for API documentation through the [rswag](https://github.com/rswag/rswag) gem.

## Viewing the Documentation

### Interactive Swagger UI

The interactive API documentation is available at:

```
http://localhost:3000/api-docs
```

This provides:
- Complete API endpoint documentation
- Request/response examples
- Interactive "Try it out" functionality
- Authentication flow demonstration

### Raw OpenAPI Specification

The OpenAPI 3.0 specification file is available at:

```
http://localhost:3000/api-docs/v1/swagger.yaml
```

## API Overview

### Base URL
- Development: `http://localhost:3000`
- Production: `https://api.currencyconverter.com` (or your deployed domain)

### Authentication

The API uses JWT (JSON Web Token) authentication. To access protected endpoints:

1. **Sign Up**: POST `/api/v1/auth` with email and password
2. **Sign In**: POST `/api/v1/auth/sign_in` to get a JWT token
3. **Use Token**: Include the token in the Authorization header:
   ```
   Authorization: Bearer <your_jwt_token>
   ```

### Supported Currencies

- BRL (Brazilian Real)
- USD (United States Dollar)
- EUR (Euro)
- JPY (Japanese Yen)

### Main Endpoints

#### Authentication
- `POST /api/v1/auth` - Create account
- `POST /api/v1/auth/sign_in` - Sign in
- `DELETE /api/v1/auth/sign_out` - Sign out

#### Transactions
- `GET /api/v1/transactions` - List user transactions (paginated)
- `POST /api/v1/transactions` - Create currency conversion

#### Health Check
- `GET /api/v1/health` - Check API health status

## Error Responses

All errors follow a consistent format:

```json
{
  "error": {
    "type": "error_code",
    "message": "Human-readable error message",
    "details": {
      "additional": "contextual information"
    }
  }
}
```

### Common Error Types

- `validation_error` - Invalid input parameters (422)
- `currency_not_supported` - Unsupported currency code (422)
- `exchange_rate_unavailable` - External API failure (503)
- `rate_limit_exceeded` - Too many requests (429)
- `UNAUTHORIZED` - Missing or invalid authentication (401)
- `RESOURCE_NOT_FOUND` - Resource not found (404)

## Updating Documentation

After making API changes, regenerate the Swagger documentation:

```bash
cd backend
bundle exec rake rswag:specs:swaggerize
```

This will:
1. Run the integration specs in `spec/integration/`
2. Generate the OpenAPI specification at `swagger/v1/swagger.yaml`
3. Make the updated docs available in Swagger UI

## Example: Testing the API

### 1. Create an Account
```bash
curl -X POST http://localhost:3000/api/v1/auth \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123"}}'
```

### 2. Sign In
```bash
curl -X POST http://localhost:3000/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123"}}' \
  -i
```

Copy the `Authorization` header from the response.

### 3. Create a Transaction
```bash
curl -X POST http://localhost:3000/api/v1/transactions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_token>" \
  -d '{"from_currency":"USD","to_currency":"BRL","from_value":"100.00"}'
```

### 4. List Transactions
```bash
curl -X GET "http://localhost:3000/api/v1/transactions?page=1&per_page=20" \
  -H "Authorization: Bearer <your_token>"
```

## Development

The API documentation specs are located in:
- `spec/integration/api/v1/auth_spec.rb`
- `spec/integration/api/v1/transactions_spec.rb`
- `spec/integration/api/v1/health_spec.rb`

To add new endpoints to the documentation:
1. Create or update integration specs following the rswag format
2. Run `bundle exec rake rswag:specs:swaggerize`
3. Check the updated docs at http://localhost:3000/api-docs
