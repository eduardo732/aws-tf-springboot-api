output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address"
  value       = aws_eip.app_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name"
  value       = aws_instance.app_server.public_dns
}

output "api_url" {
  description = "Spring Boot API URL"
  value       = "http://${aws_eip.app_eip.public_ip}:8080/api/v1"
}

output "swagger_ui_url" {
  description = "Swagger UI URL"
  value       = "http://${aws_eip.app_eip.public_ip}:8080/api/v1/swagger-ui/index.html"
}

output "localstack_url" {
  description = "LocalStack endpoint URL"
  value       = "http://${aws_eip.app_eip.public_ip}:4566"
}

output "localstack_health_check" {
  description = "LocalStack health check URL"
  value       = "http://${aws_eip.app_eip.public_ip}:4566/_localstack/health"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${replace(var.public_key_path, ".pub", "")} ec2-user@${aws_eip.app_eip.public_ip}"
}

output "docker_logs_command" {
  description = "Command to view Docker logs after SSH"
  value       = "cd app && docker-compose logs -f"
}

