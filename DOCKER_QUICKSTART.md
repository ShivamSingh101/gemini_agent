# Docker Quick Start Guide

Get Gemini Live Bot running in 3 minutes!

## Prerequisites

- Docker Desktop installed
- Google Gemini API key

## Steps

### 1. Setup Environment (30 seconds)

```bash
# Copy environment template
cp .env.docker .env

# Edit and add your API key
# Windows: notepad .env
# Linux/Mac: nano .env
```

Add your API key:
```env
GEMINI_API_KEY=AIzaSy...your_actual_key_here
```

### 2. Deploy (2 minutes)

**Windows:**
```cmd
deploy.bat up
```

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh up
```

**Manual:**
```bash
docker-compose up -d --build
```

### 3. Verify (10 seconds)

```bash
# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 4. Access

Bot is now running at: **http://localhost:7860**

## Common Commands

```bash
# Start
deploy.sh up

# Stop
deploy.sh down

# Restart
deploy.sh restart

# View logs
deploy.sh logs

# Check status
deploy.sh status
```

## Troubleshooting

### Port Already in Use

Change port in `docker-compose.yml`:
```yaml
ports:
  - "8080:7860"  # Change 7860 to 8080
```

### Container Won't Start

```bash
# View logs
docker-compose logs

# Rebuild
docker-compose down
docker-compose up -d --build
```

### API Key Issues

```bash
# Verify key is set
docker-compose exec gemini-live-bot env | grep GEMINI
```

## Next Steps

- See [README_DEPLOY.md](./README_DEPLOY.md) for production deployment
- See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for detailed troubleshooting

## That's It!

Your Gemini Live Bot is now running in Docker! 🎉
