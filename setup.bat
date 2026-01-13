@echo off
REM Setup script to fix corrupted installation

echo 🔧 Fixing Gemini Live Bot Installation
echo ==========================================
echo.

REM Remove old venv if exists
if exist venv (
    echo 🗑️  Removing old virtual environment...
    rmdir /s /q venv
    echo ✅ Old venv removed
    echo.
)

REM Create fresh venv
echo 📦 Creating fresh virtual environment...
python -m venv venv
if errorlevel 1 (
    echo ❌ Failed to create venv
    exit /b 1
)
echo ✅ Virtual environment created
echo.

REM Activate venv
echo 🔧 Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo 📥 Upgrading pip...
python -m pip install --upgrade pip
echo.

REM Clear pip cache
echo 🧹 Clearing pip cache...
pip cache purge
echo ✅ Cache cleared
echo.

REM Install dependencies
echo 📥 Installing dependencies (this may take a few minutes)...
echo    This includes WebRTC support, OpenCV, and audio processing...
pip install --no-cache-dir -r requirements.txt
if errorlevel 1 (
    echo.
    echo ❌ Installation failed
    echo.
    echo 💡 Troubleshooting:
    echo    1. Check your internet connection
    echo    2. Try running as Administrator
    echo    3. Disable antivirus temporarily
    echo    4. Try manual install:
    echo       pip install "pipecat-ai[silero,google,webrtc]"
    echo       pip install google-generativeai python-dotenv loguru
    exit /b 1
)

echo.
echo ==========================================
echo ✅ Setup Complete!
echo ==========================================
echo.
echo 💡 Next steps:
echo    1. Edit .env file and add your GEMINI_API_KEY
echo       (Copy from .env.example if needed)
echo.
echo    2. Run the bot:
echo       python gemini_live.py
echo.
