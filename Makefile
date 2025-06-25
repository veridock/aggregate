# Document Processing Pipeline Makefile
# Handles: Markdown → PDF → SVG → PNG → OCR → Search → Aggregation

PYTHON = python3
PIP = pip3
VENV = venv
ACTIVATE = $(VENV)/bin/activate

# Default target
.PHONY: all
all: install create process aggregate search

# Install all required dependencies
.PHONY: install
install: $(VENV)/bin/activate
	@echo "Installing dependencies..."
	. $(ACTIVATE) && $(PIP) install --upgrade pip
	. $(ACTIVATE) && $(PIP) install markdown reportlab weasyprint
	. $(ACTIVATE) && $(PIP) install cairosvg pillow pytesseract
	. $(ACTIVATE) && $(PIP) install pdf2image beautifulsoup4 lxml
	@echo "Dependencies installed successfully!"

# Create virtual environment
$(VENV)/bin/activate:
	@echo "Creating virtual environment..."
	$(PYTHON) -m venv $(VENV)

# Create example files
.PHONY: create
create:
	@echo "Creating example markdown file..."
	. $(ACTIVATE) && $(PYTHON) processor.py --step create
	@echo "Example files created!"

# Process documents through the pipeline
.PHONY: process
process:
	@echo "Processing documents through pipeline..."
	. $(ACTIVATE) && $(PYTHON) processor.py --step process
	@echo "Processing completed!"

# Aggregate results
.PHONY: aggregate
aggregate:
	@echo "Aggregating results..."
	. $(ACTIVATE) && $(PYTHON) processor.py --step aggregate
	@echo "Aggregation completed!"

# Search metadata
.PHONY: search
search:
	@echo "Searching metadata..."
	. $(ACTIVATE) && $(PYTHON) processor.py --step search
	@echo "Search completed!"

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	rm -f *.pdf *.svg *.png *.json *.html
	rm -rf output/
	@echo "Cleanup completed!"

# Clean everything including virtual environment
.PHONY: clean-all
clean-all: clean
	@echo "Removing virtual environment..."
	rm -rf $(VENV)/
	@echo "Full cleanup completed!"

# Help target
.PHONY: help
help:
	@echo "Document Processing Pipeline"
	@echo "Available targets:"
	@echo "  install   - Install all dependencies"
	@echo "  create    - Create example markdown file"
	@echo "  process   - Process documents through pipeline"
	@echo "  aggregate - Aggregate results into HTML table"
	@echo "  search    - Search metadata in filesystem"
	@echo "  clean     - Remove generated files"
	@echo "  clean-all - Remove everything including venv"
	@echo "  help      - Show this help message"