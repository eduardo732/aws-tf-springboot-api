# Infraestructura Local con LocalStack - Guía Completa

Esta guía te enseña a usar LocalStack para simular servicios AWS en tu máquina local **sin ningún costo**.

## 🎯 ¿Qué es LocalStack?

LocalStack es un emulador de servicios AWS que corre completamente en tu máquina local. Te permite:

- ✅ Desarrollar y probar aplicaciones que usan AWS **sin conectarte a AWS real**
- ✅ **Cero costos** - todo es local
- ✅ Rapidez - no hay latencia de red
- ✅ Privacidad - tus datos nunca salen de tu PC
- ✅ Simular S3, DynamoDB, SQS, SNS, Lambda, y más

## 🏗️ Arquitectura

```
┌────────────────────────────────────────────────────────────────┐
│                      Tu PC (localhost)                          │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Docker Network (base-network)                │ │
│  │                                                           │ │
│  │  ┌─────────────────────┐    ┌─────────────────────────┐  │ │
│  │  │  LocalStack         │    │  Spring Boot API        │  │ │
│  │  │  Container          │◄───┤  Container              │  │ │
│  │  │                     │    │                         │  │ │
│  │  │  Puerto: 4566       │    │  Puerto: 8080           │  │ │
│  │  │                     │    │                         │  │ │
│  │  │  Servicios AWS:     │    │  Profile: local         │  │ │
│  │  │  • S3               │    │  Endpoint:              │  │ │
│  │  │  • DynamoDB         │    │  http://localstack:4566 │  │ │
│  │  │  • SQS              │    │                         │  │ │
│  │  │  • SNS              │    │  H2 Database            │  │ │
│  │  │  • Lambda           │    │  JWT Auth               │  │ │
│  │  │  • Secrets Manager  │    │  REST API               │  │ │
│  │  │  • CloudWatch       │    │                         │  │ │
│  │  └─────────────────────┘    └─────────────────────────┘  │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  Acceso desde tu máquina:                                      │
│  • API: http://localhost:8080/api/v1                           │
│  • LocalStack: http://localhost:4566                           │
│  • Swagger: http://localhost:8080/api/v1/swagger-ui/index.html│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisitos

### 1. Docker Desktop

```powershell
# Verifica si tienes Docker
docker --version

# Si no lo tienes, instala Docker Desktop:
# Descarga de: https://www.docker.com/products/docker-desktop

# O con Chocolatey:
choco install docker-desktop
```

### 2. AWS CLI (para interactuar con LocalStack)

```powershell
# Instalar AWS CLI
choco install awscli

# Verificar instalación
aws --version
```

### 3. Git (para clonar el proyecto)

```powershell
git --version

# Si no lo tienes:
choco install git
```

## 🚀 Inicio Rápido

### 1. Levantar los servicios

```powershell
# Navega al directorio del proyecto
cd C:\Users\eduar\Documents\java\base

# Inicia todos los servicios
docker-compose up -d

# Ver los logs
docker-compose logs -f

# Ver solo logs de LocalStack
docker-compose logs -f localstack

# Ver solo logs de la API
docker-compose logs -f app
```

### 2. Verificar que todo está corriendo

```powershell
# Ver contenedores activos
docker-compose ps

# Deberías ver algo como:
# NAME          STATUS    PORTS
# localstack    Up        0.0.0.0:4566->4566/tcp
# base-api      Up        0.0.0.0:8080->8080/tcp

# Probar LocalStack
curl http://localhost:4566/_localstack/health

# Probar API
curl http://localhost:8080/api/v1/health

# Abrir Swagger UI en navegador
Start-Process http://localhost:8080/api/v1/swagger-ui/index.html
```

## 🔧 Configurar AWS CLI para LocalStack

### Método 1: Perfil dedicado (Recomendado)

```powershell
# Crear perfil para LocalStack
aws configure --profile localstack

# Ingresa estos valores:
# AWS Access Key ID: test
# AWS Secret Access Key: test
# Default region name: us-east-1
# Default output format: json

