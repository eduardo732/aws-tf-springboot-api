# Arquitectura del Sistema

## Diagrama de Infraestructura AWS con Terraform

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet                                │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ HTTPS/HTTP
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                    AWS Cloud (us-east-1)                         │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              VPC Default (10.0.0.0/16)                     │ │
│  │                                                            │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │          Security Group (springboot-api-sg)          │ │ │
│  │  │                                                      │ │ │
│  │  │  Inbound Rules:                                     │ │ │
│  │  │  • Port 22  (SSH)       → Restricted IP            │ │ │
│  │  │  • Port 80  (HTTP)      → 0.0.0.0/0                │ │ │
│  │  │  • Port 8080 (API)      → 0.0.0.0/0                │ │ │
│  │  │  • Port 4566 (LocalStack) → Restricted IP          │ │ │
│  │  │                                                      │ │ │
│  │  │  ┌────────────────────────────────────────────────┐ │ │ │
│  │  │  │    EC2 Instance (t3.medium)                    │ │ │ │
│  │  │  │    Amazon Linux 2023                           │ │ │ │
│  │  │  │                                                 │ │ │ │
│  │  │  │  ┌─────────────────────────────────────────┐  │ │ │ │
│  │  │  │  │       Docker Engine                     │  │ │ │ │
│  │  │  │  │                                         │  │ │ │ │
│  │  │  │  │  ┌─────────────────────────────────┐   │  │ │ │ │
│  │  │  │  │  │  LocalStack Container           │   │  │ │ │ │
│  │  │  │  │  │  Port: 4566                     │   │  │ │ │ │
│  │  │  │  │  │                                 │   │  │ │ │ │
│  │  │  │  │  │  Services:                      │   │  │ │ │ │
│  │  │  │  │  │  • S3                           │   │  │ │ │ │
│  │  │  │  │  │  • DynamoDB                     │   │  │ │ │ │
│  │  │  │  │  │  • SQS                          │   │  │ │ │ │
│  │  │  │  │  │  • SNS                          │   │  │ │ │ │
│  │  │  │  │  └─────────────────────────────────┘   │  │ │ │ │
│  │  │  │  │                                         │  │ │ │ │
│  │  │  │  │  ┌─────────────────────────────────┐   │  │ │ │ │
│  │  │  │  │  │  Spring Boot API Container      │   │  │ │ │ │
│  │  │  │  │  │  Port: 8080                     │   │  │ │ │ │
│  │  │  │  │  │                                 │   │  │ │ │ │
│  │  │  │  │  │  • REST API (/api/v1)           │   │  │ │ │ │
│  │  │  │  │  │  • JWT Authentication           │   │  │ │ │ │
│  │  │  │  │  │  • H2 Database (in-memory)      │   │  │ │ │ │
│  │  │  │  │  │  • Swagger UI                   │   │  │ │ │ │
│  │  │  │  │  │  • Profile: local               │   │  │ │ │ │
│  │  │  │  │  └─────────────────────────────────┘   │  │ │ │ │
│  │  │  │  │                                         │  │ │ │ │
│  │  │  │  └─────────────────────────────────────────┘  │ │ │ │
│  │  │  │                                                 │ │ │ │
│  │  │  │  Storage: 30 GB gp3 EBS Volume                 │ │ │ │
│  │  │  └────────────────────────────────────────────────┘ │ │ │
│  │  │                                                      │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                                                            │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │             Elastic IP (Static)                      │ │ │
│  │  │             Associated to EC2                        │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                                                            │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Flujo de Despliegue con Terraform

```
┌─────────────────┐
│  Developer PC   │
│                 │
│  1. Edita .tf   │
│     files       │
└────────┬────────┘
         │
         │ terraform init
         │
         ▼
┌─────────────────┐
│  Terraform CLI  │
│                 │
│  2. Planifica   │
│     recursos    │
└────────┬────────┘
         │
         │ terraform apply
         │
         ▼
┌─────────────────┐
│   AWS API       │
│                 │
│  3. Crea        │
│     recursos    │
└────────┬────────┘
         │
         ├─────────► EC2 Instance
         │
         ├─────────► Security Group
         │
         ├─────────► Elastic IP
         │
         └─────────► Key Pair
                    
         ▼
┌─────────────────┐
│  EC2 Instance   │
│                 │
│  4. user-data   │
│     script runs │
└────────┬────────┘
         │
         ├─────────► Install Docker
         │
         ├─────────► Clone Git Repo
         │
         ├─────────► docker-compose up
         │
         └─────────► Start Services
```

## Arquitectura de la Aplicación

