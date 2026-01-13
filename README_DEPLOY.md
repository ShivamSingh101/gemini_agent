# Gemini Live Bot - Docker Deployment Guide

Complete guide for deploying Gemini Live Bot using Docker.

## Prerequisites

### Required
- Docker (20.10+)
- Docker Compose (2.0+)
- Google Gemini API Key

### System Requirements
- **CPU**: 2+ cores recommended
- **RAM**: 2GB minimum, 4GB recommended
- **Disk**: 5GB free space
- **Network**: Stable internet connection

## Quick Start

### 1. Get API Key

Get your Gemini API key from: https://aistudio.google.com/app/apikey

### 2. Configure Environment

```bash
# Copy environment template
cp .env.docker .env

# Edit .env and add your API key
nano .env  # or use any text editor
```

Set your `GEMINI_API_KEY` in `.env`:
```env
GEMINI_API_KEY=AIzaSy...your_key_here
```

### 3. Deploy

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh up
```

**Windows:**
```cmd
deploy.bat up
```

**Or manually:**
```bash
docker-compose up -d --build
```

### 4. Verify

Check container status:
```bash
docker-compose ps
```

View logs:
```bash
docker-compose logs -f
```

### 5. Access

Bot is now running at: **http://localhost:7860**

## Deployment Commands

### Start/Stop

```bash
# Start bot
./deploy.sh up

# Stop bot
./deploy.sh down

# Restart bot
./deploy.sh restart
```

### Logs

```bash
# View logs (live)
./deploy.sh logs

# View last 100 lines
docker-compose logs --tail=100

# View specific service logs
docker-compose logs gemini-live-bot
```

### Status

```bash
# Check status
./deploy.sh status

# Check health
docker-compose ps
```

### Build

```bash
# Rebuild image
./deploy.sh build

# Build without cache
docker-compose build --no-cache
```

### Clean Up

```bash
# Remove containers and volumes
./deploy.sh clean

# Remove everything including images
docker-compose down -v --rmi all
```

## Configuration

### Environment Variables

Edit `.env` file:

```env
# Required
GEMINI_API_KEY=your_key_here

# Optional
LOG_LEVEL=INFO              # DEBUG, INFO, WARNING, ERROR
PORT=7860                   # WebRTC port
PIPELINE_IDLE_TIMEOUT=300   # Seconds before idle timeout
```

### Docker Compose

Edit `docker-compose.yml` for advanced configuration:

```yaml
services:
  gemini-live-bot:
    # Change port mapping
    ports:
      - "8080:7860"  # Change 8080 to your desired port

    # Adjust resource limits
    deploy:
      resources:
        limits:
          cpus: '4'      # Increase for more performance
          memory: 4G     # Increase for more stability
```

## Production Deployment

### 1. Use Specific Image Version

```yaml
services:
  gemini-live-bot:
    image: gemini-live-bot:1.0.0
    build:
      context: .
      dockerfile: Dockerfile
```

### 2. Enable Auto-Restart

```yaml
services:
  gemini-live-bot:
    restart: always  # Always restart on failure
```

### 3. Use External Network

```yaml
networks:
  default:
    external: true
    name: production-network
```

### 4. Add SSL/TLS

Use nginx reverse proxy:

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - gemini-live-bot
```

### 5. Monitoring

Add Prometheus metrics:

```yaml
services:
  gemini-live-bot:
    environment:
      - ENABLE_METRICS=true
    ports:
      - "9090:9090"  # Metrics port
```

## Advanced Usage

### Docker Build Arguments

```dockerfile
# Custom Python version
docker build --build-arg PYTHON_VERSION=3.11 .

# Custom port
docker build --build-arg PORT=8080 .
```

### Multi-Stage Build

For smaller images, modify `Dockerfile`:

```dockerfile
# Builder stage
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements-docker.txt .
RUN pip install --user --no-cache-dir -r requirements-docker.txt

# Runtime stage
FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY gemini_live.py .
CMD ["python", "gemini_live.py"]
```

### Docker Swarm Deployment

```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml gemini-bot

# Scale service
docker service scale gemini-bot_gemini-live-bot=3

# View services
docker stack services gemini-bot
```

### Kubernetes Deployment

