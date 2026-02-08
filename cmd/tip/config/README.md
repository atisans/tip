# CLI Configuration Package

Configuration management for the Tip CLI application.

## Purpose

This package handles:
- Configuration file loading and parsing
- Default configuration values
- Configuration validation
- Environment variable support
- Configuration persistence

## Configuration Sources

Configuration is loaded from (in order of precedence):
1. Command-line flags (highest priority)
2. Environment variables (TIP_*)
3. Configuration file (~/.tip/config.yaml)
4. Default values (lowest priority)

## Configuration File

Default location: `~/.tip/config.yaml`

### Example Configuration

```yaml
# Server settings
server:
  url: "https://api.tip.local"
  timeout: 30

# Default vault settings
vault:
  default: "personal"
  auto_lock: 300  # seconds

# UI preferences
ui:
  color: true
  pager: true
  editor: "vim"

# Security settings
security:
  clipboard_timeout: 30
  confirm_destructive: true
```

## Environment Variables

All configuration options can be set via environment variables:
- `TIP_SERVER_URL` - Server URL
- `TIP_VAULT_DEFAULT` - Default vault name
- `TIP_UI_COLOR` - Enable colored output

## Implementation

Uses Viper for configuration management with support for:
- YAML, JSON, and TOML formats
- Automatic config file watching
- Nested configuration keys
- Type-safe configuration access
