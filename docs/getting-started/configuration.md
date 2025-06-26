# Configuration Guide

Enclose can be configured through various methods to customize its behavior. This guide covers all available configuration options.

## Configuration Methods

### 1. Command Line Arguments

Most common options can be set via command line:

```bash
enclose process input.md \
  --output output/ \
  --format pdf,svg,png \
  --dpi 300 \
  --ocr true
```

### 2. Configuration File

Create a `config.toml` file in your project root:

```toml
[general]
output_dir = "output/"
default_formats = ["pdf", "svg", "png"]
dpi = 300

[ocr]
enabled = true
language = "eng"

[pdf]
page_size = "A4"
margin = "1in"

[svg]
embed_fonts = true

[logging]
level = "INFO"
file = "enclose.log"
```

### 3. Environment Variables

```bash
export ENCLOSE_OUTPUT_DIR="output/"
export ENCLOSE_DPI=300
export ENCLOSE_OCR_ENABLED=true
```

## Configuration Options

### General Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `output_dir` | string | `./output` | Output directory for processed files |
| `default_formats` | list | `["pdf", "svg", "png"]` | Default output formats |
| `dpi` | int | `300` | DPI for image generation |
| `clean` | bool | `false` | Clean output directory before processing |

### PDF Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `page_size` | string | `"A4"` | Page size (A4, Letter, etc.) |
| `margin` | string | `"1in"` | Page margins |
| `orientation` | string | `"portrait"` | Page orientation |

### SVG Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `embed_fonts` | bool | `true` | Embed fonts in SVG |
| `width` | string | `"800"` | SVG width |
| `height` | string | `"1000"` | SVG height |

### OCR Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | bool | `true` | Enable OCR processing |
| `language` | string | `"eng"` | OCR language code |
| `confidence` | float | `0.8` | Minimum confidence threshold |

### Logging Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `level` | string | `"INFO"` | Logging level |
| `file` | string | `None` | Log file path |

## Configuration Precedence

1. Command line arguments (highest precedence)
2. Environment variables
3. Configuration file
4. Default values (lowest precedence)

## Example Configurations

### Minimal Configuration

```toml
[general]
output_dir = "output/"
```

### Production Configuration

```toml
[general]
output_dir = "/var/data/enclose/output"
default_formats = ["pdf", "png"]
dpi = 600

[ocr]
enabled = true
language = "eng+fra+deu"

[pdf]
page_size = "A4"
margin = "0.75in"

[logging]
level = "WARNING"
file = "/var/log/enclose.log"
```

## Environment Variables

All configuration options can be set via environment variables by prefixing them with `ENCLOSE_` and converting to uppercase with underscores:

```bash
# Equivalent to --output-dir=output
ENCLOSE_OUTPUT_DIR=output enclose process input.md

# Equivalent to --dpi=600
ENCLOSE_DPI=600 enclose process input.md

# Multiple options
ENCLOSE_DPI=600 ENCLOSE_OCR_ENABLED=false enclose process input.md
```

## Advanced Configuration

### Custom Templates

You can provide custom templates for different output formats. Place them in a `templates` directory in your configuration path.

### Plugins

Enclose supports plugins for custom processing steps. Create a Python package following the plugin interface and add it to your configuration:

```toml
[plugins]
custom_plugin = "my_plugin.module:PluginClass"
```

## Troubleshooting

### Common Issues

1. **Configuration Not Loading**
   - Ensure the configuration file is in the correct location
   - Check file permissions
   - Verify TOML syntax is valid

2. **Environment Variables Not Working**
   - Ensure variables are prefixed with `ENCLOSE_`
   - Check for typos in variable names
   - Make sure variables are exported in your shell

3. **Configuration Precedence Issues**
   - Remember that command line arguments override everything
   - Check for conflicting settings in different configuration sources
