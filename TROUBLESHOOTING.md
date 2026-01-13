# Troubleshooting Guide

Common issues and solutions for Gemini Live Bot.

## Installation Issues

### Error: "SyntaxError: source code string cannot contain null bytes"

**Symptom:**
```
SyntaxError: source code string cannot contain null bytes
```

**Cause:**
Corrupted FastAPI or dependency installation (null bytes in files).

**Solution:**

**Option 1: Use Setup Script (Recommended)**
```bash
# Windows
setup.bat

# Linux/Mac
./setup.sh
```

**Option 2: Manual Fix**
```bash
# 1. Remove corrupted venv
rm -rf venv          # Linux/Mac
rmdir /s /q venv     # Windows

# 2. Clear pip cache
pip cache purge

# 3. Create fresh venv
python -m venv venv

# 4. Activate venv
source venv/bin/activate      # Linux/Mac
venv\Scripts\activate.bat     # Windows

# 5. Upgrade pip
python -m pip install --upgrade pip

# 6. Install dependencies (no cache)
pip install --no-cache-dir -r requirements.txt

# 7. Run bot
python gemini_live.py
```

---

### Error: "GEMINI_API_KEY not found"

**Symptom:**
```
KeyError: 'GEMINI_API_KEY'
```

**Solution:**
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your key:
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```

3. Get your API key from: https://aistudio.google.com/app/apikey

---

### Error: "No module named 'pipecat'"

**Symptom:**
```
ModuleNotFoundError: No module named 'pipecat'
```

**Solution:**
```bash
# Activate venv first
source venv/bin/activate      # Linux/Mac
venv\Scripts\activate.bat     # Windows

# Then install
pip install -r requirements.txt
```

---

### Error: "Failed to connect to Gemini Live API"

**Symptom:**
```
ConnectionError: Failed to connect to Gemini Live API
```

**Solutions:**

1. **Check API Key:**
   ```bash
   # Verify key is set
   cat .env | grep GEMINI_API_KEY

   # Test key manually
   curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_KEY"
   ```

2. **Check Internet Connection:**
   - Ensure stable internet
   - Try pinging Google: `ping google.com`

3. **Check API Quota:**
   - Visit: https://console.cloud.google.com/apis/dashboard
   - Check if you've exceeded rate limits

---

### Error: "WebRTC connection failed"

**Symptom:**
```
WebRTC connection failed
```

**Solutions:**

1. **Check Port Availability:**
   ```bash
   # Check if port 7860 is in use
   netstat -ano | findstr :7860    # Windows
   lsof -i :7860                   # Linux/Mac
   ```

2. **Firewall Settings:**
   - Allow Python through firewall
   - Allow port 7860 inbound/outbound

3. **Run on Different Port:**
   ```bash
   python gemini_live.py --port 8080
   ```

---

## Runtime Issues

### High Latency / Slow Response

**Symptoms:**
- Bot takes >3 seconds to respond
- Audio playback is choppy

**Solutions:**

1. **Check Internet Speed:**
   - Minimum: 5 Mbps upload/download
   - Test at: https://fast.com

2. **Adjust VAD Settings:**
   Edit `gemini_live.py`:
   ```python
   vad_analyzer=SileroVADAnalyzer(params=VADParams(
       stop_secs=0.3,  # Reduce from 0.5 for faster turn-taking
   ))
   ```

3. **Check System Resources:**
   ```bash
   # Check CPU/Memory usage
   top         # Linux/Mac
   taskmgr     # Windows
   ```

---

### Bot Not Responding

**Symptoms:**
- Bot connects but doesn't speak
- No audio output

**Solutions:**

1. **Check Logs:**
   ```bash
   python gemini_live.py 2>&1 | tee debug.log
   ```

2. **Test Microphone:**
   - Ensure microphone permissions granted
   - Test in browser: chrome://settings/content/microphone

3. **Verify WebRTC Client:**
   - Check browser console for errors
   - Try different browser (Chrome recommended)

---

### Bot Cuts Off User Speech

**Symptoms:**
- Bot interrupts before user finishes
- Audio gets truncated

**Solutions:**

1. **Increase VAD stop_secs:**
   ```python
   vad_analyzer=SileroVADAnalyzer(params=VADParams(
       stop_secs=0.8,  # Increase from 0.5 for more patience
   ))
   ```

2. **Adjust Volume Threshold:**
   ```python
   vad_analyzer=SileroVADAnalyzer(params=VADParams(
       stop_secs=0.5,
       min_volume=0.4,  # Lower threshold for quieter voices
   ))
   ```

---

### Hindi/Hinglish Not Working

**Symptoms:**
- Bot doesn't understand Hindi
- Responds in English only

**Solutions:**

1. **Verify System Instruction:**
   Check `system_instruction` in `gemini_live.py` has Hindi content

2. **Test with Clear Hindi:**
   - Speak slowly and clearly
   - Avoid heavy accents initially

3. **Check Gemini Model:**
   - Ensure using `gemini-2.5-flash` or newer
   - Older models have limited Hindi support

---

## Performance Issues

### Memory Issues

**Symptom:**
```
MemoryError: Unable to allocate memory
```

**Solutions:**

1. **Close Other Applications:**
   - Free up RAM before running

2. **Use Lighter Models:**
   - Gemini Live is already optimized
   - Consider reducing concurrent connections

3. **Monitor Memory:**
   ```bash
   # Check available memory
   free -h          # Linux
   wmic OS get FreePhysicalMemory  # Windows
   ```

---

### CPU Overload

**Symptoms:**
- Fan running loud
- System becomes slow
- Bot stutters

**Solutions:**

1. **Reduce VAD Processing:**
   ```python
   # Use longer intervals
   vad_analyzer=SileroVADAnalyzer(params=VADParams(
       stop_secs=0.8,
   ))
   ```

2. **Limit Concurrent Connections:**
   - Run single bot instance
   - Don't run multiple bots simultaneously

---

## API Issues

### Rate Limit Exceeded

**Symptom:**
```
429 Too Many Requests
```

**Solutions:**

1. **Check Quota:**
   - Visit: https://console.cloud.google.com/apis/dashboard
   - Check Gemini API quota usage

2. **Add Retry Logic:**
   - Wait a few seconds between requests
   - Implement exponential backoff

3. **Upgrade Plan:**
   - Free tier has limits
   - Consider paid tier for production

---

### Invalid API Key

**Symptom:**
```
401 Unauthorized: Invalid API key
```

**Solutions:**

1. **Regenerate Key:**
   - Visit: https://aistudio.google.com/app/apikey
   - Create new key
   - Update `.env`

2. **Check Key Format:**
   - Should start with `AIza...`
   - No extra spaces or quotes

3. **Verify Permissions:**
   - Ensure API key has Gemini API access
   - Check API is enabled in console

---

## Advanced Debugging

### Enable Debug Logging

Add to `gemini_live.py`:
```python
import logging
logging.basicConfig(level=logging.DEBUG)
logger.setLevel(logging.DEBUG)
```

### Capture Network Traffic

```bash
# Monitor network requests
tcpdump -i any port 443 -w gemini_debug.pcap
```

### Test Gemini API Directly

```python
import google.generativeai as genai

