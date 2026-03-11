# AWS Configuration Helper

Este archivo te ayuda a configurar AWS CLI y preparar el entorno para Terraform.

## 1. Crear usuario IAM en AWS Console

### Pasos:

1. Ve a AWS Console → IAM → Users
2. Click "Add users"
3. Nombre de usuario: `terraform-deployer`
4. Selecciona "Programmatic access"
5. Permisos: Adjunta políticas:
   - `AmazonEC2FullAccess`
   - `AmazonVPCFullAccess`
   O crea una política personalizada con permisos mínimos (recomendado)

### Política IAM mínima recomendada:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "cloudwatch:*",
        "autoscaling:*"
      ],
      "Resource": "*"
    }
  ]
}
```

6. Descarga las credenciales (Access Key ID y Secret Access Key)

## 2. Configurar AWS CLI

```powershell
# Instalar AWS CLI (si no lo tienes)
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# O con Chocolatey
choco install awscli

# Configurar credenciales
aws configure

# Te pedirá:
# AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Default region name [None]: us-east-1
# Default output format [None]: json
```

## 3. Verificar configuración

```powershell
# Ver configuración actual
aws configure list

# Probar conexión
aws sts get-caller-identity

# Listar regiones disponibles
aws ec2 describe-regions --output table
```

## 4. Configuración alternativa con perfiles

Si trabajas con múltiples cuentas AWS:

```powershell
# Configurar con perfil específico
aws configure --profile terraform-dev

# Usar el perfil
$env:AWS_PROFILE = "terraform-dev"
terraform apply

# O especificar en el comando
terraform apply -var="aws_profile=terraform-dev"
```

## 5. Variables de entorno (alternativa)

En lugar de `aws configure`, puedes usar variables de entorno:

```powershell
# PowerShell
$env:AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
$env:AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
$env:AWS_DEFAULT_REGION = "us-east-1"
```

## 6. Generar par de claves SSH

```powershell
# Generar nueva clave SSH
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\aws-springboot-key

# La clave pública estará en:
# C:\Users\TU_USUARIO\.ssh\aws-springboot-key.pub

# Usa esta ruta en terraform.tfvars:
# public_key_path = "~/.ssh/aws-springboot-key.pub"
```

## 7. Obtener tu IP pública

Para configurar `allowed_ssh_cidrs` y `allowed_localstack_cidrs`:

```powershell
# Obtener tu IP pública
(Invoke-WebRequest -Uri "https://ifconfig.me/ip").Content

# O usando otro servicio
(Invoke-WebRequest -Uri "https://api.ipify.org").Content

# Usa esta IP en terraform.tfvars:
# allowed_ssh_cidrs = ["TU_IP/32"]
```

## 8. Regiones AWS disponibles

Regiones comunes y sus códigos:

| Región | Código | Ubicación |
|--------|--------|-----------|
| US East (N. Virginia) | us-east-1 | EE.UU. Este |
| US East (Ohio) | us-east-2 | EE.UU. Este |
| US West (Oregon) | us-west-2 | EE.UU. Oeste |
| South America (São Paulo) | sa-east-1 | Brasil |
| Europe (Ireland) | eu-west-1 | Irlanda |
| Asia Pacific (Singapore) | ap-southeast-1 | Singapur |

## 9. Costos estimados por región

Precios aproximados para t3.medium (actualizado 2026):

- **us-east-1**: $0.0416/hora (~$30/mes)
- **us-west-2**: $0.0416/hora (~$30/mes)
- **sa-east-1**: $0.0624/hora (~$45/mes)
- **eu-west-1**: $0.0464/hora (~$34/mes)

**Recomendación**: Usa `us-east-1` para costos más bajos.

## 10. Checklist antes de desplegar

- [ ] AWS CLI instalado y configurado
- [ ] Credenciales IAM con permisos necesarios
- [ ] Par de claves SSH generado
- [ ] Región seleccionada
- [ ] IP pública obtenida para seguridad
- [ ] terraform.tfvars configurado
- [ ] Terraform instalado (v1.0+)

## 11. Comandos útiles AWS CLI

```powershell
# Ver instancias EC2
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key=='Name'].Value|[0]]" --output table

# Ver Security Groups
aws ec2 describe-security-groups --output table

# Ver Key Pairs
aws ec2 describe-key-pairs --output table

# Ver Elastic IPs
aws ec2 describe-addresses --output table

# Terminar una instancia
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Ver costos del mes actual
aws ce get-cost-and-usage --time-period Start=2026-03-01,End=2026-03-31 --granularity MONTHLY --metrics UnblendedCost
```

## 12. Solución de problemas

### Error: "Unable to locate credentials"

```powershell
# Verifica que las credenciales estén configuradas
aws configure list

# Reconfigura si es necesario
aws configure
```

### Error: "UnauthorizedOperation"

- Verifica que tu usuario IAM tenga los permisos necesarios
- Revisa las políticas adjuntas al usuario

### Error: "InvalidKeyPair.NotFound"

- Asegúrate de que la ruta en `terraform.tfvars` apunte a la clave pública (.pub)
- Verifica que el archivo existe

### Error: "RequestLimitExceeded"

- AWS tiene límites de API calls
- Espera unos minutos y reintenta
- Considera usar `terraform apply -parallelism=1` para reducir llamadas concurrentes

## 13. Buenas prácticas de seguridad

1. **No commitees credenciales**: Nunca subas `terraform.tfvars` o archivos con credenciales a Git
2. **Usa IAM roles**: En lugar de Access Keys, usa IAM roles cuando sea posible
3. **Rota credenciales**: Cambia tus Access Keys periódicamente
4. **MFA**: Habilita autenticación multifactor en tu cuenta AWS
5. **Least privilege**: Da solo los permisos mínimos necesarios
6. **Encriptación**: Usa KMS para datos sensibles
7. **CloudTrail**: Habilita logs de auditoría

## 14. Recursos adicionales

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Pricing Calculator](https://calculator.aws/)

