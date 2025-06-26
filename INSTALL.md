# 🐧 Complete Linux Installation Guide

## Document Processing Pipeline Environment Setup

### 📋 Available Installation Scripts

| Distribution | Script | Description |
|-------------|--------|-------------|
| **Universal** | `universal_installer.sh` | 🌟 **Auto-detects and installs on any Linux** |
| Ubuntu/Debian | `install_ubuntu.sh` | Optimized for apt-based systems |
| Fedora/RHEL/CentOS | `install_fedora.sh` | Optimized for dnf/yum-based systems |
| Arch Linux | `install_arch.sh` | Optimized for pacman-based systems |
| openSUSE | `install_opensuse.sh` | Optimized for zypper-based systems |

---

## 🚀 Quick Installation (Recommended)

### Option 1: Universal Installer (Works on all Linux)
```bash
# Download and run universal installer
curl -O https://your-repo/universal_installer.sh
chmod +x universal_installer.sh
./universal_installer.sh
```

### Option 2: Distribution-Specific
```bash
# For Ubuntu/Debian
curl -O https://your-repo/install_ubuntu.sh
chmod +x install_ubuntu.sh
./install_ubuntu.sh

# For Fedora/RHEL/CentOS
curl -O https://your-repo/install_fedora.sh
chmod +x install_fedora.sh
./install_fedora.sh

# For Arch Linux
curl -O https://your-repo/install_arch.sh
chmod +x install_arch.sh
./install_arch.sh

# For openSUSE
curl -O https://your-repo/install_opensuse.sh
chmod +x install_opensuse.sh
./install_opensuse.sh
```

---

## 📦 What Gets Installed

### System Dependencies
- **Python 3.7+** with pip and virtualenv
- **Development tools** (gcc, make, build tools)
- **Tesseract OCR** with English and Polish language packs
- **Poppler utilities** for PDF processing
- **Cairo graphics library** for SVG rendering
- **Image libraries** (JPEG, PNG, TIFF, WebP)
- **Fonts** (Liberation, DejaVu)
- **Web browser** (Firefox) for dashboard viewing

### Python Packages (in virtual environment)
- `markdown==3.4.4` - Markdown processing
- `reportlab==4.0.4` - PDF generation
- `weasyprint==60.0` - HTML to PDF conversion
- `cairosvg==2.7.1` - SVG processing
- `Pillow==10.0.0` - Image manipulation
- `pytesseract==0.3.10` - OCR engine wrapper
- `pdf2image==3.1.0` - PDF to image conversion
- `beautifulsoup4==4.12.2` - XML/HTML parsing
- `lxml==4.9.3` - XML processing

---

## 🔧 Supported Distributions

### ✅ Tested and Supported

| Distribution Family | Versions | Package Manager |
|-------------------|----------|----------------|
| **Ubuntu** | 18.04, 20.04, 22.04, 24.04 | apt |
| **Debian** | 10, 11, 12 | apt |
| **Linux Mint** | 19, 20, 21 | apt |
| **Pop!_OS** | 20.04, 22.04 | apt |
| **Fedora** | 35, 36, 37, 38, 39 | dnf |
| **RHEL** | 8, 9 | dnf/yum |
| **CentOS** | 8, 9 | dnf/yum |
| **Rocky Linux** | 8, 9 | dnf/yum |
| **AlmaLinux** | 8, 9 | dnf/yum |
| **Arch Linux** | Rolling | pacman |
| **Manjaro** | Rolling | pacman |
| **EndeavourOS** | Rolling | pacman |
| **openSUSE Leap** | 15.3, 15.4, 15.5 | zypper |
| **openSUSE Tumbleweed** | Rolling | zypper |

---

## 📁 Installation Process

### Step 1: Download Script
```bash
# Universal installer (recommended)
wget https://raw.githubusercontent.com/your-repo/universal_installer.sh
chmod +x universal_installer.sh
```

### Step 2: Run Installation
```bash
./universal_installer.sh
```

### Step 3: Verify Installation
```bash
cd ~/document-processor
source venv/bin/activate
python test_environment.py
```

### Step 4: Download Project Files
```bash
# Download main project files
wget https://raw.githubusercontent.com/your-repo/Makefile
wget https://raw.githubusercontent.com/your-repo/processor.py
wget https://raw.githubusercontent.com/your-repo/README.md
```

### Step 5: Run Pipeline
```bash
make all
```

---

## 🛠️ Manual Installation (Advanced)

If automated scripts don't work, follow manual steps:

### 1. Install System Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv python3-dev \
    build-essential tesseract-ocr tesseract-ocr-eng tesseract-ocr-pol \
    poppler-utils libcairo2-dev libpango1.0-dev libffi-dev \
    libjpeg-dev libpng-dev fonts-liberation
```

**Fedora/RHEL:**
```bash
sudo dnf install -y python3 python3-pip python3-devel gcc gcc-c++ \
    tesseract tesseract-langpack-eng tesseract-langpack-pol \
    poppler-utils cairo-devel pango-devel libffi-devel \
    libjpeg-turbo-devel libpng-devel liberation-fonts
