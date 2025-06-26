#!/usr/bin/env python3
"""
Document Processing Pipeline - Convert between different document formats.

Usage:
  enclose [command] [options]
  enclose <input> <output_format> [options]
  enclose --help
  enclose --version

Commands:
  list      List all supported formats and conversions

Examples:
  enclose document.md pdf -o output.pdf
  enclose list
"""

import argparse
import sys
from typing import Optional, List

from processor.core.document_processor import DocumentProcessor


def list_formats() -> None:
    """List all supported formats and conversions."""
    processor = DocumentProcessor()
    formats = processor.get_supported_formats()
    print("\nSupported formats:")
    print(f"Input formats: {', '.join(formats['input_formats'])}")
    print(f"Output formats: {', '.join(formats['output_formats'])}")
    print("\nSupported conversions:")
    for src, dests in formats["conversions"].items():
        print(f"{src.upper()} -> {', '.join(dests).upper()}")


def convert_file(input_path: str, output_format: str, output_path: Optional[str] = None) -> None:
    """Convert a file to the specified format."""
    processor = DocumentProcessor()
    try:
        output_path = processor.process(input_path, output_format.lower(), output_path)
        print(f"Successfully created: {output_path}")
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)


def main(args: Optional[List[str]] = None) -> None:
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(
        description="Document Processing Pipeline - Convert between document formats",
        usage="%(prog)s [command] [options]"
    )
    
    # Add --version flag
    parser.add_argument(
        '--version',
        action='version',
        version='%(prog)s 1.0.0',
        help="Show version and exit"
    )
    
    # Subparsers for commands
    subparsers = parser.add_subparsers(dest='command', help='Command to run')
    
    # List command
    list_parser = subparsers.add_parser('list', help='List supported formats')
    
    # Convert command (default)
    convert_parser = argparse.ArgumentParser(add_help=False)
    convert_parser.add_argument(
        "input",
        help="Input file to process"
    )
    convert_parser.add_argument(
        "output_format",
        help="Output format (e.g., pdf, png, svg)",
        choices=["pdf", "png", "svg", "html"],
    )
    convert_parser.add_argument(
        "-o", "--output",
        help="Output file path (default: auto-generated in 'output' directory)",
    )
    
    # If no arguments, show help
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)
    
    # Check if first argument is a command or a file
    if len(sys.argv) > 1 and sys.argv[1] in ['list', '--help', '--version']:
        args = parser.parse_args()
    else:
        # Use convert parser for file conversion
        args = convert_parser.parse_args()
        args.command = 'convert'
    
    # Execute the appropriate command
    if args.command == 'list':
        list_formats()
    elif args.command == 'convert':
        convert_file(args.input, args.output_format, args.output)
    else:
        # This handles --help and --version
        parser.parse_args()


if __name__ == "__main__":
    main()
