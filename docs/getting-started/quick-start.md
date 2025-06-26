# Quick Start Guide

This guide will help you quickly get started with Enclose by walking you through the basic workflow of processing documents.

## Basic Workflow

Enclose processes documents through the following pipeline:

```mermaid
graph LR
    A[Markdown] --> B[PDF]
    B --> C[SVG]
    C --> D[PNG]
    D --> E[OCR]
    E --> F[Search Index]
    F --> G[Dashboard]
```

## Step 1: Create an Example Document

Generate a sample markdown document to get started:

```bash
# Create an example markdown file
cat > example.md << 'EOL'
# Sample Document

This is a sample markdown document for testing Enclose.

## Features

- Markdown to PDF conversion
- PDF to SVG embedding
- Image extraction
- OCR processing

```

## Step 2: Process the Document

Use the `enclose` command to process your document:

```bash
# Process the document through the entire pipeline
enclose process example.md -o output/
```

This will create the following directory structure:

```
output/
├── example.pdf
├── example.svg
├── page_1.png
├── ocr_results.json
└── dashboard.html
```

## Step 3: View the Results

### View the Dashboard

Open the generated dashboard in your default browser:

```bash
# On macOS
open output/dashboard.html

# On Linux
xdg-open output/dashboard.html

# On Windows (PowerShell)
Start-Process output/dashboard.html
```

### View Individual Files

- **PDF**: `output/example.pdf` - The generated PDF document
- **SVG**: `output/example.svg` - PDF embedded in an SVG container
- **PNG**: `output/page_1.png` - Extracted page as an image
- **OCR**: `output/ocr_results.json` - Extracted text with confidence scores

## Step 4: Search Processed Documents

Search through your processed documents:

```bash
# Search for documents containing specific text
enclose search "sample document"
```

## Example Commands

### Process a Single File

```bash
enclose process input.md -o output/
```

### Process a Directory

```bash
enclose process documents/ -o processed/
```

### Convert to Specific Formats

```bash
# Convert only to PDF
enclose process input.md --format pdf -o output/


# Convert to PDF and PNG
enclose process input.md --format pdf,png -o output/
```

### View Help

```bash
# Show all available commands
enclose --help

# Show help for a specific command
enclose process --help
```

## Next Steps

- Learn more about [configuration options](configuration.md)
- Explore the [command line interface](usage/cli.md)
- Check out more [examples](../examples/)
- Read about the [system architecture](../architecture/overview.md)
