#!/bin/bash
set -e

# Log everything to file
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Starting instance setup at $(date)"
echo "=========================================="

# Update system
echo ">>> Updating system packages..."
dnf update -y

# Install Docker
echo ">>> Installing Docker..."
dnf install -y docker git
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
echo ">>> Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify Docker installation
docker --version
docker-compose --version

# Install AWS CLI (útil para interactuar con LocalStack)
echo ">>> Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip
aws --version

# Install awslocal (wrapper for LocalStack)
echo ">>> Installing awslocal..."
dnf install -y python3-pip
pip3 install awscli-local

# Clone repository
echo ">>> Cloning repository from ${git_repo}..."
cd /home/ec2-user
if [ -d "app" ]; then
  rm -rf app
fi
git clone ${git_repo} app
chown -R ec2-user:ec2-user app

# Start services with Docker Compose
echo ">>> Starting Docker Compose services..."
cd app
docker-compose up -d

# Wait for services to be ready
echo ">>> Waiting for services to start (30 seconds)..."
sleep 30

# Check service status
echo ">>> Docker Compose service status:"
docker-compose ps

# Show recent logs
echo ">>> Recent logs from services:"
docker-compose logs --tail=100

# Get instance metadata
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Create a simple health check script
cat > /home/ec2-user/health-check.sh <<'EOF'
#!/bin/bash
echo "=========================================="
echo "Health Check at $(date)"
echo "=========================================="
echo ""
echo "API Health:"
curl -s http://localhost:8080/api/v1/health || echo "API not ready"
echo ""
echo ""
echo "LocalStack Health:"
curl -s http://localhost:4566/_localstack/health || echo "LocalStack not ready"
echo ""
echo ""
echo "Docker Containers:"
docker ps
echo ""
EOF

chmod +x /home/ec2-user/health-check.sh
chown ec2-user:ec2-user /home/ec2-user/health-check.sh

# Run initial health check
echo ">>> Running initial health check..."
sleep 10
/home/ec2-user/health-check.sh

echo ""
echo "=========================================="
echo "Setup completed successfully at $(date)"
echo "=========================================="
echo ""
echo "Access URLs:"
echo "  - API: http://$INSTANCE_IP:8080/api/v1"
echo "  - Swagger UI: http://$INSTANCE_IP:8080/api/v1/swagger-ui/index.html"
echo "  - LocalStack: http://$INSTANCE_IP:4566"
echo "  - LocalStack Health: http://$INSTANCE_IP:4566/_localstack/health"
echo ""
echo "Useful commands (after SSH):"
echo "  - View logs: cd app && docker-compose logs -f"
echo "  - Restart services: cd app && docker-compose restart"
echo "  - Stop services: cd app && docker-compose down"
echo "  - Check health: ./health-check.sh"
echo ""
echo "LocalStack AWS CLI examples:"
echo "  - awslocal s3 mb s3://test-bucket"
echo "  - awslocal s3 ls"
echo "  - aws --endpoint-url=http://localhost:4566 s3 ls"
echo ""

