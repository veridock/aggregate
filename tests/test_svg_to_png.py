"""Test SVG to PNG conversion."""

import io
import tempfile
import imghdr
from pathlib import Path

import pytest
from PIL import Image

from enclose.converters.pdf_converter import svg_to_png


def create_test_svg(temp_dir: Path) -> Path:
    """Create a test SVG file for conversion testing."""
    svg_content = """<?xml version="1.0" encoding="UTF-8"?>
    <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
        <rect width="100" height="100" fill="red" />
    </svg>"""
    
    svg_path = temp_dir / "test.svg"
    svg_path.write_text(svg_content, encoding='utf-8')
    return svg_path


def test_svg_to_png_conversion():
    """Test that SVG is correctly converted to PNG."""
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_dir_path = Path(temp_dir)
        
        # Create test SVG
        svg_path = create_test_svg(temp_dir_path)
        
        # Test conversion
        output_dir = temp_dir_path / "output"
        output_dir.mkdir()
        
        # Convert SVG to PNG
        page_info, _ = svg_to_png(
            svg_file=svg_path,
            metadata={"test": "data"},
            output_dir=output_dir
        )
        
        # Check results
        assert len(page_info) == 1
        assert "file" in page_info[0]
        assert "width" in page_info[0]
        assert "height" in page_info[0]
        
        output_path = Path(page_info[0]["file"])
        assert output_path.exists()
        assert output_path.suffix.lower() == ".png"
        
        # Verify it's a valid PNG file
        with open(output_path, 'rb') as f:
            # Check PNG signature
            header = f.read(8)
            assert header.startswith(b'\x89PNG\r\n\x1a\x0a')  # PNG file signature
            
            # Verify MIME type
            f.seek(0)
            mime_type = imghdr.what(f)
            assert mime_type == 'png', f"Expected PNG, got {mime_type}"
            
            # Verify it can be opened as an image
            f.seek(0)
            try:
                with Image.open(io.BytesIO(f.read())) as img:
                    img.verify()  # Verify image data is not corrupted
                    assert img.format == 'PNG', f"Expected PNG format, got {img.format}"
            except Exception as e:
                pytest.fail(f"Failed to open as PNG image: {e}")


if __name__ == "__main__":
    test_svg_to_png_conversion()
    print("All tests passed!")
