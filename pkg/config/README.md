# Configuration Package

Application-wide configuration management for Tip.

## Overview

This package provides centralized configuration management for the Tip application, handling configuration loading, validation, and access across all components.

## Features

- Multi-source configuration (files, environment, flags)
- Type-safe configuration access
- Configuration validation
- Hot-reload support
- Default value management
- Configuration migration

## Configuration Hierarchy

Configuration is resolved in the following order (later sources override earlier):

1. **Built-in defaults**
2. **Configuration file** (`~/.tip/config.yaml`)
3. **Environment variables** (`TIP_*`)
4. **Command-line flags** (highest priority)

## Configuration Structure

```go
type Config struct {
    // Server configuration
    Server ServerConfig `yaml:"server"`
    
    // Storage configuration
    Storage StorageConfig `yaml:"storage"`
    
    // Security configuration
    Security SecurityConfig `yaml:"security"`
    
    // UI/UX configuration
    UI UIConfig `yaml:"ui"`
    
    // Feature flags
    Features FeatureFlags `yaml:"features"`
}
```

### Server Configuration

```go
type ServerConfig struct {
    URL         string        `yaml:"url"`          // Server URL
    Timeout     time.Duration `yaml:"timeout"`      // Request timeout
    RetryCount  int           `yaml:"retry_count"`  // Max retries
    SyncEnabled bool          `yaml:"sync_enabled"` // Enable cloud sync
}
```

### Storage Configuration

```go
type StorageConfig struct {
    Backend      string `yaml:"backend"`       // "json", "sqlite", "remote"
    DataDirectory string `yaml:"data_dir"`     // Local storage path
    CacheEnabled bool   `yaml:"cache_enabled"` // Enable caching
    CacheSize    int    `yaml:"cache_size"`    // Cache size in MB
}
```

### Security Configuration

```go
type SecurityConfig struct {
    MasterPasswordTimeout time.Duration `yaml:"master_password_timeout"`
    ClipboardTimeout      time.Duration `yaml:"clipboard_timeout"`
    AutoLockEnabled       bool          `yaml:"auto_lock_enabled"`
    AutoLockTimeout       time.Duration `yaml:"auto_lock_timeout"`
    ConfirmDestructive    bool          `yaml:"confirm_destructive"`
}
```

### UI Configuration

```go
type UIConfig struct {
    ColorEnabled    bool   `yaml:"color_enabled"`    // Enable colored output
    PagerEnabled    bool   `yaml:"pager_enabled"`    // Use pager for long output
    DefaultEditor   string `yaml:"default_editor"`   // Default text editor
    DateFormat      string `yaml:"date_format"`      // Date display format
    QuietMode       bool   `yaml:"quiet_mode"`       // Suppress non-essential output
}
```

## Environment Variables

All configuration options can be set via environment variables using the prefix `TIP_`:

```bash
export TIP_SERVER_URL="https://api.tip.io"
export TIP_STORAGE_BACKEND="sqlite"
export TIP_SECURITY_CLIPBOARD_TIMEOUT="45s"
export TIP_UI_COLOR_ENABLED="false"
```

Nested configuration uses underscore separators:
- `TIP_SERVER_URL` → `server.url`
- `TIP_SECURITY_AUTO_LOCK_TIMEOUT` → `security.auto_lock_timeout`

## Configuration File

Default location: `~/.tip/config.yaml`

### Example Configuration

```yaml
server:
  url: "https://api.tip.io"
  timeout: 30s
  sync_enabled: true

storage:
  backend: "sqlite"
  data_dir: "~/.tip/data"
  cache_enabled: true
  cache_size: 100

security:
  master_password_timeout: 5m
  clipboard_timeout: 30s
  auto_lock_enabled: true
  auto_lock_timeout: 10m
  confirm_destructive: true

ui:
  color_enabled: true
  pager_enabled: true
  default_editor: "vim"
  date_format: "2006-01-02 15:04"

features:
  sync: true
  sharing: true
  audit_logging: false
```

## Usage

```go
import "github.com/tip/pkg/config"

// Load configuration
cfg, err := config.Load()
if err != nil {
    log.Fatal(err)
}

// Access configuration values
timeout := cfg.Server.Timeout
backend := cfg.Storage.Backend

// Check if feature is enabled
if cfg.Features.Sync {
    // Enable sync functionality
}
```

## Validation

Configuration is validated on load:
- Required fields must be present
- Values must be within valid ranges
- File paths must exist (when applicable)
- URLs must be valid

```go
cfg, err := config.Load()
if err != nil {
    if validationErr, ok := err.(*config.ValidationError); ok {
        // Handle validation errors
        for _, field := range validationErr.Fields {
            log.Printf("Invalid config: %s - %s", field.Name, field.Message)
        }
    }
}
```

## Hot Reload

Configuration can be reloaded at runtime (useful for long-running server):

```go
// Watch for file changes
config.Watch(func() {
    log.Println("Configuration reloaded")
})

// Or reload manually
err := config.Reload()
```

## Configuration Migration

When configuration format changes, automatic migration is provided:

```go
// Migrate from v1 to v2
err := config.Migrate("v1", "v2")
```
