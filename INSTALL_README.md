# Neuro AI VTuber - Installation & Usage Guide

Welcome to the simplified installation and control system for Neuro AI VTuber! This guide will help you get up and running quickly.

## Table of Contents
- [Quick Start](#quick-start)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Control Script Usage](#control-script-usage)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

For the impatient (make sure you meet the requirements first!):

```bash
# 1. Install
./install.sh

# 2. Configure your settings
nano constants.py
nano .env

# 3. Run
./neuro start
```

---

## System Requirements

### Recommended Setup
- **OS**: Linux or Windows 11
- **CPU**: Modern multi-core processor (Ryzen 7 / Intel i7 or better)
- **RAM**: 32GB DDR4/DDR5
- **GPU**: NVIDIA GPU with 12GB+ VRAM (RTX 4070 or better)
- **Python**: 3.11 or higher
- **CUDA**: 11.8
- **Storage**: 20GB+ free space

### Minimum Setup
- **OS**: Linux or Windows
- **RAM**: 16GB
- **GPU**: NVIDIA GPU with 8GB+ VRAM
- **Python**: 3.11
- You can adjust model sizes and quality settings to run on less powerful hardware

---

## Installation

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd Neuro
```

### Step 2: Run the Installer

The installer will handle everything automatically:

```bash
chmod +x install.sh
./install.sh
```

The installer will:
1. Check Python version (requires 3.11+)
2. Detect NVIDIA GPU
3. Create a virtual environment
4. Install PyTorch with CUDA support
5. Install all Python dependencies
6. Guide you through configuration

**⏱️ Estimated time**: 10-20 minutes (depending on internet speed)

### Step 3: Install External Dependencies

These need to be installed separately:

#### text-generation-webui (Required)
The LLM backend that runs your AI models.

```bash
# Follow the installation guide at:
# https://github.com/oobabooga/text-generation-webui
```

Download an LLM model (recommended: [LLAMA 3 8B Instruct EXL2](https://huggingface.co/turboderp/Llama-3-8B-Instruct-exl2/tree/4.0bpw))

#### Vtube Studio (Optional)
For vtuber model control and lip sync.

- Download from Steam or the official website
- The default Hiyori model works great!

#### Virtual Audio Cable (Optional)
To pipe TTS audio into Vtube Studio for lip sync.

- Windows: [VB-Cable](https://vb-audio.com/Cable/)
- Linux: Use PulseAudio or PipeWire virtual sinks

---

## Configuration

### 1. Environment Variables (.env)

Create and configure your `.env` file:

```bash
cp .env.example .env
nano .env
```

Required settings:
```
TWITCH_APP_ID=your_twitch_app_id
TWITCH_SECRET=your_twitch_secret
HF_TOKEN=your_huggingface_token  # Only if using gated models
```

**Getting Twitch credentials:**
1. Go to [Twitch Developer Portal](https://dev.twitch.tv/console)
2. Create a new application
3. Set OAuth Redirect URL to: `http://localhost:17563`
4. Copy your Client ID and Secret

### 2. Audio Device Configuration

Find your audio device IDs:

```bash
source venv/bin/activate  # or venv/Scripts/activate on Windows
python utils/listAudioDevices.py
```

Note the device numbers for your microphone and speakers.

### 3. Constants Configuration (constants.py)

Edit `constants.py` and update these UNIQUE values:

```python
# Audio devices (from previous step)
INPUT_DEVICE_INDEX = 1    # Your microphone
OUTPUT_DEVICE_INDEX = 7   # Your speakers

# Twitch settings
TWITCH_CHANNEL = "your_channel_name"

# Your name
HOST_NAME = "YourName"

# Voice reference file
VOICE_REFERENCE = "your_voice.wav"

# LLM endpoint
LLM_ENDPOINT = "http://127.0.0.1:5000"  # text-generation-webui default
```

### 4. Voice Reference File

Place a 5-30 second WAV file of the voice you want to clone in the `voices/` directory:

```bash
# Example
cp /path/to/your/voice.wav voices/neuro_voice.wav
```

Update `VOICE_REFERENCE` in `constants.py` to match your filename.

### 5. System Prompt (Optional)

Edit the `SYSTEM_PROMPT` in `constants.py` to customize your AI's personality and backstory.

---

## Running the Application

### Option 1: Using the Control Script (Recommended)

The `neuro` control script provides easy management:

```bash
# Start in foreground (interactive, see output)
./neuro start

# Start in background (daemon mode)
./neuro background

# Check status
./neuro status

# View logs
./neuro logs
./neuro logs -f  # Follow logs in real-time

# Stop the application
./neuro stop

# Restart
./neuro restart
```

### Option 2: Using Python Launcher

The Python launcher includes diagnostics:

```bash
source venv/bin/activate

# Run diagnostics
python launcher.py diagnostics

# Start application
python launcher.py run
```

### Option 3: Direct Execution

```bash
source venv/bin/activate  # or venv/Scripts/activate on Windows
python main.py
```

---

## Control Script Usage

### Starting the Application

**Foreground mode** (recommended for first run):
```bash
./neuro start
```
- See all output in real-time
- Press CTRL+C to stop
- Good for debugging

**Background mode** (daemon):
```bash
./neuro background
```
- Runs in background
- Output goes to `neuro.log`
- Use `./neuro logs -f` to watch output
- Use `./neuro stop` to stop

### Managing the Application

```bash
# Check if running
./neuro status

# View recent logs (last 50 lines)
./neuro logs

# Follow logs in real-time
./neuro logs -f

# Stop the application
./neuro stop

# Restart (stops if running, then starts in background)
./neuro restart
```

### Example Workflow

```bash
# First time setup
./install.sh
./neuro start  # Test in foreground mode

# If everything works, use background mode
./neuro stop
./neuro background

# Check status anytime
./neuro status

# View logs while running
./neuro logs -f
```

---

## Pre-Launch Checklist

Before starting Neuro, make sure:

- [ ] text-generation-webui is running
  - OpenAI API extension is enabled
  - Your LLM model is loaded
  - Accessible at the configured endpoint (default: http://127.0.0.1:5000)

- [ ] Vtube Studio is running (if using)
  - Model is loaded
  - Microphone is set to virtual audio cable (if using TTS lip sync)

- [ ] OBS or streaming software is set up (if streaming)

- [ ] All configuration files are set up:
  - `.env` has your API keys
  - `constants.py` is configured with your settings
  - Voice reference file is in `voices/` directory

### Quick Test

Run diagnostics to check your setup:

```bash
source venv/bin/activate
python launcher.py diagnostics
```

---

## Troubleshooting

### Installation Issues

**Problem: "Python version too old"**
```bash
# Install Python 3.11 or higher
# On Ubuntu/Debian:
sudo apt update
sudo apt install python3.11 python3.11-venv

# On Windows: Download from python.org
```

**Problem: "CUDA not found" or GPU errors**
```bash
# Check NVIDIA driver
nvidia-smi

# Reinstall PyTorch with CUDA
source venv/bin/activate
pip install torch==2.2.2 torchvision==0.17.2 torchaudio==2.2.2 --index-url https://download.pytorch.org/whl/cu118
```

**Problem: Dependency conflicts**
```bash
# See the exact versions used during development
cat pipfreeze.txt

# Recreate virtual environment
rm -rf venv
./install.sh
```

### Runtime Issues

**Problem: "Connection refused" when connecting to LLM**
- Make sure text-generation-webui is running
- Check that the OpenAI API extension is enabled
- Verify the endpoint URL in `constants.py`
- Test the endpoint: `curl http://127.0.0.1:5000/v1/models`

**Problem: Audio device errors**
- Run `python utils/listAudioDevices.py` to find correct device IDs
- Update `INPUT_DEVICE_INDEX` and `OUTPUT_DEVICE_INDEX` in `constants.py`

**Problem: "No module named 'XXX'"**
```bash
source venv/bin/activate
pip install -r requirements.txt
```

**Problem: TTS is slow or choppy**
- Install DeepSpeed for better performance (see DeepSpeed section in main README)
- Reduce TTS quality settings
- Ensure you have enough GPU VRAM

**Problem: Can't see logs with `./neuro logs`**
- Logs are only created when running in background mode
- When running in foreground mode, output goes to your terminal

### Getting Help

1. Check `neuro.log` for error messages
2. Run diagnostics: `python launcher.py diagnostics`
3. Review the main README.md for detailed architecture information
4. Check the GitHub issues page

---

## Advanced Usage

### Custom LLM Endpoints

To use a different LLM endpoint (e.g., local ollama, remote API):

Edit `constants.py`:
```python
LLM_ENDPOINT = "http://your-endpoint:port"
```

Make sure the endpoint is OpenAI API compatible.

### Multimodal Mode

To enable vision capabilities:

1. Install [Neuro-LLM-Server](https://github.com/kimjammer/Neuro-LLM-Server)
2. Update `constants.py`:
```python
MULTIMODAL_ENDPOINT = "http://127.0.0.1:8080"  # Your multimodal server
MULTIMODAL_STRATEGY = "always"  # or "never"
```

### Running as a System Service

For Linux users who want to run Neuro as a systemd service:

Create `/etc/systemd/system/neuro.service`:
```ini
[Unit]
Description=Neuro AI VTuber
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/path/to/Neuro
ExecStart=/path/to/Neuro/neuro background
ExecStop=/path/to/Neuro/neuro stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Then:
```bash
sudo systemctl enable neuro
sudo systemctl start neuro
sudo systemctl status neuro
```

---

## File Structure

After installation, your directory should look like:

```
Neuro/
├── install.sh              # Installer script
├── neuro                   # Control script
├── launcher.py             # Python launcher with diagnostics
├── main.py                 # Main application entry point
├── constants.py            # Configuration constants
├── .env                    # Environment variables (API keys)
├── venv/                   # Virtual environment
├── voices/                 # Voice reference files
├── memories/               # Persistent memory storage
├── modules/                # Application modules
├── llmWrappers/            # LLM integration
├── utils/                  # Utility scripts
├── neuro.log               # Log file (when running in background)
└── .neuro.pid              # PID file (when running in background)
```

---

## What's New in This Installer

This simplified installation package provides:

1. **One-Click Installation**: Single `install.sh` script handles everything
2. **Control Script**: Easy start/stop/status management via `./neuro` command
3. **Python Launcher**: Cross-platform launcher with built-in diagnostics
4. **Better Documentation**: This comprehensive guide
5. **Health Checks**: Built-in validation of your configuration
6. **Log Management**: Automatic logging with easy viewing
7. **Process Management**: PID tracking and graceful shutdown

---

## Next Steps

After successful installation:

1. **Test Your Setup**: Run `./neuro start` and verify everything works
2. **Customize**: Edit `constants.py` to customize AI personality and behavior
3. **Stream**: Set up OBS and go live on Twitch!
4. **Experiment**: Try different LLM models and configurations
5. **Contribute**: Share your improvements with the community

---

## Support

For issues, questions, or contributions:
- Check the main [README.md](README.md) for architecture details
- Review this guide's [Troubleshooting](#troubleshooting) section
- Check existing GitHub issues
- Consider supporting the developer on Ko-fi

Happy streaming! 🎉
