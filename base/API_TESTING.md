# API Testing Examples

This file contains cURL examples for testing the Base API endpoints.

## Authentication

### Register New User
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "testuser@example.com",
    "password": "Test123!",
    "firstName": "Test",
    "lastName": "User"
  }'
```

### Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "Admin123!"
  }'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 900000,
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@api.cl",
      "firstName": "Admin",
      "lastName": "User",
      "enabled": true,
      "roles": ["ROLE_ADMIN"]
    }
  },
  "timestamp": "2026-03-10T15:30:00",
  "path": "/auth/login"
}
```

### Refresh Token
```bash
curl -X POST http://localhost:8080/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "YOUR_REFRESH_TOKEN_HERE"
  }'
```

### Logout
```bash
curl -X POST http://localhost:8080/api/v1/auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

## Users

### Get All Users (Paginated)
```bash
curl -X GET "http://localhost:8080/api/v1/users?page=0&size=10&sortBy=username&direction=ASC" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

### Get User by ID
```bash
curl -X GET http://localhost:8080/api/v1/users/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

### Get User by Username
```bash
curl -X GET http://localhost:8080/api/v1/users/username/admin \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

### Update User
```bash
curl -X PUT http://localhost:8080/api/v1/users/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newemail@example.com",
    "firstName": "Updated",
    "lastName": "Name"
  }'
```

### Delete User (Soft Delete)
```bash
curl -X DELETE http://localhost:8080/api/v1/users/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

## Health Check

### Check API Health
```bash
curl -X GET http://localhost:8080/api/v1/health
```

**Response:**
```json
{
  "status": "UP",
  "service": "base-api",
  "version": "1.0.0"
}
```

## Postman Collection

Import these examples into Postman for easier testing:

1. Create a new Collection
2. Add environment variables:
   - `baseUrl`: http://localhost:8080/api/v1
   - `accessToken`: (will be set automatically after login)
   - `refreshToken`: (will be set automatically after login)

3. Add Pre-request Script for authenticated endpoints:
```javascript
pm.request.headers.add({
    key: 'Authorization',
    value: 'Bearer ' + pm.environment.get('accessToken')
});
```

4. Add Test Script for login endpoint to save tokens:
```javascript
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set('accessToken', jsonData.data.accessToken);
    pm.environment.set('refreshToken', jsonData.data.refreshToken);
}
```

## Testing with HTTPie

### Install HTTPie
```bash
pip install httpie
```

### Login Example
```bash
http POST :8080/api/v1/auth/login \
  username=admin \
  password=Admin123!
```

### Get Users Example
```bash
http GET :8080/api/v1/users \
  "Authorization:Bearer YOUR_ACCESS_TOKEN_HERE"
```

