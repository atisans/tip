# Utilities Package

Common utility functions and helpers for Tip.

## Overview

This package provides shared utility functions used across the Tip application. These are general-purpose helpers that don't fit into specific domain packages.

## Modules

### String Utilities

```go
// Truncate string to max length with ellipsis
Truncate(s string, maxLen int) string

// Sanitize string for safe display
Sanitize(s string) string

// Generate random string
RandomString(length int) string

// Slugify string for URLs
Slugify(s string) string
```

### Time Utilities

```go
// Format duration in human-readable form
FormatDuration(d time.Duration) string

// Parse human-readable time expressions
ParseDuration(s string) (time.Duration, error)

// TimeAgo returns "2 hours ago" style string
TimeAgo(t time.Time) string

// IsExpired checks if time is past expiry
IsExpired(t time.Time, ttl time.Duration) bool
```

### File Utilities

```go
// Expand home directory (~) in path
ExpandPath(path string) (string, error)

// Ensure directory exists, create if not
EnsureDir(path string) error

// Atomic file write (write to temp, then rename)
AtomicWrite(path string, data []byte) error

// Safe file removal (overwrite before delete)
SafeRemove(path string) error

// Copy file with permissions preservation
CopyFile(src, dst string) error
```

### Crypto Utilities

```go
// Generate cryptographically secure random bytes
SecureRandom(n int) ([]byte, error)

// Constant-time string comparison
SecureCompare(a, b string) bool

// Hash string using SHA-256
HashString(s string) string

// Generate UUID v4
GenerateUUID() (string, error)
```

### Validation Utilities

```go
// Validate email format
IsValidEmail(email string) bool

// Validate URL format
IsValidURL(url string) bool

// Validate strong password
IsStrongPassword(password string) (bool, []string)

// Sanitize input for safe storage
SanitizeInput(input string) string
```

### Encoding Utilities

```go
// Base64 URL-safe encoding
Base64Encode(data []byte) string
Base64Decode(s string) ([]byte, error)

// JSON marshaling with proper formatting
PrettyJSON(v interface{}) (string, error)

// Minify JSON (remove whitespace)
MinifyJSON(v interface{}) ([]byte, error)
```

### Collection Utilities

```go
// Check if string slice contains value
Contains(slice []string, item string) bool

// Remove duplicates from string slice
Unique(slice []string) []string

// Filter slice based on predicate
Filter(slice []string, predicate func(string) bool) []string

// Chunk slice into smaller slices
Chunk(slice []string, size int) [][]string
```

## Usage Examples

```go
import "github.com/tip/pkg/utils"

// String utilities
truncated := utils.Truncate("Very long text here", 20) // "Very long text..."

// Time utilities
ago := utils.TimeAgo(task.CreatedAt) // "3 hours ago"

// File utilities
path, err := utils.ExpandPath("~/.tip/config.yaml")
// Returns: "/home/user/.tip/config.yaml"

// Crypto utilities
uuid, err := utils.GenerateUUID()
// Returns: "550e8400-e29b-41d4-a716-446655440000"

// Validation
isValid, errors := utils.IsStrongPassword("weak")
// Returns: false, ["too short", "no uppercase", "no number"]
```

## Design Principles

1. **Pure functions**: No side effects, same input = same output
2. **Error handling**: Return errors rather than panic
3. **Zero dependencies**: Only standard library (except where necessary)
4. **Well-tested**: Comprehensive unit test coverage
5. **Documented**: Clear function names and documentation

## Testing

All utilities have extensive test coverage:
- Unit tests for all functions
- Edge case handling
- Property-based testing where applicable
- Benchmark tests for performance-critical functions
