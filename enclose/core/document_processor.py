"""
Document Processor Module

This module provides the DocumentProcessor class which handles the document processing pipeline
for converting between different document formats with OCR support.
"""
from typing import Optional, Union, Dict, Any, List
import os
import json
import webbrowser
from pathlib import Path
from datetime import datetime

from ..converters.markdown_converter import create_example_markdown, markdown_to_pdf
from ..converters.pdf_converter import pdf_to_svg, svg_to_png
from ..utils.ocr_processor import process_ocr
from ..utils.file_utils import search_svg_files
from ..utils.html_utils import enclose_to_html_table
from ..utils.metadata_utils import save_metadata


class DocumentProcessor:
    """
    A class to handle document processing operations including format conversion.
    
    This class provides methods to process documents through various stages
    of the conversion pipeline, including markdown to PDF, PDF to SVG,
    SVG to PNG, and OCR processing.
    """
    
    def __init__(self, output_dir: str = "output") -> None:
        """
        Initialize the DocumentProcessor with default settings.
        
        Args:
            output_dir: Directory to store output files (default: 'output')
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        self.metadata: Dict[str, Any] = {}
        self.supported_formats = ['md', 'html', 'pdf', 'svg', 'png']
        self.default_output_dir = str(self.output_dir)
    
    def process(self, input_path: Union[str, Path], 
               output_format: str, 
               output_path: Optional[Union[str, Path]] = None) -> str:
        """
        Process the input document and convert it to the specified output format.
        
        Args:
            input_path: Path to the input file
            output_format: Desired output format (e.g., 'pdf', 'png', 'svg')
            output_path: Optional output path (defaults to input filename with new extension)
            
        Returns:
            Path to the generated output file
            
        Raises:
            ValueError: If the input format or output format is not supported
            FileNotFoundError: If the input file does not exist
            RuntimeError: If the conversion fails
        """
        input_path = Path(input_path)
        if not input_path.exists():
            raise FileNotFoundError(f"Input file not found: {input_path}")
            
        input_format = input_path.suffix[1:].lower()
        if input_format not in self.supported_formats:
            raise ValueError(f"Unsupported input format: {input_format}")
            
        if output_format.lower() not in self.supported_formats:
            raise ValueError(f"Unsupported output format: {output_format}")
            
        # Set up output path
        if output_path is None:
            output_dir = Path(self.default_output_dir)
            output_filename = f"{input_path.stem}.{output_format}"
            output_path = output_dir / output_filename
        else:
            output_path = Path(output_path)
            output_dir = output_path.parent
            output_filename = output_path.name
        
        # Ensure output directory exists
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Handle different conversion paths
        try:
            if input_format == 'md' and output_format == 'pdf':
                return self.markdown_to_pdf(input_path, output_path)
            elif input_format == 'pdf' and output_format == 'svg':
                return self.pdf_to_svg(input_path, output_path)
            elif input_format == 'svg' and output_format == 'png':
                return self.svg_to_png(input_path, output_path)
            else:
                # For unsupported conversions, use a generic approach
                return self._generic_conversion(input_path, output_path, output_format)
                
        except Exception as e:
            raise RuntimeError(f"Failed to convert {input_path} to {output_format}: {str(e)}")
    
    def create_example_markdown(self) -> Path:
        """Create an example markdown file."""
        return Path(create_example_markdown(self.output_dir))

    def markdown_to_pdf(self, md_file: Union[str, Path], output_path: Optional[Union[str, Path]] = None) -> str:
        """
        Convert markdown to PDF.
        
        Args:
            md_file: Path to the markdown file
            output_path: Optional output path for the PDF
            
        Returns:
            Path to the generated PDF file
        """
        md_file = Path(md_file)
        if output_path is None:
            output_dir = Path(self.default_output_dir)
            output_filename = f"{md_file.stem}.pdf"
            output_path = output_dir / output_filename
        else:
            output_path = Path(output_path)
            output_dir = output_path.parent
            output_filename = output_path.name
        
        # Ensure output directory exists
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Use the markdown_to_pdf function from converters
        return markdown_to_pdf(str(md_file), str(output_dir), output_filename)

    def pdf_to_svg(self, pdf_file: Union[str, Path]) -> tuple[str, Dict[str, Any]]:
        """Convert PDF to SVG with embedded data and metadata."""
        svg_path, metadata = pdf_to_svg(str(pdf_file), self.output_dir)
        self.metadata.update(metadata)
        return svg_path, self.metadata

    def svg_to_png(self, svg_file: Union[str, Path], 
                  metadata: Dict[str, Any]) -> tuple[List[str], Dict[str, Any]]:
        """Convert embedded PDF to PNG and update metadata."""
        png_files, metadata = svg_to_png(str(svg_file), metadata, self.output_dir)
        self.metadata.update(metadata)
        return png_files, self.metadata

    def process_ocr(self, png_files: List[Union[str, Path]], 
                   metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Process PNG files with OCR and update metadata."""
        updated_metadata = process_ocr([str(f) for f in png_files], metadata)
        self.metadata.update(updated_metadata)
        return self.metadata
    
    def get_supported_formats(self) -> Dict[str, Any]:
        """
        Get information about supported formats and conversions.
        
        Returns:
            Dictionary containing information about supported formats
        """
        return {
            'input_formats': self.supported_formats,
            'output_formats': self.supported_formats,
            'conversions': {
                'md': ['html', 'pdf', 'svg', 'png'],
                'html': ['pdf', 'svg', 'png'],
                'pdf': ['svg', 'png'],
                'svg': ['png']
            }
        }
    
    def save_metadata(self, output_file: Optional[Union[str, Path]] = None) -> str:
        """
        Save the current metadata to a JSON file.
        
        Args:
            output_file: Path to the output file (default: metadata_<timestamp>.json)
            
        Returns:
            Path to the saved metadata file
        """
        if not output_file:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_file = self.output_dir / f"metadata_{timestamp}.json"
        
        with open(output_file, 'w') as f:
            json.dump(self.metadata, f, indent=2)
            
        return str(output_file)
    
    def enclose_to_html_table(self, svg_files: List[Union[str, Path]]) -> str:
        """
        Convert a list of SVG files to an HTML table.
        
        Args:
            svg_files: List of paths to SVG files
            
        Returns:
            Path to the generated HTML file
        """
        return enclose_to_html_table([str(f) for f in svg_files], self.output_dir)

    def _generic_conversion(self, input_path: Path, output_path: Path, output_format: str) -> str:
        """
        Handle generic file conversion between formats.
        
        This is a fallback method for conversions that don't have a specific handler.
        
        Args:
            input_path: Path to the input file
            output_path: Path where the output should be saved
            output_format: Target output format
            
        Returns:
            Path to the generated output file
            
        Raises:
            RuntimeError: If the conversion is not supported
        """
        # For now, just copy the file and change the extension
        # This is a placeholder and should be replaced with actual conversion logic
        try:
            with open(input_path, 'rb') as src, open(output_path, 'wb') as dst:
                dst.write(src.read())
            return str(output_path)
        except Exception as e:
            raise RuntimeError(
                f"Conversion from {input_path.suffix} to {output_format} is not yet implemented: {str(e)}"
            )
