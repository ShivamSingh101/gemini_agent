@echo off
REM Deployment script for Gemini Live Bot (Windows)

echo 🚀 Gemini Live Bot - Docker Deployment
echo ======================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed
    echo    Please install Docker Desktop: https://docs.docker.com/desktop/install/windows-install/
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo ❌ Docker Compose is not installed
        exit /b 1
    )
)

REM Check if .env file exists
if not exist .env (
    echo ⚠️  .env file not found
    echo    Creating from template...
    copy .env.docker .env
    echo.
    echo ❌ Please edit .env and add your GEMINI_API_KEY
    echo    Get your key from: https://aistudio.google.com/app/apikey
    echo.
    echo    Then run this script again.
    exit /b 1
)

echo ✅ Environment configured
echo.

REM Parse command
set COMMAND=%1
if "%COMMAND%"=="" set COMMAND=up

if "%COMMAND%"=="up" goto :up
if "%COMMAND%"=="start" goto :up
if "%COMMAND%"=="down" goto :down
if "%COMMAND%"=="stop" goto :down
if "%COMMAND%"=="restart" goto :restart
if "%COMMAND%"=="logs" goto :logs
if "%COMMAND%"=="build" goto :build
if "%COMMAND%"=="clean" goto :clean
if "%COMMAND%"=="status" goto :status
goto :usage

:up
echo 📦 Building and starting containers...
docker-compose up -d --build
echo.
echo ✅ Deployment successful!
echo.
echo 📊 Container Status:
docker-compose ps
echo.
echo 📝 View logs:
echo    docker-compose logs -f
echo.
echo 🔗 Bot URL: http://localhost:7860
goto :end

:down
echo 🛑 Stopping containers...
docker-compose down
echo ✅ Containers stopped
goto :end

:restart
echo 🔄 Restarting containers...
docker-compose restart
echo ✅ Containers restarted
goto :end

:logs
echo 📝 Showing logs (Ctrl+C to exit)...
docker-compose logs -f
goto :end

:build
echo 🏗️  Building image...
docker-compose build
echo ✅ Build complete
goto :end

:clean
echo 🧹 Cleaning up...
docker-compose down -v
docker system prune -f
echo ✅ Cleanup complete
goto :end

:status
echo 📊 Container Status:
docker-compose ps
echo.
echo 💾 Resource Usage:
docker stats --no-stream gemini-live-bot 2>nul
goto :end

:usage
echo Usage: %0 {up^|down^|restart^|logs^|build^|clean^|status}
echo.
echo Commands:
echo   up       - Build and start containers
echo   down     - Stop and remove containers
echo   restart  - Restart containers
echo   logs     - View container logs
echo   build    - Build Docker image
echo   clean    - Remove containers and clean up
echo   status   - Show container status
exit /b 1

:end
