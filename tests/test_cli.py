"""Tests for the command-line interface."""
import sys
from importlib.util import find_spec

import pytest


def test_cli_help():
    """Test the CLI help message."""
    # Test that the module can be imported
    spec = find_spec('processor.__main__')
    assert spec is not None, "Failed to find processor.__main__ module"


def test_cli_list_command(capsys):
    """Test the --list command."""
    # Mock command line arguments
    test_args = ["--list"]

    # Import the main module and run with test arguments
    import processor.__main__ as main

    # Save original sys.argv
    original_argv = sys.argv

    try:
        # Set test arguments
        sys.argv = ["enclose"] + test_args

        # Run the main function
        main.main()

        # Check the output
        captured = capsys.readouterr()
        assert "Supported formats" in captured.out
        assert "Input formats" in captured.out
        assert "Output formats" in captured.out
    finally:
        # Restore original sys.argv
        sys.argv = original_argv


def test_cli_convert_command(temp_output_dir):
    """Test the file conversion command."""
    # Create a test markdown file
    test_md = temp_output_dir / "test.md"
    test_md.write_text("# Test Document\n\nThis is a test document.")

    # Mock command line arguments
    output_pdf = str(temp_output_dir / "output.pdf")
    test_args = [str(test_md), "pdf", "--output", output_pdf]

    # Import the main module and run with test arguments
    import processor.__main__ as main

    # Save original sys.argv
    original_argv = sys.argv

    try:
        # Set test arguments
        sys.argv = ["enclose"] + test_args

        # Run the main function
        main.main()

        # Check if the PDF file was created
        pdf_file = temp_output_dir / "output.pdf"
        assert pdf_file.exists()
    finally:
        # Restore original sys.argv
        sys.argv = original_argv


def test_cli_process_command(temp_output_dir, monkeypatch):
    """Test the 'process' command."""
    # First create an example markdown file
    from processor.converters.markdown_converter import create_example_markdown
    create_example_markdown(temp_output_dir)
    
    # Mock command line arguments
    test_args = ["--step", "process", "--output", str(temp_output_dir)]
    
    # Import the main module
    import processor.__main__ as main
    
    # Save original sys.argv
    original_argv = sys.argv
    
    try:
        # Set test arguments
        sys.argv = ["processor"] + test_args
        
        # Run the main function
        main.main()
        
        # Check if output files were created
        assert (temp_output_dir / "invoice_example.pdf").exists()
        assert (temp_output_dir / "invoice_example.svg").exists()
        assert any(temp_output_dir.glob("page_*.png"))
        assert (temp_output_dir / "metadata.json").exists()
        
    finally:
        # Restore original sys.argv
        sys.argv = original_argv