# Verificar configuración
aws configure list --profile localstack
```

### Método 2: Variables de entorno

```powershell
# PowerShell
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = "us-east-1"
```

### Método 3: awslocal (wrapper simplificado)

```powershell
# Instalar awslocal
pip install awscli-local

# Usar awslocal (configura endpoint automáticamente)
awslocal s3 ls
awslocal dynamodb list-tables
```

## 📦 Ejemplos de Uso de Servicios AWS

### Amazon S3 (Almacenamiento de objetos)

```powershell
# Crear un bucket
aws --endpoint-url=http://localhost:4566 --profile localstack s3 mb s3://mi-bucket-local

# Listar buckets
aws --endpoint-url=http://localhost:4566 --profile localstack s3 ls

# Crear un archivo de prueba
echo "Hola LocalStack!" > test.txt

# Subir archivo al bucket
aws --endpoint-url=http://localhost:4566 --profile localstack s3 cp test.txt s3://mi-bucket-local/

# Listar objetos en el bucket
aws --endpoint-url=http://localhost:4566 --profile localstack s3 ls s3://mi-bucket-local/

# Descargar archivo
aws --endpoint-url=http://localhost:4566 --profile localstack s3 cp s3://mi-bucket-local/test.txt descargado.txt

# Eliminar objeto
aws --endpoint-url=http://localhost:4566 --profile localstack s3 rm s3://mi-bucket-local/test.txt

# Eliminar bucket
aws --endpoint-url=http://localhost:4566 --profile localstack s3 rb s3://mi-bucket-local
```

### DynamoDB (Base de datos NoSQL)

```powershell
# Crear tabla
aws --endpoint-url=http://localhost:4566 --profile localstack dynamodb create-table `
    --table-name Users `
    --attribute-definitions AttributeName=id,AttributeType=S AttributeName=email,AttributeType=S `
    --key-schema AttributeName=id,KeyType=HASH `
    --global-secondary-indexes "IndexName=EmailIndex,KeySchema=[{AttributeName=email,KeyType=HASH}],Projection={ProjectionType=ALL},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}" `
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Listar tablas
aws --endpoint-url=http://localhost:4566 --profile localstack dynamodb list-tables

# Insertar item
aws --endpoint-url=http://localhost:4566 --profile localstack dynamodb put-item `
    --table-name Users `
    --item '{"id":{"S":"1"},"email":{"S":"user@example.com"},"name":{"S":"John Doe"}}'

# Obtener item
aws --endpoint-url=http://localhost:4566 --profile localstack dynamodb get-item `
    --table-name Users `
    --key '{"id":{"S":"1"}}'

# Escanear tabla
aws --endpoint-url=http://localhost:4566 --profile localstack dynamodb scan --table-name Users

# Eliminar tabla
aws --endpoint-url=http://localhost:4566 --profile localstack dynamodb delete-table --table-name Users
```

### SQS (Colas de mensajes)

```powershell
# Crear cola
aws --endpoint-url=http://localhost:4566 --profile localstack sqs create-queue --queue-name mi-cola

# Listar colas
aws --endpoint-url=http://localhost:4566 --profile localstack sqs list-queues

# Obtener URL de la cola
$QUEUE_URL = "http://localhost:4566/000000000000/mi-cola"

# Enviar mensaje
aws --endpoint-url=http://localhost:4566 --profile localstack sqs send-message `
    --queue-url $QUEUE_URL `
    --message-body "Este es un mensaje de prueba"

# Recibir mensajes
aws --endpoint-url=http://localhost:4566 --profile localstack sqs receive-message `
    --queue-url $QUEUE_URL `
    --max-number-of-messages 10

# Purgar cola (eliminar todos los mensajes)
aws --endpoint-url=http://localhost:4566 --profile localstack sqs purge-queue --queue-url $QUEUE_URL

# Eliminar cola
aws --endpoint-url=http://localhost:4566 --profile localstack sqs delete-queue --queue-url $QUEUE_URL
```

