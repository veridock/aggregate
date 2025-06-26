#!/bin/bash
# Arch Linux Environment Setup Script for Document Processing Pipeline
# Supports: Arch Linux, Manjaro, EndeavourOS, ArcoLinux

set -e  # Exit on any error

echo "🏹 Arch Linux Environment Setup for Document Processing Pipeline"
echo "================================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root. Run as regular user with sudo access."
   exit 1
fi

# Detect Arch-based distribution
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    log "Detected: $PRETTY_NAME"
else
    error "Cannot detect OS version"
    exit 1
fi

# Check if pacman is available
if ! command -v pacman &> /dev/null; then
    error "pacman not found. This script is for Arch-based distributions only."
    exit 1
fi

# Update package database
log "Updating package database..."
sudo pacman -Sy

# Install base development tools
log "Installing base development tools..."
sudo pacman -S --needed --noconfirm \
    base-devel \
    python \
    python-pip \
    python-virtualenv \
    git \
    curl \
    wget

# Install Tesseract OCR
log "Installing Tesseract OCR..."
sudo pacman -S --needed --noconfirm \
    tesseract \
    tesseract-data-eng \
    tesseract-data-pol

# Install Poppler utilities
log "Installing Poppler utilities..."
sudo pacman -S --needed --noconfirm \
    poppler \
    poppler-glib

# Install Cairo and related libraries
log "Installing Cairo libraries..."
sudo pacman -S --needed --noconfirm \
    cairo \
    pango \
    gdk-pixbuf2 \
    libffi

# Install additional image libraries
log "Installing image processing libraries..."
sudo pacman -S --needed --noconfirm \
    libjpeg-turbo \
    libpng \
    libtiff \
    libwebp \
    openjpeg2

# Install fonts for better PDF rendering
log "Installing fonts..."
sudo pacman -S --needed --noconfirm \
    ttf-liberation \
    ttf-dejavu \
    fontconfig

# Install XML libraries
log "Installing XML libraries..."
sudo pacman -S --needed --noconfirm \
    libxml2 \
    libxslt

# Install web browser for dashboard viewing
log "Installing web browser..."
if ! command -v firefox &> /dev/null && ! command -v chromium &> /dev/null; then
    sudo pacman -S --needed --noconfirm firefox
fi

# Install AUR helper if not present (optional)
if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
    warn "No AUR helper found. Installing yay..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
fi

# Verify installations
log "Verifying installations..."

# Check Python
if command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version)
    log "✓ Python: $PYTHON_VERSION"
else
    error "✗ Python not found"
    exit 1
fi

# Check pip
if command -v pip &> /dev/null; then
    PIP_VERSION=$(pip --version)
    log "✓ Pip: $PIP_VERSION"
else
    error "✗ pip not found"
    exit 1
fi

# Check Tesseract
if command -v tesseract &> /dev/null; then
    TESSERACT_VERSION=$(tesseract --version | head -n1)
    log "✓ Tesseract: $TESSERACT_VERSION"
else
    error "✗ Tesseract not found"
    exit 1
fi

# Check Poppler
if command -v pdftoppm &> /dev/null; then
    POPPLER_VERSION=$(pdftoppm -v 2>&1 | head -n1 || echo "Poppler installed")
    log "✓ Poppler: $POPPLER_VERSION"
else
    error "✗ Poppler not found"
    exit 1
fi

# Check Cairo
if pkg-config --exists cairo; then
    CAIRO_VERSION=$(pkg-config --modversion cairo)
    log "✓ Cairo: $CAIRO_VERSION"
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
python -m venv venv

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

# Create test files
log "Creating test files..."

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

# Create simple test script
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
            print(f"✗ {command}: {result.stderr}")
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

if all_modules_ok and all_commands_ok:
    print("\n🎉 Environment setup successful!")
    sys.exit(0)
else:
    print("\n❌ Environment setup failed!")
    sys.exit(1)
EOF

chmod +x test_environment.py

# Run test
log "Running environment test..."
python test_environment.py

# Create activation script
cat > activate_env.sh << 'EOF'
#!/bin/bash
# Activation script for document processing environment

echo "Activating document processing environment..."
cd "$(dirname "$0")"
source venv/bin/activate
echo "Environment activated!"
echo "Run 'deactivate' to exit the environment"
EOF

chmod +x activate_env.sh

# Final instructions
echo ""
echo "🎉 Arch Linux environment setup completed successfully!"
echo "======================================================"
echo ""
echo "📁 Project location: $PROJECT_DIR"
echo ""
echo "🚀 Next steps:"
echo "1. cd $PROJECT_DIR"
echo "2. source venv/bin/activate  # or run ./activate_env.sh"
echo "3. Download the project files (Makefile, processor.py, etc.)"
echo "4. Run: make all"
echo ""
echo "🔧 Installed components:"
echo "  ✓ Python with virtual environment"
echo "  ✓ Base development tools"
echo "  ✓ Tesseract OCR (English + Polish)"
echo "  ✓ Poppler utilities"
echo "  ✓ Cairo graphics library"
echo "  ✓ All required Python packages"
echo "  ✓ Image processing libraries"
echo "  ✓ Web browser for dashboard"
echo ""
echo "💡 To reactivate environment later:"
echo "   cd $PROJECT_DIR && source venv/bin/activate"
echo ""

# Create desktop shortcut if desktop environment is available
if [ -n "$DESKTOP_SESSION" ] && [ -d "$HOME/Desktop" ]; then
    log "Creating desktop shortcut..."
    cat > "$HOME/Desktop/Document-Processor.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Document Processor
Comment=Launch Document Processing Pipeline
Exec=konsole --workdir="$PROJECT_DIR" -e bash -c 'source venv/bin/activate; exec bash'
Icon=applications-office
Terminal=true
Categories=Office;Development;
EOF
    chmod +x "$HOME/Desktop/Document-Processor.desktop"
    log "✓ Desktop shortcut created"
fi

echo "Setup completed at: $(date)"