Create `k8s-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gemini-live-bot
spec:
  replicas: 3
  selector:
    matchLabels:
      app: gemini-live-bot
  template:
    metadata:
      labels:
        app: gemini-live-bot
    spec:
      containers:
      - name: bot
        image: gemini-live-bot:latest
        env:
        - name: GEMINI_API_KEY
          valueFrom:
            secretKeyRef:
              name: gemini-secret
              key: api-key
        ports:
        - containerPort: 7860
---
apiVersion: v1
kind: Service
metadata:
  name: gemini-live-bot-service
spec:
  selector:
    app: gemini-live-bot
  ports:
  - protocol: TCP
    port: 80
    targetPort: 7860
  type: LoadBalancer
```

Deploy:
```bash
kubectl apply -f k8s-deployment.yaml
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs

# Check if port is in use
netstat -tuln | grep 7860  # Linux/Mac
netstat -ano | findstr :7860  # Windows

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### API Key Issues

```bash
# Verify environment variables
docker-compose exec gemini-live-bot env | grep GEMINI

# Test API key manually
docker-compose exec gemini-live-bot python -c "import os; print(os.getenv('GEMINI_API_KEY'))"
```

### Memory Issues

```bash
# Check container stats
docker stats gemini-live-bot

# Increase memory limit in docker-compose.yml
deploy:
  resources:
    limits:
      memory: 4G
```

### Network Issues

```bash
# Check network
docker network ls
docker network inspect gemini-live-bot_gemini-network

# Restart networking
docker-compose down
docker network prune -f
docker-compose up -d
```

### Permission Issues

```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Run as root (not recommended)
docker-compose exec -u root gemini-live-bot bash
```

## Monitoring

### Health Checks

```bash
# Manual health check
curl http://localhost:7860/health

# Check Docker health status
docker inspect --format='{{.State.Health.Status}}' gemini-live-bot
```

### Logs

```bash
# Real-time logs
docker-compose logs -f --tail=100

# Export logs
docker-compose logs > bot-logs.txt

# View logs with timestamp
docker-compose logs -t
```

### Resource Usage

```bash
# Current usage
docker stats gemini-live-bot --no-stream

# Continuous monitoring
docker stats gemini-live-bot
```

## Backup & Restore

### Backup Configuration

```bash
# Backup .env
cp .env .env.backup

# Export image
docker save gemini-live-bot:latest | gzip > gemini-live-bot.tar.gz
```

### Restore

```bash
# Restore .env
cp .env.backup .env

# Load image
docker load < gemini-live-bot.tar.gz
```

## Security Best Practices

### 1. Never Commit .env

Add to `.gitignore`:
```
.env
.env.local
.env.*.local
```

### 2. Use Secrets Management

**Docker Swarm:**
```bash
echo "your_api_key" | docker secret create gemini_api_key -
```

**Kubernetes:**
```bash
kubectl create secret generic gemini-secret --from-literal=api-key=your_key
```

### 3. Run as Non-Root User

Already configured in Dockerfile:
```dockerfile
USER appuser
```

### 4. Limit Resources

Prevent DoS by limiting resources in `docker-compose.yml`.

### 5. Regular Updates

```bash
# Update base images
docker-compose pull
docker-compose up -d --build
```

## Performance Optimization

### 1. Use BuildKit

```bash
DOCKER_BUILDKIT=1 docker-compose build
```

### 2. Layer Caching

Dependencies are installed before code copy for better caching.

### 3. Multi-Core Usage

```yaml
deploy:
  resources:
    limits:
      cpus: '4'  # Use more cores
```

### 4. Memory Tuning

```yaml
deploy:
  resources:
    limits:
      memory: 4G
    reservations:
      memory: 2G
```

## CI/CD Integration

### GitHub Actions

`.github/workflows/deploy.yml`:
```yaml
name: Deploy Gemini Live Bot

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Build Docker image
        run: docker-compose build

      - name: Deploy
        run: docker-compose up -d
```

### GitLab CI

`.gitlab-ci.yml`:
```yaml
deploy:
  stage: deploy
  script:
    - docker-compose build
    - docker-compose up -d
  only:
    - main
```

## Support

For issues:
1. Check logs: `docker-compose logs`
2. Verify configuration: `docker-compose config`
3. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
4. Report issues with logs and system info

## License

BSD 2-Clause License
