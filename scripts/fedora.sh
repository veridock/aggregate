#!/bin/bash
# Fedora/RHEL/CentOS Environment Setup Script for Document Processing Pipeline
# Supports: Fedora 35+, RHEL 8+, CentOS 8+, Rocky Linux 8+, AlmaLinux 8+

set -e  # Exit on any error

echo "🎩 Fedora/RHEL/CentOS Environment Setup for Document Processing Pipeline"
echo "======================================================================="

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

# Detect distribution
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    log "Detected: $PRETTY_NAME"

    # Determine package manager
    if command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
    else
        error "Neither dnf nor yum found"
        exit 1
    fi

    log "Using package manager: $PKG_MANAGER"
else
    error "Cannot detect OS version"
    exit 1
fi

# Enable EPEL repository for RHEL/CentOS
if [[ "$ID" == "rhel" || "$ID" == "centos" || "$ID" == "rocky" || "$ID" == "almalinux" ]]; then
    log "Enabling EPEL repository..."
    sudo $PKG_MANAGER install -y epel-release
fi

# Update package lists
log "Updating package lists..."
sudo $PKG_MANAGER update -y

# Install development tools
log "Installing development tools..."
sudo $PKG_MANAGER groupinstall -y "Development Tools"
sudo $PKG_MANAGER install -y \
    python3 \
    python3-pip \
    python3-devel \
    git \
    curl \
    wget \
    gcc \
    gcc-c++ \
    make

# Install Tesseract OCR
log "Installing Tesseract OCR..."
sudo $PKG_MANAGER install -y \
    tesseract \
    tesseract-langpack-eng \
    tesseract-langpack-pol \
    tesseract-devel

# Install Poppler utilities
log "Installing Poppler utilities..."
sudo $PKG_MANAGER install -y \
    poppler-utils \
    poppler-cpp-devel

# Install Cairo and related libraries
log "Installing Cairo libraries..."
sudo $PKG_MANAGER install -y \
    cairo-devel \
    pango-devel \
    gdk-pixbuf2-devel \
    libffi-devel

# Install additional image libraries
log "Installing image processing libraries..."
sudo $PKG_MANAGER install -y \
    libjpeg-turbo-devel \
    libpng-devel \
    libtiff-devel \
    libwebp-devel \
    openjpeg2-devel

# Install fonts for better PDF rendering
log "Installing fonts..."
sudo $PKG_MANAGER install -y \
    liberation-fonts \
    dejavu-fonts-common \
    fontconfig

# Install XML libraries
log "Installing XML libraries..."
sudo $PKG_MANAGER install -y \
    libxml2-devel \
    libxslt-devel

# Install web browser for dashboard viewing
log "Installing web browser..."
if ! command -v firefox &> /dev/null && ! command -v chromium &> /dev/null; then
    sudo $PKG_MANAGER install -y firefox
fi

# Create virtual environment tools
log "Installing virtual environment tools..."
sudo $PKG_MANAGER install -y python3-virtualenv

# Verify installations
log "Verifying installations..."

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    log "✓ Python: $PYTHON_VERSION"
else
    error "✗ Python3 not found"
    exit 1
fi

# Check pip
if command -v pip3 &> /dev/null; then
    PIP_VERSION=$(pip3 --version)
    log "✓ Pip: $PIP_VERSION"
else
    error "✗ pip3 not found"
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
python3 -m venv venv

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
python3 -c "
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
    'python3 --version'
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
python3 test_environment.py

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

# Create SELinux policy if needed
if command -v getenforce &> /dev/null && [[ $(getenforce) != "Disabled" ]]; then
    log "Creating SELinux policy for Python virtual environment..."
    sudo setsebool -P httpd_exec_mem 1 2>/dev/null || true
    warn "SELinux is enabled. You may need to adjust policies if you encounter permission issues."
fi

# Final instructions
echo ""
echo "🎉 Fedora/RHEL/CentOS environment setup completed successfully!"
echo "=================================================================="
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
echo "  ✓ Python 3 with virtual environment"
echo "  ✓ Development Tools group"
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
Exec=gnome-terminal --working-directory="$PROJECT_DIR" --command="bash -c 'source venv/bin/activate; exec bash'"
Icon=applications-office
Terminal=true
Categories=Office;Development;
EOF
    chmod +x "$HOME/Desktop/Document-Processor.desktop"
    log "✓ Desktop shortcut created"
fi

echo "Setup completed at: $(date)"