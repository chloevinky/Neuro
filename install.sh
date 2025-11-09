#!/bin/bash

# Neuro AI VTuber - Self-Installing Package
# This script will install and configure the Neuro AI VTuber application

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PYTHON_VERSION="3.11"
VENV_NAME="venv"
PYTORCH_VERSION="2.2.2"
CUDA_VERSION="cu118"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Neuro AI VTuber - Installation Script             ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""

# Function to print step headers
print_step() {
    echo ""
    echo -e "${GREEN}[STEP]${NC} $1"
    echo "────────────────────────────────────────────────────────────"
}

# Function to print info
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to print error and exit
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Function to print success
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if running on Linux or Windows (Git Bash/WSL)
print_step "Detecting operating system"
OS=$(uname -s)
case "$OS" in
    Linux*)     OS_TYPE="Linux";;
    MINGW*|MSYS*|CYGWIN*)     OS_TYPE="Windows";;
    *)          OS_TYPE="Unknown";;
esac
print_info "Detected OS: $OS_TYPE"

# Detect Python command (Windows uses 'python' or 'py', Linux uses 'python3')
print_step "Checking Python version"
PYTHON_CMD=""

if [ "$OS_TYPE" = "Windows" ]; then
    # On Windows, try python, py, then python3
    if command -v python &> /dev/null; then
        PYTHON_CMD="python"
    elif command -v py &> /dev/null; then
        PYTHON_CMD="py"
    elif command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    fi
else
    # On Linux/Mac, try python3 first, then python
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
    fi
fi

if [ -z "$PYTHON_CMD" ]; then
    print_error "Python is not installed or not in PATH. Please install Python $PYTHON_VERSION or higher."
    print_info "On Windows, you can download from: https://www.python.org/downloads/"
    print_info "Make sure to check 'Add Python to PATH' during installation."
    exit 1
fi

print_info "Using Python command: $PYTHON_CMD"

PYTHON_VER=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
PYTHON_MAJOR=$(echo $PYTHON_VER | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VER | cut -d. -f2)

print_info "Found Python version: $PYTHON_VER"

if [ -z "$PYTHON_MAJOR" ] || [ -z "$PYTHON_MINOR" ]; then
    print_error "Could not parse Python version. Got: $PYTHON_VER"
    exit 1
fi

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 11 ]); then
    print_error "Python $PYTHON_VERSION or higher is required. Found: $PYTHON_VER"
fi

# Check if Python is too new for stable PyTorch
if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 13 ]; then
    print_warning "Python $PYTHON_VER detected. PyTorch 2.2.2 doesn't support Python 3.13+."
    print_warning "Recommended: Use Python 3.11 or 3.12 for best compatibility."
    echo ""
    echo "Options:"
    echo "  1. Continue with latest PyTorch 2.5.1 + CUDA 12.1 (may have compatibility issues)"
    echo "  2. Cancel and reinstall Python 3.11 or 3.12 (recommended)"
    echo ""
    echo -n "Enter choice (1 or 2): "
    read -r python_choice
    if [ "$python_choice" = "2" ]; then
        print_info "Installation cancelled. Please install Python 3.11 or 3.12."
        print_info "Download from: https://www.python.org/downloads/"
        exit 0
    fi
    # Use latest PyTorch with CUDA 12.1 for newer Python
    PYTORCH_VERSION="2.5.1"
    PYTORCH_VISION="0.20.1"
    PYTORCH_AUDIO="2.5.1"
    CUDA_VERSION="cu121"  # PyTorch 2.5.1 uses CUDA 12.1, not 11.8
    print_info "Will use PyTorch $PYTORCH_VERSION with CUDA 12.1"
else
    # Use tested versions for Python 3.11-3.12
    PYTORCH_VISION="0.17.2"
    PYTORCH_AUDIO="2.2.2"
    print_info "Will use PyTorch $PYTORCH_VERSION with CUDA 11.8"
fi

print_success "Python version check passed"

# Check for NVIDIA GPU (optional but recommended)
print_step "Checking for NVIDIA GPU"
if command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || echo "Not found")
    print_info "NVIDIA GPU detected: $GPU_INFO"
    HAS_GPU=true
else
    print_warning "NVIDIA GPU not detected or nvidia-smi not available."
    print_warning "This application works best with an NVIDIA GPU (12GB+ VRAM recommended)."
    HAS_GPU=false
    echo -n "Continue anyway? (y/n): "
    read -r continue_install
    if [ "$continue_install" != "y" ]; then
        print_error "Installation cancelled by user."
    fi
fi

# Create virtual environment
print_step "Creating Python virtual environment"
if [ -d "$VENV_NAME" ]; then
    print_warning "Virtual environment already exists."
    echo -n "Do you want to recreate it? This will delete the existing one. (y/n): "
    read -r recreate_venv
    if [ "$recreate_venv" = "y" ]; then
        print_info "Removing existing virtual environment..."
        rm -rf "$VENV_NAME"
        $PYTHON_CMD -m venv "$VENV_NAME"
        print_success "Virtual environment recreated"
    else
        print_info "Using existing virtual environment"
    fi
else
    $PYTHON_CMD -m venv "$VENV_NAME"
    print_success "Virtual environment created"
fi

