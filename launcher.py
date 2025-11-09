#!/usr/bin/env python3
"""
Neuro AI VTuber - Python Launcher
Cross-platform launcher with configuration validation and diagnostics
"""

import sys
import os
import subprocess
import platform
from pathlib import Path

# Color codes for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

    @staticmethod
    def strip():
        """Remove color codes if not in a terminal"""
        if not sys.stdout.isatty():
            Colors.RED = Colors.GREEN = Colors.YELLOW = ''
            Colors.BLUE = Colors.CYAN = Colors.NC = ''


def print_header():
    """Print application header"""
    print()
    print(f"{Colors.CYAN}╔════════════════════════════════════════════════════════════╗{Colors.NC}")
    print(f"{Colors.CYAN}║         Neuro AI VTuber - Launcher                        ║{Colors.NC}")
    print(f"{Colors.CYAN}╚════════════════════════════════════════════════════════════╝{Colors.NC}")
    print()


def print_info(msg):
    """Print info message"""
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {msg}")


def print_success(msg):
    """Print success message"""
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {msg}")


def print_warning(msg):
    """Print warning message"""
    print(f"{Colors.YELLOW}[WARN]{Colors.NC} {msg}")


def print_error(msg):
    """Print error message"""
    print(f"{Colors.RED}[ERROR]{Colors.NC} {msg}")


def check_python_version():
    """Check if Python version meets requirements"""
    print_info("Checking Python version...")
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 11):
        print_error(f"Python 3.11+ required. Found: {version.major}.{version.minor}.{version.micro}")
        return False
    print_success(f"Python version OK: {version.major}.{version.minor}.{version.micro}")
    return True


def check_venv():
    """Check if running in virtual environment"""
    in_venv = hasattr(sys, 'real_prefix') or (
        hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix
    )
    return in_venv


def check_dependencies():
    """Check if required packages are installed"""
    print_info("Checking dependencies...")
    required_packages = [
        'torch',
        'RealtimeSTT',
        'RealtimeTTS',
        'socketio',
        'twitchAPI',
        'chromadb',
    ]

    missing = []
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing.append(package)

    if missing:
        print_error(f"Missing packages: {', '.join(missing)}")
        print_info("Please run install.sh to install dependencies")
        return False

    print_success("All required packages found")
    return True


def check_config_files():
    """Check if configuration files exist"""
    print_info("Checking configuration files...")
    issues = []

    # Check .env file
    if not Path('.env').exists():
        issues.append(".env file not found")
        print_warning("  .env file not found - you need to configure API keys")
    else:
        print_success("  .env file found")

    # Check constants.py
    if not Path('constants.py').exists():
        issues.append("constants.py not found")
        print_error("  constants.py not found")
    else:
        print_success("  constants.py found")

        # Check for default values that need to be changed
        try:
            with open('constants.py', 'r', encoding='utf-8') as f:
                content = f.read()

            warnings = []
            if 'INPUT_DEVICE_INDEX = 1' in content:
                warnings.append("INPUT_DEVICE_INDEX may need configuration")
            if 'OUTPUT_DEVICE_INDEX = 7' in content:
                warnings.append("OUTPUT_DEVICE_INDEX may need configuration")
            if 'lunasparkai' in content:
                warnings.append("TWITCH_CHANNEL may need to be changed")

            if warnings:
                print_warning("  Some constants may need configuration:")
                for w in warnings:
                    print(f"    - {w}")
        except Exception as e:
            print_warning(f"  Could not validate constants.py: {e}")

    # Check main.py
    if not Path('main.py').exists():
        issues.append("main.py not found")
        print_error("  main.py not found")
    else:
        print_success("  main.py found")

    return len(issues) == 0


def check_voice_reference():
    """Check if voice reference file exists"""
    print_info("Checking voice reference file...")
    voices_dir = Path('voices')

    if not voices_dir.exists():
        print_warning("  voices/ directory not found")
        return False

    voice_files = list(voices_dir.glob('*.wav'))
    if not voice_files:
        print_warning("  No .wav files found in voices/ directory")
        return False

    print_success(f"  Found {len(voice_files)} voice file(s)")
    for vf in voice_files:
        print_info(f"    - {vf.name}")
    return True


def check_gpu():
    """Check for NVIDIA GPU"""
    print_info("Checking for NVIDIA GPU...")
    try:
        result = subprocess.run(
            ['nvidia-smi', '--query-gpu=name,memory.total', '--format=csv,noheader'],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0 and result.stdout.strip():
            gpu_info = result.stdout.strip()
            print_success(f"  GPU detected: {gpu_info}")
            return True
        else:
            print_warning("  No NVIDIA GPU detected")
            return False
    except (FileNotFoundError, subprocess.TimeoutExpired):
        print_warning("  nvidia-smi not available")
        return False


def run_diagnostics():
    """Run full diagnostic check"""
    print_header()
    print_info("Running diagnostics...")
    print()

    # System info
    print_info("System Information:")
    print(f"  Platform: {platform.system()} {platform.release()}")
    print(f"  Python: {sys.version.split()[0]}")
    print(f"  In Virtual Environment: {check_venv()}")
    print()

    # Run checks
    all_ok = True
    all_ok &= check_python_version()
    print()

    if check_venv():
        all_ok &= check_dependencies()
        print()
    else:
        print_warning("Not running in virtual environment")
        print_info("Some dependency checks skipped")
        print()

    all_ok &= check_config_files()
    print()

    check_voice_reference()
    print()

    check_gpu()
    print()

    if all_ok:
        print_success("All critical checks passed!")
        print_info("You can start the application with: python main.py")
    else:
        print_error("Some checks failed. Please review the messages above.")
        print_info("Run install.sh if you haven't already.")

    print()
    return all_ok


def show_help():
    """Show help message"""
    print_header()
    print("Usage: python launcher.py [command]")
    print()
    print("Commands:")
    print("  diagnostics   Run system diagnostics and configuration checks")
    print("  run           Run the main application")
    print("  help          Show this help message")
    print()
    print("Examples:")
    print("  python launcher.py diagnostics   # Check system and configuration")
    print("  python launcher.py run           # Start the application")
    print()


def main():
    """Main entry point"""
    Colors.strip()

    if len(sys.argv) < 2:
        show_help()
        sys.exit(0)

    command = sys.argv[1].lower()

    if command == 'diagnostics' or command == 'diag':
        success = run_diagnostics()
        sys.exit(0 if success else 1)

    elif command == 'run':
        print_header()
        print_info("Starting Neuro AI VTuber...")
        print_info("Press CTRL+C to stop")
        print()

        # Import and run main
        try:
            import main
            sys.exit(0)
        except KeyboardInterrupt:
            print()
            print_info("Shutting down...")
            sys.exit(0)
        except Exception as e:
            print_error(f"Failed to start: {e}")
            import traceback
            traceback.print_exc()
            sys.exit(1)

    elif command == 'help' or command == '--help' or command == '-h':
        show_help()
        sys.exit(0)

    else:
        print_error(f"Unknown command: {command}")
        print()
        show_help()
        sys.exit(1)


if __name__ == '__main__':
    main()
