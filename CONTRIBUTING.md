# Contributing to Enclose

Thank you for your interest in contributing to Enclose! This guide will help you get started with contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#-code-of-conduct)
- [Getting Started](#-getting-started)
- [Development Environment](#-development-environment)
- [Making Changes](#-making-changes)
- [Code Style](#-code-style)
- [Testing](#-testing)
- [Documentation](#-documentation)
- [Submitting a Pull Request](#-submitting-a-pull-request)
- [Reporting Issues](#-reporting-issues)
- [Feature Requests](#-feature-requests)
- [Code Review Process](#-code-review-process)

## 👥 Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## 🚀 Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork locally
   ```bash
   git clone https://github.com/your-username/enclose.git
   cd enclose
   ```
3. **Set up** the development environment (see below)

## 💻 Development Environment

### Prerequisites

- Python 3.8.1+
- [Poetry](https://python-poetry.org/) for dependency management
- [Git](https://git-scm.com/)

### Setup

1. **Install dependencies**
   ```bash
   make install
   ```

2. **Activate the virtual environment**
   ```bash
   poetry shell
   ```

3. **Install pre-commit hooks**
   ```bash
   pre-commit install
   ```

## ✨ Making Changes

1. **Create a new branch** for your changes
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b bugfix/issue-number-description
   ```

2. **Make your changes** following the code style guide

3. **Test your changes**
   ```bash
   make test
   make lint
   ```

4. **Commit your changes** with a descriptive message
   ```bash
   git commit -m "Add feature: brief description of changes"
   ```

5. **Push** to your fork
   ```bash
   git push origin your-branch-name
   ```

## 🎨 Code Style

We use the following tools to maintain code quality:

- **Black** for code formatting
- **isort** for import sorting
- **Flake8** for linting
- **Mypy** for static type checking

Run the formatters and linters:

```bash
make format  # Auto-format code
make lint    # Check code quality
make type    # Run type checking
```

## 🧪 Testing

We use `pytest` for testing. To run the tests:

```bash
# Run all tests
make test

# Run a specific test file
pytest tests/test_module.py

# Run tests with coverage report
make test-cov
```

## 📚 Documentation

Documentation is stored in the `docs/` directory. When making changes:

1. Update existing documentation if necessary
2. Add new documentation for new features
3. Ensure all public APIs are documented

To build the documentation locally:

```bash
make docs
```

## 🔄 Submitting a Pull Request

1. **Fork** the repository
2. **Create a new branch** for your changes
3. **Make your changes**
4. **Write tests** for your changes
5. **Run tests** and fix any issues
6. **Update documentation** as needed
7. **Push** your changes to your fork
8. **Open a Pull Request** with a clear title and description

### Pull Request Guidelines

- Keep PRs focused on a single feature or bug fix
- Include tests for new functionality
- Update documentation as needed
- Follow the PR template

## 🐛 Reporting Issues

Found a bug? Please let us know by [opening an issue](https://github.com/veridock/enclose/issues).

### When Reporting an Issue

- Use a clear and descriptive title
- Include steps to reproduce the issue
- Add error messages and logs if applicable
- Specify your environment (OS, Python version, etc.)
- Include screenshots if helpful

## 💡 Feature Requests

We welcome feature requests! Please [open an issue](https://github.com/veridock/enclose/issues) and:

1. Describe the feature you'd like to see
2. Explain why this would be useful
3. Provide any relevant examples

## 👀 Code Review Process

1. A maintainer will review your PR
2. You may receive feedback or be asked to make changes
3. Once approved, a maintainer will merge your PR

### Review Guidelines

- Be constructive and respectful
- Focus on the code, not the person
- Explain your reasoning
- Suggest improvements
- Thank contributors for their time

## 🏷️ Versioning

We use [Semantic Versioning](https://semver.org/) (SemVer) for versioning. For the versions available, see the [tags on this repository](https://github.com/veridock/enclose/tags).

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thank you to all contributors who have helped improve Enclose!
- Special thanks to our early adopters and beta testers
