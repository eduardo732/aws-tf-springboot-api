variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "springboot-api"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "git_repository" {
  description = "Git repository URL"
  type        = string
  default     = "https://github.com/eduardo732/aws-tf-springboot-api.git"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # CAMBIAR EN PRODUCCIÓN a tu IP específica
}

variable "allowed_localstack_cidrs" {
  description = "CIDR blocks allowed for LocalStack access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Solo para desarrollo/testing
}

