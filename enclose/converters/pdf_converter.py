"""PDF conversion utilities."""

import base64
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Tuple
from typing_extensions import TypedDict

from pdf2image import convert_from_path


def pdf_to_svg(pdf_file: Path, output_dir: Path) -> Tuple[Path, Dict[str, Any]]:
    """Convert PDF to SVG with embedded data and metadata.
    
    Args:
        pdf_file: Path to the input PDF file
        output_dir: Directory to save the output SVG
        
    Returns:
        Tuple of (output_svg_path, metadata_dict)
    """
    # Ensure output directory exists
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Create output path
    output_path = output_dir / f"{pdf_file.stem}.svg"
    
    # Read PDF as base64
    with open(pdf_file, 'rb') as f:
        pdf_data = base64.b64encode(f.read()).decode('utf-8')

    # Create metadata
    metadata = {
        "file": str(output_path),
        "pdf_embedded": True,
        "pages": []
    }
    
    # Create SVG with embedded PDF data
    svg_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     width="800" height="1000" viewBox="0 0 800 1000">

    <!-- Metadata -->
    <metadata>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:dc="http://purl.org/dc/elements/1.1/">
            <rdf:Description rdf:about="">
                <dc:title>PDF Document</dc:title>
                <dc:creator>Enclose Document Processor</dc:creator>
                <dc:date>{datetime.now().isoformat()}</dc:date>
                <dc:description>PDF embedded in SVG container</dc:description>
            </rdf:Description>
        </rdf:RDF>
    </metadata>

    <!-- Background -->
    <rect width="100%" height="100%" fill="white"/>

    <!-- PDF Data (base64 encoded) -->
    <foreignObject width="100%" height="100%">
        <div xmlns="http://www.w3.org/1999/xhtml">
            <embed src="data:application/pdf;base64,{pdf_data}"
                   width="100%" height="100%" type="application/pdf"/>
        </div>
    </foreignObject>

    <!-- Visual representation -->
    <text x="50" y="50" font-family="Arial" font-size="24" fill="black">
        PDF Document
    </text>
    <rect x="50" y="70" width="700" height="2" fill="#333"/>
    <text x="50" y="120" font-family="Arial" font-size="16" fill="gray">
        PDF content embedded as data URI
    </text>
</svg>"""

    # Write SVG to file
    output_path.write_text(svg_content, encoding='utf-8')
    print(f"Created: {output_path}")
    return output_path, metadata


class PageInfo(TypedDict):
    page: int
    file: str
    width: int
    height: int


def svg_to_png(
    svg_file: Path, 
    metadata: Dict[str, Any], 
    output_dir: Path
) -> Tuple[List[PageInfo], Dict[str, Any]]:
    """Convert SVG with embedded PDF to PNG images.
    
    Args:
        svg_file: Path to the input SVG file
        metadata: Metadata from the PDF to SVG conversion
        output_dir: Directory to save the output PNG files
        
    Returns:
        Tuple of (list of page info dicts, updated metadata)
    """
    # Ensure output directory exists
    output_dir.mkdir(parents=True, exist_ok=True)
    
    try:
        # Convert PDF to images (one per page) using pdf2image
        images = convert_from_path(
            str(svg_file),
            output_folder=str(output_dir),
            fmt='png',
            output_file=svg_file.stem,
            paths_only=True
        )
        
        # Update metadata with page information
        pages: List[PageInfo] = []
        for i, img_path in enumerate(images, 1):
            page_info: PageInfo = {
                'page': i,
                'file': str(img_path) if isinstance(img_path, Path) else str(img_path),
                'width': 800,  # Default width
                'height': 1000  # Default height
            }
            pages.append(page_info)
        
        metadata['pages'] = pages
        return pages, metadata
        
    except Exception as e:
        print(f"Error converting SVG to PNG: {e}")
        # Return empty pages list on error
        return [], metadata
