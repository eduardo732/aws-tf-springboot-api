# Terraform Infrastructure for Spring Boot API with LocalStack

Este directorio contiene la infraestructura como código (IaC) usando Terraform para desplegar la aplicación Spring Boot con LocalStack en AWS EC2.

## 📋 Prerequisitos

1. **Terraform instalado** (v1.0+)
   ```bash
   # Windows con Chocolatey
   choco install terraform
   
   # O descarga de: https://www.terraform.io/downloads
   ```

2. **AWS CLI configurado**
   ```bash
   aws configure
   # Ingresa AWS Access Key ID, Secret Access Key, Region
   ```

3. **Par de claves SSH**
   ```bash
   # Genera un nuevo par de claves
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-springboot-key
   ```

## 🚀 Deployment

### 1. Configurar variables

```bash
# Copia el archivo de ejemplo
cp terraform.tfvars.example terraform.tfvars

# Edita terraform.tfvars con tus valores
# IMPORTANTE: Cambia allowed_ssh_cidrs a tu IP pública
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Validar configuración

```bash
terraform validate
```

### 4. Revisar el plan de ejecución

```bash
terraform plan
```

### 5. Aplicar la infraestructura

```bash
terraform apply
# Confirma con 'yes'
```

### 6. Obtener outputs

```bash
terraform output
```

## 📊 Outputs Disponibles

- **instance_id**: ID de la instancia EC2
- **instance_public_ip**: IP pública de la instancia
- **api_url**: URL de la API Spring Boot
- **swagger_ui_url**: URL de Swagger UI
- **localstack_url**: URL de LocalStack
- **ssh_command**: Comando para conectarse por SSH

## 🔧 Post-Deployment

### Verificar el estado de los servicios

```bash
# Espera ~3-5 minutos después del apply para que los servicios inicien

# Verificar API
curl http://<IP_PUBLICA>:8080/api/v1/health

# Verificar LocalStack
curl http://<IP_PUBLICA>:4566/_localstack/health

# Ver Swagger UI en navegador
http://<IP_PUBLICA>:8080/api/v1/swagger-ui/index.html
```

### Conectarse por SSH

```bash
# Usa el comando del output
ssh -i ~/.ssh/aws-springboot-key ec2-user@<IP_PUBLICA>

# Una vez conectado, revisa los logs
cd app
docker-compose logs -f

# O ejecuta el script de health check
./health-check.sh
```

## 🧪 Probar LocalStack

```bash
# Desde el EC2 (después de SSH)
awslocal s3 mb s3://test-bucket
awslocal s3 ls

# Desde tu máquina local
aws --endpoint-url=http://<IP_PUBLICA>:4566 s3 mb s3://test-bucket
aws --endpoint-url=http://<IP_PUBLICA>:4566 s3 ls
```

## 📁 Estructura de archivos

```
terraform/
├── main.tf                    # Recursos principales (EC2, EIP, Key Pair)
├── security.tf                # Security Groups
├── variables.tf               # Definición de variables
├── outputs.tf                 # Outputs después del despliegue
├── userdata.sh                # Script de inicialización EC2
├── terraform.tfvars.example   # Ejemplo de configuración
├── .gitignore                 # Archivos a ignorar en Git
└── README.md                  # Esta documentación
```

## 🔐 Seguridad

### Recomendaciones importantes:

1. **Restringir acceso SSH:**
   ```hcl
   allowed_ssh_cidrs = ["TU_IP_PUBLICA/32"]
   ```

2. **No exponer LocalStack públicamente en producción:**
   ```hcl
   allowed_localstack_cidrs = ["TU_IP_PUBLICA/32"]
   ```

3. **Usar AWS Secrets Manager para credenciales sensibles**

4. **Habilitar CloudWatch Logs**

5. **Configurar backups automáticos**

## 💰 Costos Estimados

- **t3.medium**: ~$0.0416/hora (~$30/mes)
- **EBS gp3 30GB**: ~$2.40/mes
- **Elastic IP**: Gratis mientras esté asociada a instancia corriendo
- **Data Transfer**: Variable según uso

**Total aproximado**: ~$35-40/mes

## 🧹 Limpieza

Para destruir toda la infraestructura:

```bash
terraform destroy
# Confirma con 'yes'
```

## 🔍 Troubleshooting

### La aplicación no inicia

```bash
# Conéctate por SSH
ssh -i ~/.ssh/aws-springboot-key ec2-user@<IP>

# Revisa el log de user-data
sudo cat /var/log/user-data.log

# Revisa los logs de Docker
cd app
docker-compose logs
```

### Error de permisos SSH

```bash
# Asegúrate de que la clave privada tenga los permisos correctos
chmod 400 ~/.ssh/aws-springboot-key
```

### Timeout al aplicar Terraform

- Verifica tu conexión a internet
- Verifica las credenciales de AWS CLI
- Revisa los límites de tu cuenta AWS

## 📚 Recursos Adicionales

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [LocalStack Documentation](https://docs.localstack.cloud/)
- [AWS EC2 Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-best-practices.html)

## 🤝 Contribuciones

Para mejorar esta infraestructura, considera:

1. Implementar Auto Scaling
2. Agregar Application Load Balancer
3. Configurar CloudWatch Alarms
4. Implementar backups automáticos
5. Agregar monitoreo con Prometheus/Grafana