### SNS (Notificaciones)

```powershell
# Crear tópico
aws --endpoint-url=http://localhost:4566 --profile localstack sns create-topic --name mi-topico

# Listar tópicos
aws --endpoint-url=http://localhost:4566 --profile localstack sns list-topics

# Suscribirse al tópico (email)
$TOPIC_ARN = "arn:aws:sns:us-east-1:000000000000:mi-topico"
aws --endpoint-url=http://localhost:4566 --profile localstack sns subscribe `
    --topic-arn $TOPIC_ARN `
    --protocol email `
    --notification-endpoint test@example.com

# Publicar mensaje
aws --endpoint-url=http://localhost:4566 --profile localstack sns publish `
    --topic-arn $TOPIC_ARN `
    --message "Mensaje de prueba desde LocalStack"

# Eliminar tópico
aws --endpoint-url=http://localhost:4566 --profile localstack sns delete-topic --topic-arn $TOPIC_ARN
```

### Secrets Manager (Gestión de secretos)

```powershell
# Crear secreto
aws --endpoint-url=http://localhost:4566 --profile localstack secretsmanager create-secret `
    --name mi-secreto `
    --secret-string '{"username":"admin","password":"supersecret123"}'

# Listar secretos
aws --endpoint-url=http://localhost:4566 --profile localstack secretsmanager list-secrets

# Obtener valor del secreto
aws --endpoint-url=http://localhost:4566 --profile localstack secretsmanager get-secret-value --secret-id mi-secreto

# Actualizar secreto
aws --endpoint-url=http://localhost:4566 --profile localstack secretsmanager update-secret `
    --secret-id mi-secreto `
    --secret-string '{"username":"admin","password":"nuevaPassword456"}'

# Eliminar secreto
aws --endpoint-url=http://localhost:4566 --profile localstack secretsmanager delete-secret `
    --secret-id mi-secreto `
    --force-delete-without-recovery
```

## 🔌 Integrar LocalStack con Spring Boot

### 1. Agregar dependencias AWS SDK

Cuando quieras usar servicios AWS en tu aplicación, sigue la guía en: [AWS_INTEGRATION.md](AWS_INTEGRATION.md)

### 2. Configuración ya incluida

El proyecto ya tiene configurado el perfil `local` en `application-local.yml`:

```yaml
spring:
  config:
    activate:
      on-profile: local

# AWS Configuration apuntando a LocalStack
aws:
  region: us-east-1
  endpoint: http://localstack:4566
```

### 3. Ejemplo de uso en tu código

```java
// Ejemplo: Servicio para subir archivos a S3 local
@Service
@RequiredArgsConstructor
@Slf4j
public class S3Service {
    
    private final S3Client s3Client;
    
    public void uploadFile(String bucketName, String key, byte[] content) {
        try {
            s3Client.putObject(
                PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(key)
                    .build(),
                RequestBody.fromBytes(content)
            );
            log.info("Archivo subido: {}/{}", bucketName, key);
        } catch (S3Exception e) {
            log.error("Error al subir archivo: {}", e.getMessage());
            throw new RuntimeException("Failed to upload file", e);
        }
    }
}
```

## 🛠️ Comandos Útiles

### Gestión de contenedores

```powershell
# Iniciar servicios
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f localstack
docker-compose logs -f app

# Reiniciar servicios
docker-compose restart

# Reiniciar solo un servicio
docker-compose restart localstack

# Detener servicios (mantiene los datos)
docker-compose stop

# Detener y eliminar contenedores (borra datos)
docker-compose down

# Detener y eliminar todo (incluye volúmenes)
docker-compose down -v

# Ver estado de los servicios
docker-compose ps

# Ejecutar comando dentro del contenedor
docker-compose exec localstack bash
docker-compose exec app bash
```

### Gestión de datos

