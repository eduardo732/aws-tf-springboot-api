# Project Structure Documentation

## Complete Folder Structure

```
base/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── cl/
│   │   │       └── api/
│   │   │           └── base/
│   │   │               ├── BaseApplication.java
│   │   │               ├── config/
│   │   │               │   ├── OpenApiConfig.java
│   │   │               │   ├── SecurityConfig.java
│   │   │               │   └── WebConfig.java
│   │   │               ├── controller/
│   │   │               │   ├── AuthController.java
│   │   │               │   ├── HealthController.java
│   │   │               │   └── UserController.java
│   │   │               ├── domain/
│   │   │               │   ├── BaseEntity.java
│   │   │               │   ├── RefreshToken.java
│   │   │               │   ├── Role.java
│   │   │               │   └── User.java
│   │   │               ├── dto/
│   │   │               │   ├── request/
│   │   │               │   │   ├── LoginRequest.java
│   │   │               │   │   ├── RefreshTokenRequest.java
│   │   │               │   │   ├── UserCreateRequest.java
│   │   │               │   │   └── UserUpdateRequest.java
│   │   │               │   └── response/
│   │   │               │       ├── ApiResponse.java
│   │   │               │       ├── AuthResponse.java
│   │   │               │       ├── ErrorResponse.java
│   │   │               │       ├── PageResponse.java
│   │   │               │       └── UserResponse.java
│   │   │               ├── exception/
│   │   │               │   ├── BadRequestException.java
│   │   │               │   ├── GlobalExceptionHandler.java
│   │   │               │   ├── ResourceNotFoundException.java
│   │   │               │   ├── TokenRefreshException.java
│   │   │               │   └── UnauthorizedException.java
│   │   │               ├── mapper/
│   │   │               │   └── UserMapper.java
│   │   │               ├── repository/
│   │   │               │   ├── RefreshTokenRepository.java
│   │   │               │   ├── RoleRepository.java
│   │   │               │   └── UserRepository.java
│   │   │               ├── security/
│   │   │               │   ├── JwtAuthenticationEntryPoint.java
│   │   │               │   ├── JwtAuthenticationFilter.java
│   │   │               │   ├── JwtTokenProvider.java
│   │   │               │   ├── UserDetailsImpl.java
│   │   │               │   └── UserDetailsServiceImpl.java
│   │   │               ├── service/
│   │   │               │   ├── AuthService.java
│   │   │               │   └── UserService.java
│   │   │               └── util/
│   │   │                   └── UserSecurity.java
│   │   └── resources/
│   │       ├── application.properties
│   │       ├── application-dev.properties
│   │       ├── application-prod.properties
│   │       ├── logback-spring.xml
│   │       └── db/
│   │           └── migration/
│   │               ├── V1__Initial_schema.sql
│   │               └── V2__Insert_default_admin.sql
│   └── test/
│       └── java/
│           └── cl/
│               └── api/
│                   └── base/
│                       └── BaseApplicationTests.java
├── .gitignore
├── API_TESTING.md
├── Dockerfile
├── docker-compose.yml
├── HELP.md
├── mvnw
├── mvnw.cmd
├── pom.xml
└── README.md
```

## Package Descriptions

### `cl.api.base.config`
Configuration classes for Spring Boot application:
- **OpenApiConfig**: Swagger/OpenAPI documentation configuration
- **SecurityConfig**: Spring Security configuration with JWT
- **WebConfig**: CORS and web MVC configuration

### `cl.api.base.controller`
REST API endpoints:
- **AuthController**: Authentication endpoints (login, register, refresh, logout)
- **HealthController**: Health check endpoint
- **UserController**: User management endpoints (CRUD operations)

### `cl.api.base.domain`
JPA entities representing database tables:
- **BaseEntity**: Abstract base entity with common fields (id, timestamps, deleted)
- **User**: User entity with authentication fields
- **Role**: Role entity for authorization
- **RefreshToken**: Refresh token entity for JWT token management

### `cl.api.base.dto.request`
Data Transfer Objects for incoming API requests:
- **LoginRequest**: Login credentials
- **RefreshTokenRequest**: Refresh token for obtaining new access token
- **UserCreateRequest**: New user registration data
- **UserUpdateRequest**: User update data

### `cl.api.base.dto.response`
Data Transfer Objects for API responses:
- **ApiResponse**: Standard success response wrapper
- **ErrorResponse**: Standard error response wrapper
- **AuthResponse**: Authentication response with tokens and user data
- **UserResponse**: User data response
- **PageResponse**: Paginated response wrapper

