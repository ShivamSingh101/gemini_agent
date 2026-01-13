#!/bin/bash
# Setup script to fix corrupted installation

echo "🔧 Fixing Gemini Live Bot Installation"
echo "=========================================="
echo ""

# Remove old venv if exists
if [ -d "venv" ]; then
    echo "🗑️  Removing old virtual environment..."
    rm -rf venv
    echo "✅ Old venv removed"
    echo ""
fi

# Create fresh venv
echo "📦 Creating fresh virtual environment..."
python3 -m venv venv
if [ $? -ne 0 ]; then
    echo "❌ Failed to create venv"
    exit 1
fi
echo "✅ Virtual environment created"
echo ""

# Activate venv
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "📥 Upgrading pip..."
python -m pip install --upgrade pip
echo ""

# Clear pip cache
echo "🧹 Clearing pip cache..."
pip cache purge
echo "✅ Cache cleared"
echo ""

# Install dependencies
echo "📥 Installing dependencies (this may take a few minutes)..."
echo "   This includes WebRTC support, OpenCV, and audio processing..."
pip install --no-cache-dir -r requirements.txt
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Installation failed"
    echo ""
    echo "💡 Troubleshooting:"
    echo "   1. Check your internet connection"
    echo "   2. Try manual install:"
    echo "      pip install 'pipecat-ai[silero,google,webrtc]'"
    echo "      pip install google-generativeai python-dotenv loguru"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "💡 Next steps:"
echo "   1. Edit .env file and add your GEMINI_API_KEY"
echo "      (Copy from .env.example if needed)"
echo ""
echo "   2. Run the bot:"
echo "      python gemini_live.py"
echo ""
