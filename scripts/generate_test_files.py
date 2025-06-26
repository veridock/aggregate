#!/usr/bin/env python3
"""
Generate test files of different types for validation.
"""
import os
from pathlib import Path

def generate_test_files(output_dir: str = "test_files") -> None:
    """Generate test files of different types."""
    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)
    
    # Generate a simple text file
    text_file = output_path / "test.txt"
    with open(text_file, 'w') as f:
        f.write("This is a test text file.")
    
    # Generate a simple HTML file
    html_file = output_path / "test.html"
    with open(html_file, 'w') as f:
        f.write("""<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body><h1>Test HTML</h1></body>
</html>""")
    
    # Generate a simple SVG file
    svg_file = output_path / "test.svg"
    with open(svg_file, 'w') as f:
        f.write("""<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="40" fill="red" />
</svg>""")
    
    print(f"Generated test files in {output_path.absolute()}")
    for f in output_path.iterdir():
        print(f"  - {f.name}")

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate test files for validation')
    parser.add_argument('--output-dir', default='test_files',
                       help='Directory to save test files (default: test_files)')
    
    args = parser.parse_args()
    generate_test_files(args.output_dir)