### `cl.api.base.exception`
Custom exceptions and global exception handling:
- **GlobalExceptionHandler**: Centralized exception handling with @ControllerAdvice
- **BadRequestException**: HTTP 400 errors
- **ResourceNotFoundException**: HTTP 404 errors
- **UnauthorizedException**: HTTP 401 errors
- **TokenRefreshException**: JWT refresh token errors

### `cl.api.base.mapper`
MapStruct interfaces for entity-DTO mapping:
- **UserMapper**: Maps between User entity and User DTOs

### `cl.api.base.repository`
Spring Data JPA repositories:
- **UserRepository**: User database operations
- **RoleRepository**: Role database operations
- **RefreshTokenRepository**: Refresh token database operations

### `cl.api.base.security`
Security and JWT authentication components:
- **JwtTokenProvider**: JWT token generation and validation
- **JwtAuthenticationFilter**: Filter to validate JWT tokens
- **JwtAuthenticationEntryPoint**: Handles authentication errors
- **UserDetailsImpl**: UserDetails implementation for Spring Security
- **UserDetailsServiceImpl**: Loads user-specific data for authentication

### `cl.api.base.service`
Business logic layer:
- **AuthService**: Authentication and authorization logic
- **UserService**: User management business logic

### `cl.api.base.util`
Utility classes:
- **UserSecurity**: Security helper for ownership checks

## Key Features Implemented

### 1. **Clean Architecture**
- Clear separation of concerns
- Layered architecture (Controller → Service → Repository)
- DTOs prevent direct entity exposure

### 2. **Security**
- JWT access tokens with 15-minute expiration
- Refresh tokens stored in database with 7-day expiration
- BCrypt password hashing
- Role-based access control (RBAC)
- Method-level security with @PreAuthorize

### 3. **Database**
- PostgreSQL integration
- Flyway migrations for version control
- Soft delete functionality
- Audit fields (createdAt, updatedAt)

### 4. **API Best Practices**
- Versioned endpoints (/api/v1)
- Standardized response format
- Pagination and sorting support
- Global exception handling
- Request validation

### 5. **Documentation**
- OpenAPI 3.0 / Swagger UI
- Comprehensive README
- API testing examples
- Code comments

### 6. **Configuration**
- Multiple profiles (dev, prod)
- Environment-based configuration
- Externalized secrets for production

### 7. **Logging**
- SLF4J with Logback
- Profile-specific logging levels
- Async appenders for performance
- Log rotation

### 8. **DevOps Ready**
- Docker support
- Docker Compose for local development
- Health check endpoint
- Actuator for monitoring

## Default Credentials

**Admin User:**
- Username: `admin`
- Password: `Admin123!`
- Role: `ROLE_ADMIN`

## Next Steps

1. **Download Dependencies**: Run `mvn clean install` to download all dependencies
2. **Setup Database**: Create PostgreSQL database and configure credentials
3. **Run Application**: Execute `mvn spring-boot:run`
4. **Test API**: Access Swagger UI at http://localhost:8080/api/v1/swagger-ui.html
5. **Customize**: Extend with additional features as needed

## Adding New Entities

To add a new entity (e.g., Product):

1. **Domain**: Create `Product.java` in `domain/` extending `BaseEntity`
2. **DTOs**: Create request/response DTOs in `dto/request/` and `dto/response/`
3. **Mapper**: Create `ProductMapper.java` in `mapper/`
4. **Repository**: Create `ProductRepository.java` in `repository/`
5. **Service**: Create `ProductService.java` in `service/`
6. **Controller**: Create `ProductController.java` in `controller/`
7. **Migration**: Create migration SQL in `db/migration/`

## Testing Strategy

- **Unit Tests**: Test services and utilities in isolation
- **Integration Tests**: Test controller endpoints with @SpringBootTest
- **Security Tests**: Test authentication and authorization
- **Database Tests**: Use @DataJpaTest for repository tests

## Production Deployment Checklist

- [ ] Change JWT secret to strong random value
- [ ] Configure production database credentials
- [ ] Enable HTTPS/TLS
- [ ] Configure proper CORS origins
- [ ] Set up external logging aggregation
- [ ] Enable monitoring and metrics
- [ ] Configure rate limiting
- [ ] Set up backup strategy
- [ ] Review and harden security settings
- [ ] Configure CI/CD pipeline