```
┌──────────────────────────────────────────────────────────┐
│                    Spring Boot API                        │
│                                                           │
│  ┌────────────────────────────────────────────────────┐  │
│  │              Controller Layer                      │  │
│  │  • AuthController    • UserController             │  │
│  │  • HealthController                                │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                 │
│  ┌──────────────────────▼─────────────────────────────┐  │
│  │              Service Layer                         │  │
│  │  • AuthService       • UserService                 │  │
│  │  • RefreshTokenService                             │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                 │
│  ┌──────────────────────▼─────────────────────────────┐  │
│  │            Repository Layer (JPA)                  │  │
│  │  • UserRepository    • RoleRepository              │  │
│  │  • RefreshTokenRepository                          │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                 │
│                         ▼                                 │
│              ┌──────────────────┐                        │
│              │  H2 Database     │                        │
│              │  (In-Memory)     │                        │
│              └──────────────────┘                        │
│                                                           │
│  ┌────────────────────────────────────────────────────┐  │
│  │              Security Layer                        │  │
│  │  • JwtAuthenticationFilter                         │  │
│  │  • JwtTokenProvider                                │  │
│  │  • UserDetailsServiceImpl                          │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

## Flujo de Autenticación JWT

```
Client                API                    Database
  │                    │                         │
  │  POST /auth/login  │                         │
  ├───────────────────►│                         │
  │                    │  Query user             │
  │                    ├────────────────────────►│
  │                    │◄────────────────────────┤
  │                    │  Validate password      │
  │                    │  Generate JWT           │
  │                    │  Create refresh token   │
  │                    ├────────────────────────►│
  │                    │◄────────────────────────┤
  │                    │                         │
  │  {access_token,    │                         │
  │   refresh_token}   │                         │
  │◄───────────────────┤                         │
  │                    │                         │
  │  GET /users        │                         │
  │  Authorization:    │                         │
  │  Bearer <token>    │                         │
  ├───────────────────►│                         │
  │                    │  Validate JWT           │
  │                    │  Extract username       │
  │                    │  Load user details      │
  │                    ├────────────────────────►│
  │                    │◄────────────────────────┤
  │                    │  Process request        │
  │                    │                         │
  │  {user data}       │                         │
  │◄───────────────────┤                         │
  │                    │                         │
```

## Integración con LocalStack

```
Spring Boot API ──────► LocalStack ──────► Emulated AWS Services
                        (Port 4566)
                                                │
                        ┌───────────────────────┼──────────────────┐
                        │                       │                  │
                        ▼                       ▼                  ▼
                    ┌───────┐             ┌──────────┐       ┌───────┐
                    │   S3  │             │ DynamoDB │       │  SQS  │
                    └───────┘             └──────────┘       └───────┘
                    
                    (When AWS SDK is configured)
```

## Recursos Terraform Creados

```
terraform/
├── main.tf
│   ├─► aws_instance.app_server
│   │   ├── AMI: Amazon Linux 2023
│   │   ├── Instance Type: t3.medium
│   │   ├── User Data: userdata.sh
│   │   └── EBS: 30GB gp3
│   │
│   ├─► aws_eip.app_eip
│   │   └── Associated to EC2
│   │
│   └─► aws_key_pair.app_key
│       └── Public key for SSH
│
└── security.tf
    └─► aws_security_group.app_sg
        ├── Ingress: SSH (22)
        ├── Ingress: HTTP (80)
        ├── Ingress: API (8080)
        ├── Ingress: LocalStack (4566)
        └── Egress: All traffic
```

## Estado del Sistema después del Despliegue

```
✅ EC2 Instance        → Running
✅ Elastic IP          → Associated
✅ Security Group      → Rules Applied
✅ Docker Engine       → Installed & Running
✅ LocalStack Container → Running on :4566
✅ API Container       → Running on :8080
✅ Health Endpoints    → Accessible
✅ Swagger UI          → Accessible
```

## URLs de Acceso Post-Deployment

```
┌────────────────────────────────────────────────────────┐
│  Servicio          │  URL                              │
├────────────────────┼───────────────────────────────────┤
│  API Health        │  http://<IP>:8080/api/v1/health   │
│  Swagger UI        │  http://<IP>:8080/api/v1/swagger-ui/index.html │
│  API Docs (JSON)   │  http://<IP>:8080/api/v1/api-docs │
│  LocalStack Health │  http://<IP>:4566/_localstack/health │
│  SSH Access        │  ssh -i key ec2-user@<IP>         │
└────────────────────────────────────────────────────────┘
```

## Costos Mensuales Estimados

```
┌─────────────────────────┬─────────────┬──────────────┐
│  Recurso                │  Costo/hora │  Costo/mes   │
├─────────────────────────┼─────────────┼──────────────┤
│  EC2 t3.medium          │  $0.0416    │  ~$30.00     │
│  EBS gp3 30GB           │  -          │  ~$2.40      │
│  Elastic IP (asociada)  │  $0.00      │  $0.00       │
│  Data Transfer (1GB)    │  -          │  ~$0.09      │
├─────────────────────────┼─────────────┼──────────────┤
│  TOTAL                  │  -          │  ~$32-35/mes │
└─────────────────────────┴─────────────┴──────────────┘

Nota: Precios para región us-east-1 (2026)
```

## Monitoring y Logs

```
┌──────────────────────────────────────────────────────┐
│  Log Location             │  Command                 │
├───────────────────────────┼──────────────────────────┤
│  User Data Script         │  sudo cat /var/log/user-data.log │
│  Docker Compose           │  cd app && docker-compose logs -f │
│  Spring Boot Logs         │  docker logs <container_id> │
│  LocalStack Logs          │  docker logs localstack  │
│  System Logs              │  sudo journalctl -xe     │
└──────────────────────────────────────────────────────┘
```