# Activate virtual environment
print_step "Activating virtual environment"
if [ "$OS_TYPE" = "Windows" ]; then
    source "$VENV_NAME/Scripts/activate"
else
    source "$VENV_NAME/bin/activate"
fi
print_success "Virtual environment activated"

# Upgrade pip
print_step "Upgrading pip"
python -m pip install --upgrade pip
print_success "Pip upgraded"

# Install PyTorch with CUDA support
print_step "Installing PyTorch ${PYTORCH_VERSION} with CUDA ${CUDA_VERSION}"
print_info "This may take several minutes depending on your internet connection..."
pip install torch==${PYTORCH_VERSION} torchvision==${PYTORCH_VISION} torchaudio==${PYTORCH_AUDIO} --index-url https://download.pytorch.org/whl/${CUDA_VERSION}
print_success "PyTorch installed"

# Install requirements
print_step "Installing Python dependencies"
print_info "This may take 10-15 minutes. Please be patient..."
pip install -r requirements.txt
print_success "Dependencies installed"

# Verify PyTorch version wasn't overridden
print_step "Verifying PyTorch installation"
TORCH_VER=$(pip show torch | grep Version | awk '{print $2}')
if [[ "$TORCH_VER" == *"${PYTORCH_VERSION}"* ]] && [[ "$TORCH_VER" == *"${CUDA_VERSION}"* ]]; then
    print_success "PyTorch ${PYTORCH_VERSION}+${CUDA_VERSION} verified"
else
    print_warning "PyTorch version mismatch detected: $TORCH_VER"
    print_info "Reinstalling correct PyTorch version..."
    pip install torch==${PYTORCH_VERSION} torchvision==${PYTORCH_VISION} torchaudio==${PYTORCH_AUDIO} --index-url https://download.pytorch.org/whl/${CUDA_VERSION}
fi

# DeepSpeed installation (optional, for TTS performance)
print_step "DeepSpeed installation (optional)"
echo -n "Do you want to install DeepSpeed for improved TTS performance? (y/n): "
read -r install_deepspeed
if [ "$install_deepspeed" = "y" ]; then
    print_info "Please manually download and install DeepSpeed wheels from:"
    print_info "https://github.com/erew123/alltalk_tts/releases/tag/DeepSpeed-14.0"
    print_info "Then run: pip install <path-to-deepspeed-wheel>"
    print_warning "Skipping automated DeepSpeed installation"
fi

# Configuration setup
print_step "Setting up configuration files"

# Setup .env file
if [ ! -f ".env" ]; then
    print_info "Creating .env file from template..."
    cp .env.example .env
    print_warning "Please edit .env file with your credentials:"
    print_info "  - TWITCH_APP_ID: Your Twitch application ID"
    print_info "  - TWITCH_SECRET: Your Twitch application secret"
    print_info "  - HF_TOKEN: Your Huggingface token (if using gated models)"
    echo -n "Press Enter when you're ready to edit .env file..."
    read -r
    ${EDITOR:-nano} .env
    print_success ".env file configured"
else
    print_warning ".env file already exists. Skipping."
fi

# List audio devices
print_step "Detecting audio devices"
print_info "Running audio device detection..."
python utils/listAudioDevices.py || print_warning "Could not list audio devices automatically"

echo ""
print_info "Please note the device numbers for your microphone and speakers."
echo -n "Press Enter to continue..."
read -r

# Configure constants.py
print_info "You need to configure constants.py with your specific settings:"
echo ""
echo "Required configurations (marked with #UNIQUE#):"
echo "  1. INPUT_DEVICE_INDEX - Your microphone device number"
echo "  2. OUTPUT_DEVICE_INDEX - Your speaker device number"
echo "  3. TWITCH_CHANNEL - Your Twitch channel name"
echo "  4. VOICE_REFERENCE - Name of your voice reference file in voices/ directory"
echo "  5. HOST_NAME - Your name"
echo ""
echo -n "Do you want to edit constants.py now? (y/n): "
read -r edit_constants
if [ "$edit_constants" = "y" ]; then
    ${EDITOR:-nano} constants.py
    print_success "constants.py configured"
fi

# Voice reference setup
print_step "Voice reference file setup"
print_info "Place a 5-30 second voice reference WAV file in the 'voices/' directory."
print_info "This will be used for TTS voice cloning."
if [ ! -d "voices" ]; then
    mkdir -p voices
    print_info "Created 'voices/' directory"
fi
echo -n "Press Enter when you've placed your voice file..."
read -r

# Installation complete
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║             Installation Complete!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
print_info "Next steps:"
echo ""
echo "1. Make sure text-generation-webui is installed and running with:"
echo "   - OpenAI API extension enabled"
echo "   - Your chosen LLM model loaded"
echo ""
echo "2. Install and configure Vtube Studio (optional)"
echo ""
echo "3. Start the application using the control script:"
echo "   ${GREEN}./neuro start${NC}"
echo ""
echo "4. Or run directly:"
if [ "$OS_TYPE" = "Windows" ]; then
    echo "   ${GREEN}$VENV_NAME/Scripts/activate && python main.py${NC}"
else
    echo "   ${GREEN}source $VENV_NAME/bin/activate && python main.py${NC}"
fi
echo ""
print_info "For more information, see INSTALL_README.md"
echo ""
