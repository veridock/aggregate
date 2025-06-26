# Installation Guide

This guide will help you install Enclose and its dependencies on your system.

## Prerequisites

- Python 3.8.1 or higher
- [Poetry](https://python-poetry.org/) for dependency management
- System dependencies (see below)

## System Dependencies

### Ubuntu/Debian

```bash
sudo apt-get update
sudo apt-get install -y tesseract-ocr poppler-utils libcairo2-dev
```

### macOS

```bash
brew install tesseract poppler cairo
```

### Windows

1. Install [Tesseract OCR](https://github.com/tesseract-ocr/tesseract)
2. Install [Poppler](https://poppler.freedesktop.org/)
3. Add both to your system PATH

## Installation Methods

### Using Make (Recommended)

```bash
# Clone the repository
git clone https://github.com/veridock/enclose.git
cd enclose

# Install the package in development mode
make install
```

### Using Poetry Directly

```bash
# Install dependencies
poetry install

# Activate the virtual environment
poetry shell
```

## Verify Installation

Run the following command to verify the installation:

```bash
enclose --version
```

You should see the version number of the installed package.

## Updating

To update to the latest version:

```bash
git pull origin main
make install
```

## Troubleshooting

### Common Issues

1. **Missing Dependencies**
   - Ensure all system dependencies are installed
   - On Linux, you might need to install additional development packages

2. **Python Version Mismatch**
   - Verify you're using Python 3.8.1 or higher
   - Check with `python --version`

3. **Permission Issues**
   - On Linux/macOS, you might need to use `sudo` for system installations
   - For Python packages, consider using `--user` flag or a virtual environment

### Getting Help

If you encounter any issues, please:
1. Check the [GitHub Issues](https://github.com/veridock/enclose/issues)
2. Search the [Discussions](https://github.com/veridock/enclose/discussions)
3. Open a new issue if your problem isn't already reported
