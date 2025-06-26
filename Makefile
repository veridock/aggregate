# Document Processing Pipeline Makefile
# Handles: Markdown → PDF → SVG → PNG → OCR → Search → Aggregation
# Enhanced with universal converter capabilities and development tools

SHELL := /bin/bash
PYTHON := poetry run python
PIP := poetry run pip
VENV := $(shell poetry env info -p 2>/dev/null || echo "venv")
ACTIVATE := $(VENV)/bin/activate
OUTPUT_DIR := output
CONFIG_DIR := ./config

# Color definitions for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
NC := \033[0m # No Color

# Logging functions
define log_info
	@echo -e "$(GREEN)[INFO]$(NC) $(1)"
endef

define log_warn
	@echo -e "$(YELLOW)[WARN]$(NC) $(1)"
endef

define log_error
	@echo -e "$(RED)[ERROR]$(NC) $(1)"
endef

define log_success
	@echo -e "$(PURPLE)[SUCCESS]$(NC) $(1)"
endef

# Default target
.PHONY: all
all: install test
	$(call log_success,Project setup and tests completed successfully!)

# Install all required dependencies using Poetry
.PHONY: install
install: install-system-deps
	$(call log_info,Installing Python dependencies using Poetry...)
	poetry install --with dev
	$(call log_success,Dependencies installed successfully!)

# Create virtual environment
.PHONY: venv
venv:
	$(call log_info,Ensuring Poetry environment is ready...)
	poetry env use python3
	poetry install --with dev
	$(call log_success,Poetry environment is ready)

# Install system dependencies
.PHONY: install-system-deps
install-system-deps:
	$(call log_info,Checking system dependencies...)
	@if [ -f "$(CONFIG_DIR)/install_dependencies.sh" ]; then \
		bash $(CONFIG_DIR)/install_dependencies.sh; \
	else \
		echo -e "$(YELLOW)[WARN]$(NC) System dependency installer not found"; \
		echo -e "$(YELLOW)[WARN]$(NC) Please ensure the following system dependencies are installed:"; \
		echo -e "  - poppler-utils (for pdf2image)"; \
		echo -e "  - tesseract-ocr (for OCR)"; \
		echo -e "  - python3-dev (for building dependencies)"; \
	fi

# Development environment setup
.PHONY: install-dev
install-dev: install
	$(call log_info,Installing development dependencies...)
	poetry run pip install \
		black>=22.3.0 \
		isort>=5.10.1 \
		flake8>=5.0.0 \
		mypy>=0.971 \
		pytest>=7.0.0 \
		pytest-cov>=3.0.0
	$(call log_success,Development environment ready!)

# Create example files
.PHONY: create
create:
	$(call log_info,Creating example markdown file...)
	poetry run python processor.py --step create
	$(call log_success,Example files created!)

# Process documents through the pipeline
.PHONY: process
process:
	$(call log_info,Processing documents through pipeline...)
	poetry run python processor.py --step process
	$(call log_success,Processing completed!)

# Aggregate results
.PHONY: aggregate
aggregate:
	$(call log_info,Aggregating results...)
	poetry run python processor.py --step aggregate
	$(call log_success,Aggregation completed!)

# Search metadata
.PHONY: search
search:
	$(call log_info,Searching metadata...)
	poetry run python processor.py --step search
	$(call log_success,Search completed!)

# Universal file conversion function
define convert_file
	@if [ ! -f "$(CONVERTER_DIR)/$(1).sh" ]; then \
		$(call log_error,Converter $(1) not found); \
		exit 1; \
	fi; \
	if [ -z "$(2)" ] || [ -z "$(3)" ] || [ -z "$(4)" ]; then \
		$(call log_error,Missing arguments); \
		echo "Usage: make convert CONVERTER=$(1) FROM=$(2) TO=$(3) INPUT=$(4) [OUTPUT=$(5)]"; \
		exit 1; \
	fi; \
	OUTPUT_FILE="$(if $(5),$(5),$(basename $(4)).$(3))"; \
	$(call log_info,Converting with $(1): $(4) ($(2)) -> $OUTPUT_FILE ($(3))); \
	bash $(CONVERTER_DIR)/$(1).sh "$(2)" "$(3)" "$(4)" "$OUTPUT_FILE"
endef

# Convert files using external converters
.PHONY: convert
convert:
	$(call convert_file,$(CONVERTER),$(FROM),$(TO),$(INPUT),$(OUTPUT))

# Image conversion shortcuts
.PHONY: img-convert
img-convert:
	$(call convert_file,imagemagick,$(FROM),$(TO),$(INPUT),$(OUTPUT))

.PHONY: pdf-convert
pdf-convert:
	$(call convert_file,pandoc,$(FROM),$(TO),$(INPUT),$(OUTPUT))

# Code formatting
.PHONY: format
format:
	$(call log_info,Formatting code...)
	poetry run black processor/ tests/
	poetry run isort processor/ tests/
	$(call log_success,Code formatted!)

# Code linting
.PHONY: lint
lint:
	$(call log_info,Linting code...)
	poetry run flake8 processor/ tests/
	poetry run mypy processor/ tests/
	$(call log_success,Linting complete!)

# Run tests
.PHONY: test
test:
	$(call log_info,Running tests...)
	poetry run pytest -v --cov=processor tests/

# Run tests with coverage report
.PHONY: coverage
coverage:
	$(call log_info,Running tests with coverage...)
	poetry run pytest --cov=processor --cov-report=html tests/
	$(call log_success,Coverage report generated in htmlcov/)

# Clean up build artifacts
.PHONY: clean
clean:
	$(call log_info,Cleaning up build artifacts...)
	rm -rf build/ dist/ *.egg-info/ .pytest_cache/ .coverage htmlcov/ .mypy_cache/
	find . -type d -name "__pycache__" -exec rm -r {} +
	find . -type f -name "*.py[co]" -delete
	$(call log_success,Cleaned up build artifacts)

# Benchmark the pipeline
.PHONY: benchmark
benchmark:
	$(call log_info,Running pipeline benchmark...)
	@echo -e "$(YELLOW)Running document processing benchmark...$(NC)"
	@echo -e "$(CYAN)Processing markdown to PDF...$(NC)"
	@time poetry run enclose test.md pdf -o benchmark_output.pdf
	@echo -e "\n$(CYAN)Processing PDF to SVG...$(NC)"
	@time poetry run enclose benchmark_output.pdf svg -o benchmark_output.svg
	@echo -e "\n$(CYAN)Processing SVG to PNG...$(NC)"
	@time poetry run enclose benchmark_output.svg png -o benchmark_output.png
	$(call log_success,Benchmark completed! Results in benchmark_output.*)

# Validate output files
.PHONY: validate
validate:
	$(call log_info,Validating output files...)
	@if [ -d "$(OUTPUT_DIR)" ]; then \
		echo -e "$(GREEN)Found output directory: $(OUTPUT_DIR)$(NC)"; \
		if command -v pdftotext >/dev/null; then \
			for file in $(OUTPUT_DIR)/*.pdf; do \
				if [ -f "$$file" ]; then \
					if ! pdftotext "$$file" - &>/dev/null; then \
						echo -e "$(RED)Invalid PDF: $$file$(NC)"; \
						exit 1; \
					else \
						echo -e "$(GREEN)Valid PDF: $$file$(NC)"; \
					fi; \
				fi; \
			done; \
		else \
			echo -e "$(YELLOW)pdftotext not found, skipping PDF validation$(NC)"; \
		fi; \
		for file in $(OUTPUT_DIR)/*.{svg,png}; do \
			if [ -f "$$file" ]; then \
				echo -e "$(GREEN)Found output file: $$file$(NC)"; \
			fi; \
		done; \
	else \
		$(call log_warn,Output directory $(OUTPUT_DIR) does not exist); \
		exit 1; \
	fi
	$(call log_success,Output files validated successfully!)

# List supported formats
.PHONY: list-formats
list-formats:
	$(call log_info,Supported input/output formats:)
	@echo -e "$(CYAN)Input formats:$(NC)"
	@echo "  - Markdown (.md)"
	@echo "  - Text (.txt)"
	@echo "  - HTML (.html)"
	@echo ""
	@echo -e "$(CYAN)Output formats:$(NC)"
	@echo "  - PDF (.pdf)"
	@echo "  - SVG (.svg)"
	@echo "  - PNG (.png)"
	@echo "  - JSON metadata (.json)"
	@echo "  - HTML dashboard (.html)"

# Check system requirements
.PHONY: check-system
check-system:
	$(call log_info,Checking system requirements...)
	@echo "Python: $($(PYTHON) --version 2>/dev/null || echo 'Not found')"
	@echo "Tesseract: $(tesseract --version 2>/dev/null | head -n1 || echo 'Not found')"
	@echo "Poppler: $(pdftoppm -v 2>&1 | head -n1 || echo 'Not found')"
	@echo "Cairo: $(pkg-config --modversion cairo 2>/dev/null || echo 'Not found')"
	@echo "ImageMagick: $(convert -version 2>/dev/null | head -n1 || echo 'Not found')"

# Create project structure
.PHONY: init-project
init-project:
	$(call log_info,Initializing project structure...)
	@mkdir -p $(OUTPUT_DIR) $(CONVERTER_DIR) $(CONFIG_DIR) tests docs examples
	@touch $(CONVERTER_DIR)/.gitkeep $(CONFIG_DIR)/.gitkeep tests/.gitkeep
	$(call log_success,Project structure initialized!)

# Package and distribute
.PHONY: package
package: clean test lint
	$(call log_info,Creating distribution package...)
	@mkdir -p dist
	@tar -czf dist/document-processor-$(date +%Y%m%d).tar.gz \
		--exclude=venv --exclude=dist --exclude=__pycache__ \
		--exclude=.git --exclude=*.pyc .
	$(call log_success,Package created in dist/)

# Deploy to server (requires SSH config)
.PHONY: deploy
deploy: package
	$(call log_info,Deploying package...)
	@if [ -n "$(SERVER)" ]; then \
		scp dist/*.tar.gz $(SERVER):/tmp/; \
		$(call log_success,Package deployed to $(SERVER)); \
	else \
		$(call log_error,SERVER variable not set); \
		echo "Usage: make deploy SERVER=user@hostname"; \
	fi

# Monitor processing (runs pipeline and watches files)
.PHONY: monitor
monitor:
	$(call log_info,Starting monitoring mode...)
	@echo "Watching for changes in current directory..."
	@while true; do \
		inotifywait -e modify,create,delete . 2>/dev/null && \
		echo "Change detected, running pipeline..." && \
		$(MAKE) process; \
	done

# Generate documentation
.PHONY: docs
docs:
	$(call log_info,Generating documentation...)
	@mkdir -p docs
	@echo "# Document Processing Pipeline Documentation" > docs/README.md
	@echo "" >> docs/README.md
	@echo "Generated on: $(date)" >> docs/README.md
	@echo "" >> docs/README.md
	@$(MAKE) help >> docs/README.md
	$(call log_success,Documentation generated in docs/)

# Clean generated files
.PHONY: clean
clean:
	$(call log_info,Cleaning generated files...)
	@rm -f *.pdf *.svg *.png *.json *.html
	@rm -rf $(OUTPUT_DIR)/ __pycache__/ *.pyc .pytest_cache/ .coverage
	$(call log_success,Cleanup completed!)

# Clean everything including virtual environment
.PHONY: clean-all
clean-all: clean
	$(call log_info,Removing virtual environment and distribution files...)
	@rm -rf $(VENV)/ dist/ .mypy_cache/
	$(call log_success,Full cleanup completed!)

# Show system status
.PHONY: status
status:
	@echo -e "$(BLUE)Document Processing Pipeline Status$(NC)"
	@echo "=================================="
	@echo ""
	@echo -e "$(CYAN)Environment:$(NC)"
	@echo "  Virtual env: $([ -d $(VENV) ] && echo '✓ Active' || echo '✗ Not found')"
	@echo "  Python: $($(PYTHON) --version 2>/dev/null || echo 'Not found')"
	@echo ""
	@echo -e "$(CYAN)Output Directory:$(NC)"
	@if [ -d "$(OUTPUT_DIR)" ]; then \
		echo "  Files: $(ls -1 $(OUTPUT_DIR) 2>/dev/null | wc -l) items"; \
		echo "  Size: $(du -sh $(OUTPUT_DIR) 2>/dev/null | cut -f1)"; \
	else \
		echo "  Status: Not created"; \
	fi
	@echo ""
	@echo -e "$(CYAN)Last Run:$(NC)"
	@if [ -f "$(OUTPUT_DIR)/metadata.json" ]; then \
		echo "  Last processed: $(stat -c %y $(OUTPUT_DIR)/metadata.json 2>/dev/null | cut -d. -f1)"; \
	else \
		echo "  Status: Never run"; \
	fi

# Interactive mode
.PHONY: interactive
interactive:
	@echo -e "$(BLUE)Document Processing Pipeline - Interactive Mode$(NC)"
	@echo "================================================"
	@echo ""
	@echo "Select an option:"
	@echo "1. Run full pipeline (create → process → aggregate)"
	@echo "2. Process existing files"
	@echo "3. Run tests"
	@echo "4. Format and lint code"
	@echo "5. Check system status"
	@echo "6. Clean build artifacts"
	@echo "7. Exit"
	@echo ""
	@read -p "Enter choice (1-7): " choice; \
	case "$$choice" in \
		1) poetry run enclose test.md pdf -o output/document.pdf \
		   && poetry run enclose output/document.pdf svg -o output/document.svg \
		   && poetry run enclose output/document.svg png -o output/document.png \
		   && echo -e "$(GREEN)Pipeline completed successfully!$(NC)" \
		   && ls -l output/;; \
		2) read -p "Enter input file path: " input_file; \
		   read -p "Enter output format (pdf/svg/png): " output_format; \
		   read -p "Enter output file path (optional): " output_file; \
		   if [ -z "$$output_file" ]; then \
			   poetry run enclose "$$input_file" "$$output_format"; \
		   else \
			   poetry run enclose "$$input_file" "$$output_format" -o "$$output_file"; \
		   fi;; \
		3) make test;; \
		4) make format lint;; \
		5) echo -e "$(CYAN)=== System Information ===$(NC)"; \
		   echo "Python: $$(poetry run python --version)"; \
		   echo "Poetry: $$(poetry --version)"; \
		   echo "PDF Tools: $$(which pdftotext 2>/dev/null || echo 'Not installed')"; \
		   echo "Tesseract: $$(which tesseract 2>/dev/null || echo 'Not installed')"; \
		   echo -e "$(CYAN)=========================$(NC)";; \
		6) make clean;; \
		7) exit 0;; \
		*) echo -e "$(RED)Invalid choice$(NC)"; exit 1;; \
	esac

# Help target with enhanced information
.PHONY: help
help:
	@echo -e "$(BLUE)Document Processing Pipeline $(NC)"
	@echo "================================="
	@echo ""
	@echo -e "$(CYAN)Core Pipeline:$(NC)"
	@echo "  all           - Run complete pipeline (install → create → process → aggregate)"
	@echo "  install       - Install all dependencies"
	@echo "  create        - Create example markdown file"
	@echo "  process       - Process documents through pipeline"
	@echo "  aggregate     - Aggregate results into HTML table"
	@echo "  search        - Search metadata in filesystem"
	@echo ""
	@echo -e "$(CYAN)Development:$(NC)"
	@echo "  install-dev   - Install development dependencies"
	@echo "  format        - Format code with black and isort"
	@echo "  lint          - Lint code with flake8 and mypy"
	@echo "  test          - Run tests and validation"
	@echo "  benchmark     - Benchmark pipeline performance"
	@echo ""
	@echo -e "$(CYAN)File Conversion:$(NC)"
	@echo "  convert       - Universal file converter"
	@echo "  img-convert   - Image format conversion"
	@echo "  pdf-convert   - PDF conversion"
	@echo "  list-formats  - Show supported formats"
	@echo ""
	@echo -e "$(CYAN)Version Control:$(NC)"
	@echo "  push          - Push changes to remote repository"
	@echo "  commit       - Stage and commit changes"
	@echo ""
	@echo -e "$(CYAN)Utilities:$(NC)"
	@echo "  validate      - Validate output files"
	@echo "  check-system  - Check system requirements"
	@echo "  status        - Show pipeline status"
	@echo "  monitor       - Watch for file changes"
	@echo "  interactive   - Interactive mode"
	@echo ""
	@echo -e "$(CYAN)Maintenance:$(NC)"
	@echo "  clean         - Remove generated files"
	@echo "  clean-all     - Remove everything including venv"
	@echo "  package       - Create distribution package"
	@echo "  publish       - Publish package to PyPI and tag release"
	@echo "  docs          - Generate documentation"
	@echo ""
	@echo -e "$(CYAN)Examples:$(NC)"
	@echo "  make all                           # Complete pipeline"
	@echo "  make convert CONVERTER=imagemagick FROM=jpg TO=png INPUT=image.jpg"
	@echo "  make push                         # Push changes to remote"
	@echo "  make commit MSG='Update code'     # Commit changes with message"
	@echo "  make monitor                      # Watch for changes"

# Version Control
.PHONY: push
push:
	@echo -e "$(BLUE)Pushing changes to remote repository...$(NC)"
	@git push
	@echo -e "$(GREEN)✓ Changes pushed successfully$(NC)"

# Publish package to PyPI and tag release
.PHONY: publish
publish: test
	@echo -e "$(BLUE)Building and publishing package to PyPI...$(NC)"
	@poetry build
	@poetry publish
	@echo -e "$(GREEN)✓ Package published to PyPI successfully$(NC)"
	@echo -e "$(BLUE)Creating git tag for the release...$(NC)"
	@version=$$(poetry version -s); \
	tag="v$$version"; \
	git tag -a "$$tag" -m "Release $$tag"; \
	git push origin "$$tag"; \
	echo -e "$(GREEN)✓ Created and pushed tag $$tag to remote$(NC)"

.PHONY: commit
commit:
	@if [ -z "$(MSG)" ]; then \
		echo -e "$(RED)Error: Please provide a commit message with MSG='your message'$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)Staging and committing changes...$(NC)"
	@git add .
	@git commit -m "$(MSG)"
	@echo -e "$(GREEN)✓ Changes committed with message: $(YELLOW)$(MSG)$(NC)"

# Prevent make from interpreting arguments as targets
%:
	@: