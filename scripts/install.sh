#!/bin/bash
# Universal Linux Environment Setup Script for Document Processing Pipeline
# Auto-detects: Ubuntu/Debian, Fedora/RHEL/CentOS, Arch Linux, openSUSE

set -e  # Exit on any error

echo "🐧 Universal Linux Environment Setup for Document Processing Pipeline"
echo "====================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${PURPLE}[SUCCESS]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root. Run as regular user with sudo access."
   exit 1
fi

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/SuSE-release ]]; then
        echo "opensuse"
    else
        echo "unknown"
    fi
}

# Get distribution info
get_distro_info() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        echo "Unknown Linux Distribution"
    fi
}

DISTRO=$(detect_distro)
DISTRO_INFO=$(get_distro_info)

log "Detected distribution: $DISTRO_INFO"

# Function to install packages based on distribution
install_system_packages() {
    case $DISTRO in
        ubuntu|debian|mint|pop|elementary)
            log "Installing packages using apt..."
            sudo apt-get update
            sudo apt-get install -y \
                python3 python3-pip python3-venv python3-dev \
                build-essential git curl wget \
                tesseract-ocr tesseract-ocr-eng tesseract-ocr-pol libtesseract-dev \
                poppler-utils poppler-data \
                libcairo2-dev libpango1.0-dev libgdk-pixbuf2.0-dev libffi-dev \
                libjpeg-dev libpng-dev libtiff5-dev libwebp-dev libopenjp2-7-dev \
                fonts-liberation fonts-dejavu-core fontconfig \
                libxml2-dev libxslt1-dev \
                firefox
            ;;

        fedora|rhel|centos|rocky|almalinux)
            log "Installing packages using dnf/yum..."
            if command -v dnf &> /dev/null; then
                PKG_MANAGER="dnf"
            else
                PKG_MANAGER="yum"
            fi

            # Enable EPEL for RHEL/CentOS
            if [[ "$DISTRO" =~ ^(rhel|centos|rocky|almalinux)$ ]]; then
                sudo $PKG_MANAGER install -y epel-release
            fi

            sudo $PKG_MANAGER update -y
            sudo $PKG_MANAGER groupinstall -y "Development Tools"
            sudo $PKG_MANAGER install -y \
                python3 python3-pip python3-devel python3-virtualenv \
                git curl wget gcc gcc-c++ make \
                tesseract tesseract-langpack-eng tesseract-langpack-pol tesseract-devel \
                poppler-utils poppler-cpp-devel \
                cairo-devel pango-devel gdk-pixbuf2-devel libffi-devel \
                libjpeg-turbo-devel libpng-devel libtiff-devel libwebp-devel openjpeg2-devel \
                liberation-fonts dejavu-fonts-common fontconfig \
                libxml2-devel libxslt-devel \
                firefox
            ;;

        arch|manjaro|endeavouros|arcolinux)
            log "Installing packages using pacman..."
            sudo pacman -Sy
            sudo pacman -S --needed --noconfirm \
                base-devel python python-pip python-virtualenv \
                git curl wget \
                tesseract tesseract-data-eng tesseract-data-pol \
                poppler poppler-glib \
                cairo pango gdk-pixbuf2 libffi \
                libjpeg-turbo libpng libtiff libwebp openjpeg2 \
                ttf-liberation ttf-dejavu fontconfig \
                libxml2 libxslt \
                firefox
            ;;

        opensuse*|sles)
            log "Installing packages using zypper..."
            sudo zypper refresh
            sudo zypper install -y -t pattern devel_basis
            sudo zypper install -y \
                python3 python3-pip python3-virtualenv python3-devel \
                git curl wget gcc gcc-c++ make \
                tesseract-ocr tesseract-ocr-traineddata-english tesseract-ocr-traineddata-polish tesseract-ocr-devel \
                poppler-tools libpoppler-devel \
                cairo-devel pango-devel gdk-pixbuf-devel libffi-devel \
                libjpeg8-devel libpng16-devel libtiff-devel libwebp-devel openjpeg2-devel \
                liberation-fonts dejavu-fonts fontconfig \
                libxml2-devel libxslt-devel \
                firefox
            ;;

        *)
            error "Unsupported distribution: $DISTRO"
            error "Supported distributions: Ubuntu/Debian, Fedora/RHEL/CentOS, Arch Linux, openSUSE"
            exit 1
            ;;
    esac
}

# Function to get Python command (python3 vs python)
get_python_cmd() {
    if command -v python3 &> /dev/null; then
        echo "python3"
    elif command -v python &> /dev/null; then
        echo "python"
    else
        error "Python not found"
        exit 1
    fi
}

# Function to get pip command
get_pip_cmd() {
    if command -v pip3 &> /dev/null; then
        echo "pip3"
    elif command -v pip &> /dev/null; then
        echo "pip"
    else
        error "pip not found"
        exit 1
    fi
}

# Install system packages
log "Installing system dependencies for $DISTRO..."
install_system_packages

# Verify installations
log "Verifying installations..."

PYTHON_CMD=$(get_python_cmd)
PIP_CMD=$(get_pip_cmd)

# Check Python
if command -v $PYTHON_CMD &> /dev/null; then
    PYTHON_VERSION=$($PYTHON_CMD --version)
    success "✓ Python: $PYTHON_VERSION"
else
    error "✗ Python not found"
    exit 1
fi

# Check pip
if command -v $PIP_CMD &> /dev/null; then
    PIP_VERSION=$($PIP_CMD --version)
    success "✓ Pip: $PIP_VERSION"
else
    error "✗ pip not found"
    exit 1
fi

# Check Tesseract
if command -v tesseract &> /dev/null; then
    TESSERACT_VERSION=$(tesseract --version | head -n1)
    success "✓ Tesseract: $TESSERACT_VERSION"
else
    error "✗ Tesseract not found"
    exit 1
fi

# Check Poppler
if command -v pdftoppm &> /dev/null; then
    success "✓ Poppler utilities installed"
else
    error "✗ Poppler not found"
    exit 1
fi

# Check Cairo
if pkg-config --exists cairo; then
    CAIRO_VERSION=$(pkg-config --modversion cairo)
    success "✓ Cairo: $CAIRO_VERSION"
else
    error "✗ Cairo not found"
    exit 1
fi

# Create project directory
PROJECT_DIR="$HOME/document-processor"
log "Creating project directory: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create virtual environment
log "Creating Python virtual environment..."
$PYTHON_CMD -m venv venv

# Activate virtual environment
log "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip in virtual environment
log "Upgrading pip in virtual environment..."
pip install --upgrade pip setuptools wheel

# Install Python dependencies
log "Installing Python dependencies..."
pip install \
    markdown==3.4.4 \
    reportlab==4.0.4 \
    weasyprint==60.0 \
    cairosvg==2.7.1 \
    Pillow==10.0.0 \
    pytesseract==0.3.10 \
    pdf2image==3.1.0 \
    beautifulsoup4==4.12.2 \
    lxml==4.9.3

# Test installations
log "Testing Python packages..."
python -c "
import markdown
import reportlab
import weasyprint
import cairosvg
import PIL
import pytesseract
import pdf2image
import bs4
import lxml
print('✓ All Python packages imported successfully')
"

# Create project files
log "Creating project files..."

# Create requirements.txt
cat > requirements.txt << 'EOF'
markdown==3.4.4
reportlab==4.0.4
weasyprint==60.0
cairosvg==2.7.1
Pillow==10.0.0
pytesseract==0.3.10
pdf2image==3.1.0
beautifulsoup4==4.12.2
lxml==4.9.3
EOF

# Create environment test script
cat > test_environment.py << 'EOF'
#!/usr/bin/env python3
"""Test script to verify environment setup"""

import sys
import subprocess

def test_import(module_name):
    try:
        __import__(module_name)
        print(f"✓ {module_name}")
        return True
    except ImportError as e:
        print(f"✗ {module_name}: {e}")
        return False

def test_command(command):
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✓ {command}")
            return True
        else:
            print(f"✗ {command}: {result.stderr.strip()}")
            return False
    except Exception as e:
        print(f"✗ {command}: {e}")
        return False

print("Testing Python modules:")
modules = [
    'markdown', 'reportlab', 'weasyprint', 'cairosvg',
    'PIL', 'pytesseract', 'pdf2image', 'bs4', 'lxml'
]

all_modules_ok = all(test_import(module) for module in modules)

print("\nTesting system commands:")
commands = [
    'tesseract --version',
    'pdftoppm -h',
    'python --version'
]

all_commands_ok = all(test_command(cmd) for cmd in commands)

print(f"\nDistribution: {subprocess.getoutput('cat /etc/os-release | grep PRETTY_NAME')}")

if all_modules_ok and all_commands_ok:
    print("\n🎉 Environment setup successful!")
    sys.exit(0)
else:
    print("\n❌ Environment setup failed!")
    sys.exit(1)
EOF

chmod +x test_environment.py

# Create activation script
cat > activate_env.sh << 'EOF'
#!/bin/bash
# Activation script for document processing environment

echo "🐧 Activating document processing environment..."
cd "$(dirname "$0")"
source venv/bin/activate
echo "✓ Environment activated!"
echo ""
echo "Available commands:"
echo "  python test_environment.py  # Test installation"
echo "  make install                # Install project dependencies"
echo "  make all                    # Run complete pipeline"
echo "  deactivate                  # Exit environment"
echo ""
EOF

chmod +x activate_env.sh

# Create system info script
cat > system_info.sh << 'EOF'
#!/bin/bash
# System information script

echo "🖥️  System Information"
echo "===================="
echo "Distribution: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo ""

echo "📦 Installed Components"
echo "======================"
echo "Python: $(python --version 2>&1)"
echo "Pip: $(pip --version | cut -d' ' -f1-2)"
echo "Tesseract: $(tesseract --version | head -n1)"
echo "Cairo: $(pkg-config --modversion cairo 2>/dev/null || echo 'Not found')"
echo ""

echo "🔧 Virtual Environment"
echo "====================="
if [[ "$VIRTUAL_ENV" ]]; then
    echo "Status: Active"
    echo "Path: $VIRTUAL_ENV"
else
    echo "Status: Inactive"
    echo "Run: source venv/bin/activate"
fi
EOF

chmod +x system_info.sh

# Run test
log "Running environment test..."
python test_environment.py

# Create README for the environment
cat > ENVIRONMENT_README.md << 'EOF'
# Document Processing Environment

## 🎯 Quick Start

```bash
# Activate environment
source venv/bin/activate
# or
./activate_env.sh

# Test installation
python test_environment.py

# View system info
./system_info.sh
```

## 📁 Directory Structure

```
document-processor/
├── venv/                   # Python virtual environment
├── requirements.txt        # Python dependencies
├── test_environment.py     # Environment verification
├── activate_env.sh         # Environment activation
├── system_info.sh          # System information
└── ENVIRONMENT_README.md   # This file
```

## 🚀 Next Steps

1. Download the main project files:
   - Makefile
   - processor.py
   - README.md

2. Run the pipeline:
   ```bash
   make all
   ```

3. View dashboard:
   - Opens automatically in browser
   - Located at: output/dashboard.html

## 🔧 Troubleshooting

- **Permission issues**: Check sudo access
- **Missing packages**: Re-run the installer
- **OCR not working**: Verify tesseract installation
- **PDF errors**: Check poppler installation

## 📞 Support

- Test environment: `python test_environment.py`
- System info: `./system_info.sh`
- Reinstall: Re-run the universal installer
EOF

# Final success message
echo ""
echo "🎉 Universal Linux environment setup completed successfully!"
echo "============================================================"
echo ""
echo "📊 Installation Summary:"
echo "  📁 Project location: $PROJECT_DIR"
echo "  🐧 Distribution: $DISTRO_INFO"
echo "  🐍 Python: $PYTHON_VERSION"
echo "  📦 All dependencies installed"
echo ""
echo "🚀 Next Steps:"
echo "1. cd $PROJECT_DIR"
echo "2. source venv/bin/activate  # or run ./activate_env.sh"
echo "3. Download project files (Makefile, processor.py)"
echo "4. Run: make all"
echo ""
echo "📚 Created Files:"
echo "  ✓ requirements.txt         # Python dependencies"
echo "  ✓ test_environment.py      # Environment verification"
echo "  ✓ activate_env.sh          # Easy activation"
echo "  ✓ system_info.sh           # System information"
echo "  ✓ ENVIRONMENT_README.md    # Environment guide"
echo ""
echo "💡 Useful Commands:"
echo "  ./activate_env.sh           # Activate environment"
echo "  python test_environment.py  # Test installation"
echo "  ./system_info.sh            # View system info"
echo ""

# Create desktop shortcut if possible
if [ -n "$DESKTOP_SESSION" ] && [ -d "$HOME/Desktop" ]; then
    log "Creating desktop shortcut..."
    cat > "$HOME/Desktop/Document-Processor.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Document Processor
Comment=Launch Document Processing Pipeline
Exec=x-terminal-emulator -e bash -c 'cd "$PROJECT_DIR" && source venv/bin/activate && exec bash'
Icon=applications-office
Terminal=true
Categories=Office;Development;
EOF
    chmod +x "$HOME/Desktop/Document-Processor.desktop"
    success "✓ Desktop shortcut created"
fi

echo "Setup completed at: $(date)"
echo ""
echo "🎊 Ready to process documents! 🎊"