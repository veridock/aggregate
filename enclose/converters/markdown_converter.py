"""
Markdown conversion utilities.
"""

from pathlib import Path
import markdown
from weasyprint import HTML


def create_example_markdown(output_dir):
    """Create an example markdown file."""
    markdown_content = """# Invoice Example

## Invoice #INV-2025-001

**Date:** June 25, 2025  
**Due Date:** July 25, 2025

### Bill To:
**Customer Name:** John Smith  
**Address:** 123 Main Street  
**City:** New York, NY 10001

### Services Provided:

| Item | Description | Quantity | Rate | Amount |
|------|-------------|----------|------|--------|
| 1 | Web Development | 40 hrs | $100/hr | $4,000 |
| 2 | Design Services | 20 hrs | $80/hr | $1,600 |
| 3 | Consultation | 10 hrs | $120/hr | $1,200 |

### Summary:
- **Subtotal:** $6,800
- **Tax (8.5%):** $578
- **Total:** $7,378

### Payment Terms:
Payment is due within 30 days of invoice date.

### Notes:
Thank you for your business!
"""

    file_path = output_dir / "invoice_example.md"
    with open(file_path, 'w') as f:
        f.write(markdown_content)

    print(f"Created: {file_path}")
    return file_path


def markdown_to_pdf(md_file, output_dir, output_file=None):
    """Convert markdown to PDF.
    
    Args:
        md_file: Path or string to the input markdown file
        output_dir: Directory to save the output PDF
        output_file: Optional output filename (without extension)
        
    Returns:
        Path to the generated PDF file
    """
    # Convert string paths to Path objects
    md_file = Path(md_file) if not isinstance(md_file, Path) else md_file
    output_dir = Path(output_dir) if not isinstance(output_dir, Path) else output_dir
    
    # Ensure output directory exists
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Determine output filename
    if output_file is None:
        output_file = md_file.stem
    if not output_file.endswith('.pdf'):
        output_file = f"{output_file}.pdf"
    
    pdf_path = output_dir / output_file
    
    try:
        # Read markdown content
        with open(md_file, 'r', encoding='utf-8') as f:
            md_content = f.read()

        # Convert markdown to HTML
        html_content = markdown.markdown(md_content, extensions=['tables'])

        # Add CSS styling
        styled_html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                body {{ 
                    font-family: Arial, sans-serif; 
                    margin: 40px;
                    line-height: 1.6;
                }}
                table {{ 
                    border-collapse: collapse; 
                    width: 100%; 
                    margin: 20px 0; 
                }}
                th, td {{ 
                    border: 1px solid #ddd; 
                    padding: 12px; 
                    text-align: left; 
                }}
                th {{ 
                    background-color: #f2f2f2; 
                    font-weight: bold;
                }}
                h1, h2, h3, h4, h5, h6 {{ 
                    color: #333;
                    margin-top: 1.5em;
                }}
                h1 {{ font-size: 2em; }}
                h2 {{ font-size: 1.5em; }}
                h3 {{ font-size: 1.3em; }}
                code {{
                    background: #f4f4f4;
                    padding: 2px 5px;
                    border-radius: 3px;
                    font-family: monospace;
                }}
                pre {{
                    background: #f4f4f4;
                    padding: 15px;
                    border-radius: 3px;
                    overflow-x: auto;
                }}
                blockquote {{
                    border-left: 4px solid #ddd;
                    margin: 1.5em 0;
                    padding: 0.5em 1em;
                    color: #666;
                }}
            </style>
        </head>
        <body>
        {html_content}
        </body>
        </html>
        """

        # Generate PDF
        HTML(string=styled_html).write_pdf(pdf_path)
        
        print(f"Created: {pdf_path}")
        return str(pdf_path)
        
    except Exception as e:
        print(f"Error converting {md_file} to PDF: {str(e)}")
        raise
