from setuptools import setup, find_packages

setup(
    name="enclose",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        'markdown>=3.3.0',
        'weasyprint>=52.5',
        'reportlab>=3.6.0',
        'Pillow>=8.0.0',
        'cairosvg>=2.5.0',
        'pdf2image>=1.16.0',
        'pytesseract>=0.3.8',
        'beautifulsoup4>=4.9.0',
    ],
    entry_points={
        'console_scripts': [
            'process-documents=processor.__main__:main',
        ],
    },
    python_requires='>=3.7',
)
