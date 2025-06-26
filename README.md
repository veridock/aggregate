# Enclose

A comprehensive document processing pipeline for Markdown to PDF/SVG/PNG conversion with OCR capabilities.

```mermaid
graph LR
    A[Markdown] -->|Parse| B[HTML]
    B -->|Convert| C[PDF]
    C -->|Embed| D[SVG]
    D -->|Extract| E[PNG]
    E -->|Process| F[OCR]
    F -->|Index| G[Search]
    G -->|Visualize| H[Dashboard]
```

## 🚀 Features

- **Multi-format conversion**: Markdown to PDF with styling
- **SVG embedding**: PDF embedded as base64 data URI in SVG containers
- **Image extraction**: PDF pages converted to PNG with base64 encoding
- **OCR processing**: Text extraction with confidence scoring
- **Metadata tracking**: JSON metadata throughout the pipeline
- **Interactive dashboard**: View and search processed documents

## 📚 Documentation

For complete documentation, please visit our [documentation site](docs/index.md).

## 🛠️ Quick Start

### Prerequisites

- Python 3.8.1+
- [Poetry](https://python-poetry.org/) for dependency management
- System dependencies (see [Installation Guide](docs/getting-started/installation.md))

### Installation

```bash
# Clone the repository
git clone https://github.com/veridock/enclose.git
cd enclose

# Install the package
make install
```

### Basic Usage

```bash
# Process a document
enclose process example.md -o output/

# View the results
open output/dashboard.html  # macOS
# or
xdg-open output/dashboard.html  # Linux
```

## 📖 Documentation Structure

- [Getting Started](docs/getting-started/installation.md) - Installation and setup
- [User Guide](docs/usage/cli.md) - Command reference and usage examples
- [Architecture](docs/architecture/overview.md) - System design and components
- [Development](development/setup.md) - Contributing and development setup

## 🌟 Features in Detail

### Document Conversion
- Markdown to PDF with custom styling
- PDF to SVG with embedded fonts
- High-quality image extraction

### Advanced Processing
- OCR text extraction with confidence scoring
- Metadata extraction and management
- Batch processing support

### Command Line Interface
- Intuitive command structure
- Configurable output formats
- Progress tracking

## 📊 Example Workflow

```mermaid
sequenceDiagram
    participant User
    participant CLI
    participant Processor
    
    User->>CLI: enclose process doc.md
    CLI->>Processor: Process document
    Processor->>Processor: Convert Markdown to PDF
    Processor->>Processor: Generate SVG with embedded PDF
    Processor->>Processor: Extract images
    Processor->>Processor: Process OCR
    Processor-->>CLI: Processing complete
    CLI-->>User: Results in output/
```

## 📦 Project Structure

```
enclose/
├── docs/                   # Documentation
├── processor/              # Main package
│   ├── __init__.py
│   ├── __main__.py         # CLI entry point
│   ├── core/               # Core processing logic
│   ├── converters/         # Format converters
│   └── utils/              # Utility functions
├── scripts/                # Helper scripts
├── tests/                  # Test suite
└── pyproject.toml          # Project configuration
```

## 🤝 Contributing

Contributions are welcome! Please see our [Contributing Guide](docs/development/contributing.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🧪 Testing

To run the test suite:

```bash
make test
make lint
```

## 🔄 Development Workflow

1. **Set up development environment**
   ```bash
   make install
   ```

2. **Run tests**
   ```bash
   make test
   ```

3. **Format and check code**
   ```bash
   make format
   make lint
   ```

4. **Run the development server**
   ```bash
   make dev
   ```
   - Dashboard opens automatically in browser
   - Access: `output/dashboard.html`

## 🛠️ CLI Commands

```bash
# Process a document
enclose process input.md -o output/

# List supported formats
enclose --list
# Show help
enclose --help
```

## 📁 Project Structure

```
enclose/
├── Makefile                 # Build automation
├── pyproject.toml          # Project configuration and dependencies
├── README.md               # Project documentation
├── scripts/
│   └── enclose            # Global CLI wrapper script
├── processor/              # Main package
│   ├── __init__.py
│   ├── __main__.py         # CLI entry point
│   ├── core/               # Core processing logic
│   ├── converters/         # File format converters
│   └── utils/              # Utility functions
└── output/                 # Generated files (created on first run)
    ├── example.md          # Example markdown
    ├── example.pdf         # Generated PDF
    ├── example.svg         # SVG with embedded PDF
    ├── page_1.png         # Extracted PNG pages
    ├── metadata.json       # Processing metadata
    └── dashboard.html      # Interactive dashboard
```

## 🔄 Pipeline Workflow

```
Step 1: CREATE
├── Generate example markdown file (invoice)
└── Output: invoice_example.md

Step 2: MARKDOWN → PDF
├── Convert markdown to styled HTML
├── Generate PDF with CSS styling
└── Output: invoice_example.pdf

Step 3: PDF → SVG
├── Embed PDF as base64 data URI
├── Add SVG metadata (RDF/Dublin Core)
└── Output: invoice_example.svg + metadata.json

Step 4: PDF → PNG
├── Extract PDF pages as PNG images
├── Convert PNG to base64 encoding
└── Output: page_*.png + updated metadata

Step 5: OCR PROCESSING
├── Extract text from PNG images
├── Calculate confidence scores
└── Output: updated metadata with OCR data

Step 6: FILESYSTEM SEARCH
├── Scan for all SVG files
├── Parse SVG metadata
└── Output: svg_search_results.json

Step 7: DASHBOARD CREATION
├── Generate HTML table with thumbnails
├── Embed SVG previews
└── Output: dashboard.html (opens in browser)
```

## 📊 Output Files

### Metadata Structure
```json
{
  "file": "path/to/file.svg",
  "type": "svg_with_pdf",
  "created": "2025-06-25T10:30:00",
  "pdf_embedded": true,
  "total_pages": 1,
  "pages": [
    {
      "page": 1,
      "file": "page_1.png",
      "base64": "iVBORw0KGgoAAAANSU...",
      "ocr_text": "Invoice #INV-2025-001...",
      "ocr_confidence": 95.7,
      "word_count": 45
    }
  ]
}
```

### Dashboard Features
- **SVG Thumbnails**: Direct embedding of SVG files
- **File Information**: Path, size, modification date
- **PDF Detection**: Indicates embedded PDF data
- **Metadata Status**: Shows RDF metadata presence
- **Interactive Links**: Click to open files

## 🛠️ Makefile Targets

| Target | Description |
|--------|-------------|
| `install` | Install dependencies in virtual environment |
| `create` | Create example markdown file |
| `process` | Run conversion pipeline (steps 2-5) |
| `search` | Search filesystem for SVG files |
| `enclose` | Create HTML dashboard |
| `clean` | Remove generated files |
| `clean-all` | Remove everything including venv |
| `help` | Show available commands |

## 🔧 Configuration

### OCR Language Support
```bash
# Install additional languages
sudo apt-get install tesseract-ocr-pol  # Polish
sudo apt-get install tesseract-ocr-deu  # German

# Configure in processor.py
pytesseract.image_to_string(image, lang='pol+eng')
```

### PDF Styling
Modify CSS in `markdown_to_pdf()` method:
```python
styled_html = f"""
<style>
    body {{ font-family: 'Your Font', sans-serif; }}
    /* Add custom styles */
</style>
"""
```

## 🐛 Troubleshooting

### Common Issues

**OCR Not Working:**
```bash
# Check tesseract installation
tesseract --version

# Install language packs
sudo apt-get install tesseract-ocr-eng
```

**PDF Conversion Fails:**
```bash
# Check weasyprint dependencies
pip install --upgrade weasyprint
```

**SVG Rendering Issues:**
```bash
# Install cairo development libraries
sudo apt-get install libcairo2-dev
```

### Debug Mode
```bash
# Enable verbose output
python processor.py --step process --verbose
```

## 📝 License

This project is open source. See LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📞 Support

- **Issues**: GitHub Issues
- **Documentation**: This README
- **Examples**: Check `output/` directory after running pipeline

---

## 🎉 Quick Demo

```bash
# Complete setup and demo
make install
make all

# View results
open output/dashboard.html  # macOS
xdg-open output/dashboard.html  # Linux
```

The dashboard will show your processed documents with interactive thumbnails and metadata!