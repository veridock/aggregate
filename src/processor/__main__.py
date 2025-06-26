#!/usr/bin/env python3
"""Main entry point for the enclose command."""

import argparse
import sys

from processor.core.document_processor import DocumentProcessor


def main():
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(
        description="Document Processing Pipeline - Convert formats"
    )

    # Required arguments
    parser.add_argument("input", help="Input file to process")
    parser.add_argument(
        "output_format",
        help="Output format (e.g., pdf, png, svg)",
        choices=["pdf", "png", "svg", "html"],
    )

    # Optional arguments
    parser.add_argument(
        "-o",
        "--output",
        help="Output file path (default: auto-gen in 'output' dir)",
    )
    parser.add_argument(
        "--list-formats",
        action="store_true",
        help="List all supported formats and exit",
    )

    args = parser.parse_args()
    processor = DocumentProcessor()

    if args.list_formats:
        formats = processor.get_supported_formats()
        print("\nSupported formats:")
        print(f"Input formats: {', '.join(formats['input_formats'])}")
        print(f"Output formats: {', '.join(formats['output_formats'])}")
        print("\nSupported conversions:")
        for src, dests in formats["conversions"].items():
            print(f"{src.upper()} -> {', '.join(dests).upper()}")
        return

    try:
        output_path = processor.process(
            args.input, args.output_format.lower(), args.output
        )
        print(f"Successfully created: {output_path}")
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
