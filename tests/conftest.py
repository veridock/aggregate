"""
Test configuration and fixtures.
"""
import os
import shutil
import tempfile
from pathlib import Path
import pytest


@pytest.fixture(scope="session")
def test_data_dir():
    """Return the path to the test data directory."""
    return Path(__file__).parent / "data"


@pytest.fixture(scope="function")
def temp_output_dir():
    """Create and return a temporary directory for test output."""
    temp_dir = tempfile.mkdtemp(prefix="enclose_test_")
    yield Path(temp_dir)
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)


@pytest.fixture
def example_markdown():
    """Return example markdown content."""
    return """# Test Document

## Section 1
This is a test document.

- Item 1
- Item 2
- Item 3
"""


@pytest.fixture
def example_markdown_file(tmp_path, example_markdown):
    """Create a temporary markdown file for testing."""
    md_file = tmp_path / "test.md"
    md_file.write_text(example_markdown)
    return md_file
