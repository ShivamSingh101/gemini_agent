@echo off
REM Quick start script for Gemini Live Bot (Windows)

echo 🚀 Starting Gemini Live WebRTC Bot...
echo.

REM Check if .env exists
if not exist .env (
    echo ⚠️  Warning: .env file not found
    echo Creating .env from .env.example...
    copy .env.example .env
    echo.
    echo ❌ Please edit .env and add your GEMINI_API_KEY
    echo    Get your key from: https://aistudio.google.com/app/apikey
    exit /b 1
)

REM Check if venv exists
if not exist venv (
    echo 📦 Creating virtual environment...
    python -m venv venv
    echo ✅ Virtual environment created
    echo.
)

REM Activate venv
echo 🔧 Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo 📥 Installing dependencies...
pip install -q -r requirements.txt
echo ✅ Dependencies installed
echo.

REM Run the bot
echo 🎙️  Starting bot...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
python gemini_live.py
