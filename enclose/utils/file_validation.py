"""
File validation utilities.
"""
import os
import magic
from pathlib import Path
from typing import Dict, Tuple, Optional, Union

def get_file_mime_type(file_path: Union[str, Path]) -> str:
    """
    Get the MIME type of a file.
    
    Args:
        file_path: Path to the file
        
    Returns:
        MIME type as a string (e.g., 'application/pdf')
    """
    try:
        mime = magic.Magic(mime=True)
        return mime.from_file(str(file_path))
    except Exception as e:
        return f"error: {str(e)}"

def validate_file_signature(file_path: Union[str, Path], expected_type: str) -> Tuple[bool, str]:
    """
    Validate a file's signature against its expected type.
    
    Args:
        file_path: Path to the file
        expected_type: Expected file type ('pdf', 'svg', 'png', 'jpeg', etc.)
        
    Returns:
        Tuple of (is_valid, message)
    """
    if not os.path.exists(file_path):
        return False, f"File does not exist: {file_path}"
        
    mime_type = get_file_mime_type(file_path)
    
    # Map of expected MIME types for each file extension
    expected_mime_types = {
        'pdf': 'application/pdf',
        'svg': 'image/svg+xml',
        'png': 'image/png',
        'jpeg': 'image/jpeg',
        'jpg': 'image/jpeg',
        'html': 'text/html',
        'txt': 'text/plain',
        'md': 'text/markdown'
    }
    
    expected_mime = expected_mime_types.get(expected_type.lower())
    
    if not expected_mime:
        return False, f"Unsupported file type for validation: {expected_type}"
    
    if mime_type == expected_mime:
        return True, f"Valid {expected_type.upper()} file: {mime_type}"
    else:
        return False, f"Invalid {expected_type.upper()} file. Expected {expected_mime}, got {mime_type}"

def validate_converted_file(file_path: Union[str, Path], original_path: Optional[Union[str, Path]] = None) -> Dict[str, str]:
    """
    Validate a converted file's MIME type and signature.
    
    Args:
        file_path: Path to the converted file
        original_path: Optional path to the original file for comparison
        
    Returns:
        Dictionary with validation results
    """
    result = {
        'file': str(file_path),
        'exists': os.path.exists(file_path),
        'size_bytes': os.path.getsize(file_path) if os.path.exists(file_path) else 0,
        'mime_type': '',
        'is_valid': False,
        'validation_message': ''
    }
    
    if not result['exists']:
        result['validation_message'] = 'File does not exist'
        return result
    
    # Get file extension and validate
    ext = Path(file_path).suffix.lower().lstrip('.')
    if not ext:
        result['validation_message'] = 'No file extension found'
        return result
    
    # Get MIME type
    result['mime_type'] = get_file_mime_type(file_path)
    
    # Validate file signature
    is_valid, message = validate_file_signature(file_path, ext)
    result['is_valid'] = is_valid
    result['validation_message'] = message
    
    # If original file is provided, compare sizes (basic sanity check)
    if original_path and os.path.exists(original_path):
        try:
            orig_size = os.path.getsize(original_path)
            new_size = result['size_bytes']
            result['original_size'] = orig_size
            result['size_ratio'] = new_size / orig_size if orig_size > 0 else 0
        except Exception as e:
            result['size_comparison_error'] = str(e)
    
    return result