```

**Arch Linux:**
```bash
sudo pacman -S python python-pip base-devel tesseract tesseract-data-eng \
    tesseract-data-pol poppler cairo pango libffi libjpeg-turbo \
    libpng ttf-liberation
```

**openSUSE:**
```bash
sudo zypper install python3 python3-pip python3-devel gcc gcc-c++ \
    tesseract-ocr tesseract-ocr-traineddata-english \
    tesseract-ocr-traineddata-polish poppler-tools cairo-devel \
    pango-devel libffi-devel libjpeg8-devel libpng16-devel liberation-fonts
```

### 2. Create Virtual Environment
```bash
mkdir -p ~/document-processor
cd ~/document-processor
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Python Packages
```bash
pip install --upgrade pip
pip install markdown reportlab weasyprint cairosvg Pillow \
    pytesseract pdf2image beautifulsoup4 lxml
```

---

## 🧪 Testing Installation

### Quick Test
```bash
cd ~/document-processor
source venv/bin/activate
python test_environment.py
```

### System Information
```bash
./system_info.sh
```

### Expected Output
```
🎉 Environment setup successful!

✓ markdown
✓ reportlab
✓ weasyprint
✓ cairosvg
✓ PIL
✓ pytesseract
✓ pdf2image
✓ bs4
✓ lxml

✓ tesseract --version
✓ pdftoppm -h
✓ python --version
```

---

## 🔄 Project Usage After Installation

### 1. Activate Environment
```bash
cd ~/document-processor
source venv/bin/activate
# or
./activate_env.sh
```

### 2. Run Pipeline
```bash
# Complete pipeline
make all

# Step by step
make create     # Create example
make process    # Convert documents
make aggregate  # Create dashboard
```

### 3. View Results
- Dashboard opens automatically in browser
- Files created in `output/` directory
- Interactive SVG thumbnails and metadata

---

## 🚨 Troubleshooting

### Common Issues and Solutions

**1. Permission Denied**
```bash
# Fix: Run as regular user, not root
sudo chown -R $USER:$USER ~/document-processor
```

**2. Package Installation Fails**
```bash
# Fix: Update package manager
sudo apt update        # Ubuntu/Debian
sudo dnf update        # Fedora/RHEL
sudo pacman -Syu       # Arch
sudo zypper update     # openSUSE
```

**3. Python Import Errors**
```bash
# Fix: Reinstall in virtual environment
source venv/bin/activate
pip install --upgrade --force-reinstall [package-name]
```

**4. OCR Not Working**
```bash
# Fix: Check tesseract installation
tesseract --version
sudo apt-get install tesseract-ocr-eng  # Install English
```

**5. PDF Conversion Fails**
```bash
# Fix: Install additional dependencies
sudo apt-get install libpango1.0-dev libcairo2-dev
pip install --upgrade weasyprint
```

**6. Virtual Environment Issues**
```bash
# Fix: Recreate virtual environment
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## 🔍 Verification Commands

### Check System Dependencies
```bash
python3 --version          # Python 3.7+
tesseract --version        # Tesseract 4.0+
pdftoppm -v               # Poppler utilities
pkg-config --modversion cairo  # Cairo library
```

### Check Python Packages
```bash
source venv/bin/activate
pip list | grep -E "(markdown|weasyprint|tesseract|cairo)"
```

### Test Complete Pipeline
```bash
make create && make process && make aggregate
```

---

## 📞 Support and Help

### Getting Help
1. **Run diagnostics**: `python test_environment.py`
2. **Check system info**: `./system_info.sh`
3. **View logs**: Check terminal output during installation
4. **Reinstall**: Re-run the appropriate installer script

### Contact Information
- **Issues**: GitHub Issues
- **Documentation**: README.md files
- **Examples**: Check `output/` directory after successful run

---

## 🎯 Quick Reference

### File Locations
```
~/document-processor/
├── venv/                    # Virtual environment
├── requirements.txt         # Python dependencies
├── test_environment.py      # Environment test
├── activate_env.sh          # Activation script
├── system_info.sh           # System information
├── Makefile                 # Build automation
├── processor.py             # Main processing script
└── output/                  # Generated files
    ├── *.md, *.pdf, *.svg   # Processed documents
    ├── *.png                # Extracted images
    ├── *.json               # Metadata files
    └── dashboard.html       # Interactive dashboard
```

### Essential Commands
```bash
# Environment
source venv/bin/activate     # Activate
deactivate                   # Deactivate

# Pipeline
make all                     # Complete pipeline
make help                    # Show all targets

# Testing
python test_environment.py   # Test setup
./system_info.sh            # System info
```

---

## 🎉 Success Indicators

When installation is successful, you should see:

✅ **All system packages installed**
✅ **Virtual environment created**
✅ **Python packages installed**
✅ **Environment test passes**
✅ **Desktop shortcut created**
✅ **Ready for document processing**

The pipeline is ready when you can run `make all` and see the dashboard open in your browser with processed documents and interactive thumbnails!