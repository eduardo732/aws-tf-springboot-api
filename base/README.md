# Base API - Professional RESTful API Template with Spring Boot 3

A production-ready RESTful API template built with Spring Boot 3, featuring JWT authentication, H2 in-memory database for development, and comprehensive security.

## 🚀 Tech Stack

- **Java 17+**
- **Spring Boot 3.4.x**
- **Spring Security** with JWT authentication
- **H2 Database** (in-memory for development)
- **PostgreSQL** (ready for production)
- **JPA / Hibernate** ORM
- **Flyway** database migrations
- **Custom Mappers** for entity-DTO mapping
- **Lombok** boilerplate reduction
- **OpenAPI 3** (Swagger) documentation
- **SLF4J + Logback** logging
- **Maven** build tool

## ✨ Features

- ✅ JWT Authentication with Refresh Tokens
- ✅ Role-based Authorization (ADMIN, USER, MODERATOR)
- ✅ H2 In-Memory Database (no setup required)
- ✅ PostgreSQL Ready for Production
- ✅ Flyway Database Migrations
- ✅ Global Exception Handling
- ✅ Request Validation
- ✅ Standard API Response Format
- ✅ Pagination & Sorting Support
- ✅ OpenAPI/Swagger Documentation
- ✅ Health Check Endpoint
- ✅ Environment Profiles (dev/prod)
- ✅ Security Best Practices
- ✅ Clean Architecture

## 📁 Project Structure

```
cl.api.base/
├── config/          # Configuration classes (Security, OpenAPI, Web)
├── controller/      # REST controllers
├── domain/          # JPA entities
├── dto/
│   ├── request/    # Request DTOs
│   └── response/   # Response DTOs
├── exception/       # Custom exceptions & global handler
├── mapper/          # Entity-DTO mappers
├── repository/      # JPA repositories
├── security/        # Security & JWT components
├── service/         # Business logic
└── util/           # Utility classes
```

## 🔧 Quick Start

### Prerequisites

- JDK 17 or higher
- Maven 3.8+
- Git

**No database installation required!** This template uses H2 in-memory database.

### Installation

1. Clone the repository:

```bash
git clone <your-repo-url>
cd base
```

2. Run the application:

```bash
./mvnw spring-boot:run
```

That's it! The application will start on `http://localhost:8080`
CREATE DATABASE base_db;
CREATE USER postgres WITH PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE base_db TO postgres;
```

2. Update database credentials in `src/main/resources/application-dev.properties` if needed.

### Build & Run

1. Clone the repository
2. Navigate to project directory
3. Build the project:

```bash
mvn clean install
```

4. Run the application:

```bash
mvn spring-boot:run
```

The API will start at `http://localhost:8080/api/v1`

## 📚 API Documentation

Once the application is running, access the interactive API documentation at:

- **Swagger UI**: http://localhost:8080/api/v1/swagger-ui.html
- **OpenAPI Spec**: http://localhost:8080/api/v1/api-docs

## 🔐 Authentication

### Default Admin Credentials

- **Username**: `admin`
- **Password**: `Admin123!`

### Authentication Flow

1. **Register** new user: `POST /api/v1/auth/register`
2. **Login**: `POST /api/v1/auth/login` - Returns access token and refresh token
3. **Use token**: Include in Authorization header: `Bearer {access_token}`
4. **Refresh token**: `POST /api/v1/auth/refresh` - Get new access token
5. **Logout**: `POST /api/v1/auth/logout` - Revoke refresh tokens

## 🌐 API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout

### Users
- `GET /users` - Get all users (paginated) [ADMIN]
- `GET /users/{id}` - Get user by ID
- `GET /users/username/{username}` - Get user by username [ADMIN]
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Soft delete user [ADMIN]

### Health
- `GET /health` - Health check endpoint

## 📦 API Response Format

### Success Response
```json
{
  "success": true,
  "data": { },
  "timestamp": "2026-03-10T15:30:00",
  "path": "/api/v1/users"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "User not found with id: 1"
  },
  "timestamp": "2026-03-10T15:30:00",
  "path": "/api/v1/users/1"
}
```

## 🔒 Security Features

- JWT access tokens (15 minutes default)
- Refresh tokens stored in database (7 days default)
- BCrypt password encoding
- Role-based access control (RBAC)
- Method-level security with @PreAuthorize
- CORS configuration
- Stateless session management

## 📝 Roles

- **ROLE_USER** - Standard user
- **ROLE_ADMIN** - Administrator
- **ROLE_MODERATOR** - Moderator

## 🗃️ Database Migrations

Flyway manages database schema:

- **V1__Initial_schema.sql** - Creates tables and indexes
- **V2__Insert_default_admin.sql** - Inserts default admin user and roles

Migrations run automatically on application startup.

## 🌍 Profiles

### Development (`dev`)
- Detailed logging
- SQL query logging
- H2 console enabled
- Development database

### Production (`prod`)
- Minimal logging
- Production database from environment variables
- Security headers
- Connection pooling optimized

Switch profiles in `application.properties`:
```properties
spring.profiles.active=dev
```

## 🧪 Testing

Run tests:
```bash
mvn test
```

## 📊 Pagination & Sorting

All list endpoints support pagination and sorting:

```
GET /users?page=0&size=10&sortBy=username&direction=ASC
```

Parameters:
- `page` - Page number (0-based)
- `size` - Items per page
- `sortBy` - Field to sort by
- `direction` - ASC or DESC

## 🚢 Deployment

### Docker (Coming Soon)

### AWS Deployment Considerations

- Use RDS for PostgreSQL/MySQL or keep H2 for stateless deployments
- Store secrets in AWS Secrets Manager
- Use ECS/EKS for container orchestration
- Configure ALB for load balancing
- Use CloudWatch for logging
- Enable auto-scaling

### Environment Variables (Production)

For PostgreSQL in production:
```
DATABASE_URL=jdbc:postgresql://your-db-host:5432/base_db
DATABASE_USERNAME=your-username
DATABASE_PASSWORD=your-password
DATABASE_DRIVER=org.postgresql.Driver
HIBERNATE_DIALECT=org.hibernate.dialect.PostgreSQLDialect
JWT_SECRET=your-secret-key
JWT_ACCESS_EXPIRATION=900000
JWT_REFRESH_EXPIRATION=604800000
```

Or keep H2 for stateless/demo deployments (default).

## 📄 License

This project is licensed under the MIT License.

## 👥 Support

For support, email support@api.cl

## 🎯 Future Enhancements

- [ ] Rate limiting
- [ ] Redis caching
- [ ] Email verification
- [ ] Password reset functionality
- [ ] OAuth2 integration
- [ ] API versioning strategy
- [ ] Comprehensive integration tests
- [ ] Docker & Docker Compose
- [ ] CI/CD pipeline
- [ ] Monitoring & metrics (Prometheus, Grafana)