```powershell
# Ver volúmenes de Docker
docker volume ls

# Limpiar volúmenes no usados
docker volume prune

# Backup de datos de LocalStack
docker cp localstack:/tmp/localstack ./backup-localstack

# Restaurar datos
docker cp ./backup-localstack/. localstack:/tmp/localstack
```

### Monitoreo

```powershell
# Ver uso de recursos
docker stats

# Ver logs del sistema
docker-compose logs --tail=100

# Health check de LocalStack
curl http://localhost:4566/_localstack/health | ConvertFrom-Json

# Health check de la API
curl http://localhost:8080/api/v1/health
```

## 🐛 Troubleshooting

### LocalStack no inicia

```powershell
# Ver logs detallados
docker-compose logs localstack

# Verificar puertos en uso
netstat -ano | findstr :4566

# Si el puerto está ocupado, cambiar en docker-compose.yml:
# ports:
#   - "4567:4566"  # Usa otro puerto

# Reiniciar Docker Desktop
Restart-Service docker

# Limpiar y reiniciar
docker-compose down -v
docker-compose up -d
```

### La aplicación no puede conectarse a LocalStack

```powershell
# Verificar que ambos contenedores estén en la misma red
docker network inspect base_base-network

# Verificar configuración en application-local.yml
# Debe usar: http://localstack:4566 (nombre del contenedor)
# NO usar: http://localhost:4566

# Reiniciar la aplicación
docker-compose restart app
```

### Errores de permisos en Windows

```powershell
# Ejecutar PowerShell como Administrador

# Agregar tu usuario al grupo docker-users
net localgroup docker-users "TU_USUARIO" /add

# Reiniciar sesión de Windows
```

### LocalStack responde lento

```powershell
# Asignar más recursos en Docker Desktop:
# Settings > Resources > Advanced
# - CPUs: 4
# - Memory: 4GB

# Limitar servicios en docker-compose.yml:
# environment:
#   - SERVICES=s3,dynamodb,sqs  # Solo los que necesites
```

### Datos se pierden al reiniciar

```powershell
# Asegúrate de que el volumen esté configurado en docker-compose.yml:
volumes:
  - "./localstack-data:/tmp/localstack"

# Crear carpeta si no existe
New-Item -Path "./localstack-data" -ItemType Directory -Force
```

## 📊 Monitoreo y Debugging

### Ver servicios disponibles

```powershell
# Health check detallado
curl http://localhost:4566/_localstack/health | ConvertFrom-Json | ConvertTo-Json

# Ejemplo de respuesta:
# {
#   "services": {
#     "s3": "running",
#     "dynamodb": "running",
#     "sqs": "running",
#     "sns": "running"
#   }
# }
```

### Logs estructurados

```powershell
# Logs con timestamp
docker-compose logs -f --timestamps

# Filtrar logs por nivel
docker-compose logs | Select-String "ERROR"
docker-compose logs | Select-String "WARN"
```

### Conectarse al contenedor

```powershell
# Entrar a LocalStack
docker-compose exec localstack bash

# Una vez dentro:
# Listar servicios activos
ps aux | grep localstack

# Ver configuración
env | grep LOCALSTACK

# Salir
exit
```

## 🎓 Ejemplos Prácticos

### Ejemplo 1: Pipeline de procesamiento de archivos

```powershell
# 1. Crear bucket
awslocal s3 mb s3://uploads

# 2. Crear cola SQS para notificaciones
awslocal sqs create-queue --queue-name file-processing

# 3. Subir archivo
echo "Data importante" > data.txt
awslocal s3 cp data.txt s3://uploads/

# 4. Enviar notificación a la cola
awslocal sqs send-message `
    --queue-url http://localhost:4566/000000000000/file-processing `
    --message-body '{"bucket":"uploads","key":"data.txt"}'

# 5. Procesar mensaje
awslocal sqs receive-message `
    --queue-url http://localhost:4566/000000000000/file-processing
```

### Ejemplo 2: Sistema de usuarios con DynamoDB

