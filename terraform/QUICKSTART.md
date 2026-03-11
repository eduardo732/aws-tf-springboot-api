# Quick Start Guide

## Pasos rápidos para desplegar

### 1. Preparación (solo primera vez)

```powershell
# Instalar Terraform (si no lo tienes)
choco install terraform

# Verificar instalación
terraform --version

# Configurar AWS CLI (si no lo has hecho)
aws configure
# Ingresa: Access Key, Secret Key, Region (us-east-1), Output format (json)

# Generar par de claves SSH
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\aws-springboot-key
```

### 2. Configurar variables

```powershell
cd terraform

# Copiar archivo de ejemplo
Copy-Item terraform.tfvars.example terraform.tfvars

# Editar terraform.tfvars (usa notepad o tu editor favorito)
notepad terraform.tfvars
```

**Valores mínimos a configurar en `terraform.tfvars`:**

```hcl
public_key_path = "~/.ssh/aws-springboot-key.pub"
git_repository = "https://github.com/TU_USUARIO/TU_REPO.git"

# Opcional: tu IP pública para mayor seguridad
# Obtén tu IP: curl ifconfig.me
# allowed_ssh_cidrs = ["TU_IP/32"]
```

### 3. Desplegar

```powershell
# Inicializar Terraform
terraform init

# Ver qué se va a crear
terraform plan

# Aplicar cambios (confirma con 'yes')
terraform apply

# Espera ~5 minutos
```

### 4. Verificar

```powershell
# Ver outputs
terraform output

# Obtener la IP pública
$IP = terraform output -raw instance_public_ip

# Probar API (espera 3-5 minutos después del apply)
curl "http://${IP}:8080/api/v1/health"

# Probar LocalStack
curl "http://${IP}:4566/_localstack/health"

# Abrir Swagger UI en navegador
Start-Process "http://${IP}:8080/api/v1/swagger-ui/index.html"
```

### 5. Conectar por SSH

```powershell
# Obtener comando SSH
terraform output -raw ssh_command

# O ejecutar directamente
ssh -i $env:USERPROFILE\.ssh\aws-springboot-key ec2-user@$IP

# Una vez dentro, ver logs
cd app
docker-compose logs -f
```

### 6. Limpiar (cuando termines)

```powershell
# Destruir toda la infraestructura
terraform destroy
# Confirma con 'yes'
```

## Comandos útiles

### Ver estado actual
```powershell
terraform show
```

### Ver solo outputs
```powershell
terraform output
```

### Formatear archivos .tf
```powershell
terraform fmt
```

### Validar sintaxis
```powershell
terraform validate
```

### Refrescar estado
```powershell
terraform refresh
```

### Ver recursos creados
```powershell
terraform state list
```

## Troubleshooting rápido

### Error: InvalidKeyPair.NotFound
- Verifica que `public_key_path` en `terraform.tfvars` apunte a tu clave pública (.pub)

### Error: UnauthorizedOperation
- Verifica que tu usuario AWS tenga permisos para crear EC2, VPC, etc.

### La aplicación no responde después de 5 minutos
```powershell
# Conéctate por SSH y revisa logs
ssh -i $env:USERPROFILE\.ssh\aws-springboot-key ec2-user@$IP
sudo cat /var/log/user-data.log
cd app
docker-compose logs
```

### Cambiar región de despliegue
Edita `terraform.tfvars`:
```hcl
aws_region = "us-west-2"  # o la región que prefieras
```

## Costos

- **t3.medium**: ~$30/mes (24/7)
- **Almacenamiento**: ~$2.40/mes
- **Total**: ~$35/mes

Para reducir costos:
- Destruye la infraestructura cuando no la uses: `terraform destroy`
- Usa instancias spot (más complejo)
- Usa t3.small en lugar de t3.medium (puede ser insuficiente para LocalStack)

