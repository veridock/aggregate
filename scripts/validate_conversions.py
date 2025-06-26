#!/usr/bin/env python3
"""
Script to validate the MIME types of converted files.
"""
import sys
import json
from pathlib import Path
from typing import Dict, Any, List

# Add the project root to the Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from enclose.utils.file_validation import validate_converted_file

def validate_conversion_pipeline(output_dir: str) -> Dict[str, Any]:
    """
    Validate all files in the output directory of a conversion pipeline.
    
    Args:
        output_dir: Directory containing converted files
        
    Returns:
        Dictionary with validation results
    """
    output_path = Path(output_dir)
    results = {
        'directory': str(output_path.absolute()),
        'files': [],
        'summary': {
            'total_files': 0,
            'valid_files': 0,
            'invalid_files': 0,
            'by_extension': {}
        }
    }
    
    # Common file extensions to check
    extensions = {'.pdf', '.svg', '.png', '.jpg', '.jpeg', '.html', '.md'}
    
    # Find all relevant files
    for ext in extensions:
        for file_path in output_path.rglob(f'*{ext}'):
            if file_path.is_file():
                # Skip temporary files
                if file_path.name.startswith('.'):
                    continue
                    
                # Validate the file
                validation = validate_converted_file(file_path)
                results['files'].append(validation)
                
                # Update summary
                results['summary']['total_files'] += 1
                if validation['is_valid']:
                    results['summary']['valid_files'] += 1
                else:
                    results['summary']['invalid_files'] += 1
                
                # Update extension stats
                ext = file_path.suffix.lower()
                if ext not in results['summary']['by_extension']:
                    results['summary']['by_extension'][ext] = {
                        'total': 0,
                        'valid': 0,
                        'invalid': 0
                    }
                results['summary']['by_extension'][ext]['total'] += 1
                if validation['is_valid']:
                    results['summary']['by_extension'][ext]['valid'] += 1
                else:
                    results['summary']['by_extension'][ext]['invalid'] += 1
    
    return results

def print_validation_results(results: Dict[str, Any]) -> None:
    """Print validation results in a human-readable format."""
    print(f"\nValidation Results for: {results['directory']}")
    print("=" * 80)
    
    # Print summary
    summary = results['summary']
    print(f"\nSummary:")
    print(f"  Total files: {summary['total_files']}")
    print(f"  Valid files: {summary['valid_files']}")
    print(f"  Invalid files: {summary['invalid_files']}")
    
    # Print by extension
    if summary['by_extension']:
        print("\nBy extension:")
        for ext, stats in summary['by_extension'].items():
            print(f"  {ext}:")
            print(f"    Total: {stats['total']}")
            print(f"    Valid: {stats['valid']}")
            print(f"    Invalid: {stats['invalid']}")
    
    # Print details of invalid files
    invalid_files = [f for f in results['files'] if not f['is_valid']]
    if invalid_files:
        print("\nInvalid Files:")
        for file_info in invalid_files:
            print(f"\n  File: {file_info['file']}")
            print(f"  MIME Type: {file_info['mime_type']}")
            print(f"  Message: {file_info['validation_message']}")
    
    # Print a final status
    if summary['invalid_files'] > 0:
        print("\n❌ Validation failed - Some files are invalid")
        sys.exit(1)
    else:
        print("\n✅ All files are valid!")
        sys.exit(0)

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Validate converted files in a directory')
    parser.add_argument('directory', nargs='?', default='output',
                       help='Directory containing converted files (default: output)')
    parser.add_argument('--json', action='store_true',
                       help='Output results as JSON')
    
    args = parser.parse_args()
    
    results = validate_conversion_pipeline(args.directory)
    
    if args.json:
        print(json.dumps(results, indent=2))
    else:
        print_validation_results(results)
