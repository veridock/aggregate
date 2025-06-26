"""Test file format and MIME type validation for converted files."""

import io
import mimetypes
from pathlib import Path

import pytest
from PIL import Image


def validate_image_format(file_path: Path, expected_format: str) -> None:
    """Validate that the file is a valid image of the expected format."""
    try:
        with Image.open(file_path) as img:
            # Verify the image can be loaded and matches expected format
            img.verify()
            assert img.format == expected_format.upper(), \
                f"Expected {expected_format.upper()} format, got {img.format}"
    except Exception as e:
        pytest.fail(f"Failed to validate {file_path} as {expected_format}: {str(e)}")


def validate_mime_type(file_path: Path, expected_mime: str) -> None:
    """Validate that the file's MIME type matches expected."""
    mime, _ = mimetypes.guess_type(file_path)
    assert mime == expected_mime, f"Expected MIME type {expected_mime}, got {mime}"


def test_pdf_conversion(example_markdown_file, temp_output_dir):
    """Test that PDF conversion produces valid PDF files."""
    from enclose.converters.markdown_converter import markdown_to_pdf
    
    # Convert markdown to PDF (returns a string path)
    pdf_path_str = markdown_to_pdf(example_markdown_file, temp_output_dir)
    pdf_path = Path(pdf_path_str)  # Convert to Path object
    
    # Check file exists and has content
    assert pdf_path.exists()
    assert pdf_path.stat().st_size > 0
    
    # Validate MIME type
    validate_mime_type(pdf_path, 'application/pdf')
    
    # Basic PDF validation (first 4 bytes should be '%PDF')
    with open(pdf_path, 'rb') as f:
        header = f.read(4)
        assert header == b'%PDF', "Not a valid PDF file"


def test_svg_conversion(example_markdown_file, temp_output_dir):
    """Test that SVG conversion produces valid SVG files."""
    from enclose.converters.markdown_converter import markdown_to_pdf
    from enclose.converters.pdf_converter import pdf_to_svg
    
    # First create a PDF
    pdf_path = markdown_to_pdf(example_markdown_file, temp_output_dir)
    
    # Convert PDF to SVG
    svg_path, _ = pdf_to_svg(pdf_path, temp_output_dir)
    
    # Check file exists and has content
    assert svg_path.exists()
    assert svg_path.stat().st_size > 0
    
    # Validate MIME type
    validate_mime_type(svg_path, 'image/svg+xml')
    
    # Basic SVG validation (should start with '<?xml' or '<svg')
    with open(svg_path, 'rb') as f:
        content = f.read(100).decode('utf-8', 'ignore').lower()
        assert content.startswith('<?xml') or content.lstrip().startswith('<svg'), \
            "Not a valid SVG file"


def test_png_conversion(example_markdown_file, temp_output_dir):
    """Test that PNG conversion produces valid PNG files."""
    from enclose.converters.markdown_converter import markdown_to_pdf
    from enclose.converters.pdf_converter import pdf_to_svg, svg_to_png
    
    # First create a PDF and SVG
    pdf_path = markdown_to_pdf(example_markdown_file, temp_output_dir)
    svg_path, metadata = pdf_to_svg(pdf_path, temp_output_dir)
    
    # Convert SVG to PNG
    page_info, _ = svg_to_png(svg_path, metadata, temp_output_dir)
    
    # Check PNG file was created
    assert len(page_info) > 0
    png_path = Path(page_info[0]["file"])
    
    # Check file exists and has content
    assert png_path.exists()
    assert png_path.stat().st_size > 0
    
    # Validate MIME type
    validate_mime_type(png_path, 'image/png')
    
    # Validate image format and integrity
    validate_image_format(png_path, 'PNG')
    
    # Additional PNG signature check
    with open(png_path, 'rb') as f:
        header = f.read(8)
        assert header.startswith(b'\x89PNG\r\n\x1a\x0a'), "Not a valid PNG file"
