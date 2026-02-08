# JSON Storage Adapter

JSON file-based storage implementation for Tip.

## Overview

This package provides a file-based storage adapter using JSON format. It's designed for local-only usage where simplicity and portability are priorities over performance.

## Features

- JSON file storage with human-readable format
- Atomic write operations (write to temp, then rename)
- Automatic directory creation
- File locking for concurrent access safety
- Compression support (optional)

## Storage Format

Data is stored in JSON files with the following structure:

```json
{
  "version": "1.0",
  "vaults": [
    {
      "id": "vault-uuid",
      "name": "Personal",
      "passwords": [...],
      "tasks": [...]
    }
  ]
}
```

## File Locations

Default storage directory:
- Linux/macOS: `~/.tip/storage/`
- Windows: `%USERPROFILE%\.tip\storage\`

File naming convention:
- `{vault_id}.json` - Individual vault files
- `metadata.json` - Storage metadata and indexes

## Performance Characteristics

- **Read**: O(n) where n is file size
- **Write**: O(n) - full file rewrite on any change
- **Search**: O(n) - linear search through all records
- **Concurrent Access**: File locking prevents corruption

**Best for**: Small to medium datasets (< 1000 items), local development, backup exports

**Not recommended for**: Large datasets, high-concurrency scenarios, production servers

## Usage

```go
import "github.com/tip/pkg/storage/json"

// Create storage instance
store, err := json.NewStorage(json.Options{
    Directory: "~/.tip/storage",
})
if err != nil {
    log.Fatal(err)
}

// Use storage interface methods
vaults, err := store.ListVaults()
if err != nil {
    log.Fatal(err)
}

// Close when done
defer store.Close()
```

## Implementation Details

### Write Safety
All writes use atomic operations:
1. Write to temporary file
2. Sync to disk
3. Rename to target file
4. Remove temp file

This ensures data integrity even if the process crashes during write.

### File Locking
Uses advisory file locking to prevent concurrent writes:
- Read locks allow multiple readers
- Write locks are exclusive
- Lock timeout prevents deadlocks

### Encryption
Data is encrypted at rest using AES-256-GCM:
- Each vault has its own encryption key
- Keys are derived from master password using Argon2id
- Encrypted data is base64 encoded in JSON

## Migration

To migrate from JSON to SQLite storage:
```bash
tip vault export --format=json myvault
tip vault import --storage=sqlite myvault.json
```