```powershell
# 1. Crear tabla de usuarios
awslocal dynamodb create-table `
    --table-name Users `
    --attribute-definitions AttributeName=userId,AttributeType=S `
    --key-schema AttributeName=userId,KeyType=HASH `
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# 2. Insertar usuarios
awslocal dynamodb put-item --table-name Users --item '{
    "userId": {"S": "user1"},
    "name": {"S": "Juan Pérez"},
    "email": {"S": "juan@example.com"},
    "age": {"N": "30"}
}'

awslocal dynamodb put-item --table-name Users --item '{
    "userId": {"S": "user2"},
    "name": {"S": "María García"},
    "email": {"S": "maria@example.com"},
    "age": {"N": "25"}
}'

# 3. Consultar usuario
awslocal dynamodb get-item `
    --table-name Users `
    --key '{"userId":{"S":"user1"}}'

# 4. Escanear todos los usuarios
awslocal dynamodb scan --table-name Users
```

### Ejemplo 3: Pub/Sub con SNS + SQS

```powershell
# 1. Crear tópico SNS
awslocal sns create-topic --name notifications

# 2. Crear cola SQS
awslocal sqs create-queue --queue-name notification-queue

# 3. Suscribir la cola al tópico
$topicArn = "arn:aws:sns:us-east-1:000000000000:notifications"
$queueArn = "arn:aws:sqs:us-east-1:000000000000:notification-queue"

awslocal sns subscribe `
    --topic-arn $topicArn `
    --protocol sqs `
    --notification-endpoint $queueArn

# 4. Publicar mensaje en el tópico
awslocal sns publish `
    --topic-arn $topicArn `
    --message "Nuevo evento importante!"

# 5. Leer mensaje de la cola
awslocal sqs receive-message `
    --queue-url http://localhost:4566/000000000000/notification-queue
```

## 🔒 Seguridad (entorno local)

LocalStack es para desarrollo local, no uses en producción. Sin embargo:

```powershell
# Limitar acceso a localhost (ya configurado en docker-compose.yml)
# ports:
#   - "127.0.0.1:4566:4566"  # Solo accesible desde tu PC

# No exponer LocalStack en red pública

# Usar credenciales fake (test/test) solo para local

# Limpiar datos sensibles antes de commits
docker-compose down -v
rm -rf ./localstack-data/*
```

## 📚 Recursos Adicionales

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [LocalStack GitHub](https://github.com/localstack/localstack)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/)
- [AWS SDK for Java](https://docs.aws.amazon.com/sdk-for-java/latest/developer-guide/)
- [Spring Cloud AWS](https://spring.io/projects/spring-cloud-aws)

## 🎯 Comandos de Referencia Rápida

```powershell
# Iniciar
docker-compose up -d

# Detener
docker-compose down

# Logs
docker-compose logs -f

# Health check
curl http://localhost:4566/_localstack/health

# S3: Crear bucket
awslocal s3 mb s3://mi-bucket

# S3: Listar buckets
awslocal s3 ls

# DynamoDB: Listar tablas
awslocal dynamodb list-tables

# SQS: Listar colas
awslocal sqs list-queues

# SNS: Listar tópicos
awslocal sns list-topics

# Secrets: Listar secretos
awslocal secretsmanager list-secrets
```

## 🎉 Conclusión

Con LocalStack tienes un entorno AWS completo en tu máquina local:

- ✅ **$0 de costo** - nada de facturación AWS
- ✅ **Desarrollo rápido** - sin latencia de red
- ✅ **Privacidad total** - datos no salen de tu PC
- ✅ **Experimentación segura** - borra y recrea cuando quieras
- ✅ **Aprende AWS** - sin miedo a romper algo o generar costos

**¡Empieza a desarrollar ahora mismo!**

```powershell
docker-compose up -d
curl http://localhost:8080/api/v1/health
```

---

**Siguiente paso:** Cuando estés listo para integrar servicios AWS en tu aplicación Spring Boot, consulta: [AWS_INTEGRATION.md](AWS_INTEGRATION.md)