genai.configure(api_key="your_key")
model = genai.GenerativeModel("gemini-2.5-flash")
response = model.generate_content("Hello")
print(response.text)
```

---

## Getting Help

If issues persist:

1. **Check Logs:**
   ```bash
   python gemini_live.py 2>&1 | tee debug.log
   ```

2. **Gather Information:**
   - Python version: `python --version`
   - Pipecat version: `pip show pipecat-ai`
   - OS version
   - Error messages
   - Debug logs

3. **Report Issue:**
   - [Pipecat GitHub](https://github.com/pipecat-ai/pipecat/issues)
   - Include logs and system info
   - Describe steps to reproduce

---

## Prevention Tips

### Best Practices

1. **Always Use Virtual Environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate
   ```

2. **Keep Dependencies Updated:**
   ```bash
   pip install --upgrade -r requirements.txt
   ```

3. **Use Stable Python Version:**
   - Recommended: Python 3.10 or 3.11
   - Avoid 3.13 (too new, compatibility issues)

4. **Regular Cleanup:**
   ```bash
   # Clear pip cache monthly
   pip cache purge

   # Remove unused packages
   pip autoremove
   ```

5. **Monitor Resources:**
   - Check CPU/RAM usage
   - Ensure stable internet
   - Close unnecessary applications

---

## Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| Null bytes error | Run `setup.bat` or `setup.sh` |
| Missing API key | Copy `.env.example` to `.env` and add key |
| Module not found | `pip install -r requirements.txt` |
| Connection failed | Check internet and API key |
| High latency | Reduce `stop_secs` in VAD params |
| Bot cuts off user | Increase `stop_secs` to 0.8-1.0 |
| Memory issues | Close other apps, use lighter models |
| Rate limit | Wait or upgrade API plan |

---

## Support Resources

- **Pipecat Docs:** https://docs.pipecat.ai
- **Gemini API Docs:** https://ai.google.dev/gemini-api/docs/live
- **Python Virtual Env:** https://docs.python.org/3/library/venv.html
- **WebRTC Guide:** https://webrtc.org/getting-started/overview
