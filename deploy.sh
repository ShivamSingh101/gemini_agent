#!/bin/bash
# Deployment script for Gemini Live Bot

set -e

echo "🚀 Gemini Live Bot - Docker Deployment"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "   Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo "   Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found${NC}"
    echo "   Creating from template..."
    cp .env.docker .env
    echo ""
    echo -e "${RED}❌ Please edit .env and add your GEMINI_API_KEY${NC}"
    echo "   Get your key from: https://aistudio.google.com/app/apikey"
    echo ""
    echo "   Then run this script again."
    exit 1
fi

# Check if GEMINI_API_KEY is set
source .env
if [ -z "$GEMINI_API_KEY" ] || [ "$GEMINI_API_KEY" = "your_gemini_api_key_here" ]; then
    echo -e "${RED}❌ GEMINI_API_KEY not set in .env${NC}"
    echo "   Please edit .env and add your API key"
    exit 1
fi

echo -e "${GREEN}✅ Environment configured${NC}"
echo ""

# Parse command line arguments
COMMAND=${1:-up}

case $COMMAND in
    up|start)
        echo "📦 Building and starting containers..."
        docker-compose up -d --build
        echo ""
        echo -e "${GREEN}✅ Deployment successful!${NC}"
        echo ""
        echo "📊 Container Status:"
        docker-compose ps
        echo ""
        echo "📝 View logs:"
        echo "   docker-compose logs -f"
        echo ""
        echo "🔗 Bot URL: http://localhost:7860"
        ;;

    down|stop)
        echo "🛑 Stopping containers..."
        docker-compose down
        echo -e "${GREEN}✅ Containers stopped${NC}"
        ;;

    restart)
        echo "🔄 Restarting containers..."
        docker-compose restart
        echo -e "${GREEN}✅ Containers restarted${NC}"
        ;;

    logs)
        echo "📝 Showing logs (Ctrl+C to exit)..."
        docker-compose logs -f
        ;;

    build)
        echo "🏗️  Building image..."
        docker-compose build
        echo -e "${GREEN}✅ Build complete${NC}"
        ;;

    clean)
        echo "🧹 Cleaning up..."
        docker-compose down -v
        docker system prune -f
        echo -e "${GREEN}✅ Cleanup complete${NC}"
        ;;

    status)
        echo "📊 Container Status:"
        docker-compose ps
        echo ""
        echo "💾 Resource Usage:"
        docker stats --no-stream gemini-live-bot 2>/dev/null || echo "Container not running"
        ;;

    shell)
        echo "🐚 Opening shell in container..."
        docker-compose exec gemini-live-bot /bin/bash
        ;;

    *)
        echo "Usage: $0 {up|down|restart|logs|build|clean|status|shell}"
        echo ""
        echo "Commands:"
        echo "  up       - Build and start containers"
        echo "  down     - Stop and remove containers"
        echo "  restart  - Restart containers"
        echo "  logs     - View container logs"
        echo "  build    - Build Docker image"
        echo "  clean    - Remove containers and clean up"
        echo "  status   - Show container status"
        echo "  shell    - Open shell in container"
        exit 1
        ;;
esac
