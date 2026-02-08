# SQLite Storage Adapter

SQLite database storage implementation for Tip.

## Overview

This package provides a SQLite-based storage adapter offering high performance, ACID transactions, and efficient querying for production deployments.

## Features

- Full ACID compliance with transactions
- Efficient indexing for fast queries
- Support for complex queries and joins
- Data integrity constraints
- Backup and restore capabilities
- Migration system for schema updates

## Database Schema

### Tables

**vaults**
```sql
CREATE TABLE vaults (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    owner_id TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**passwords**
```sql
CREATE TABLE passwords (
    id TEXT PRIMARY KEY,
    vault_id TEXT NOT NULL,
    title TEXT NOT NULL,
    username TEXT,
    encrypted_password TEXT NOT NULL,
    url TEXT,
    notes TEXT,
    tags TEXT, -- JSON array
    custom_fields TEXT, -- JSON object
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE
);
```

**tasks**
```sql
CREATE TABLE tasks (
    id TEXT PRIMARY KEY,
    vault_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending',
    priority TEXT DEFAULT 'medium',
    due_date DATETIME,
    tags TEXT, -- JSON array
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE
);
```

**users**
```sql
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login_at DATETIME
);
```

### Indexes

- `idx_passwords_vault_id` - Fast password lookups by vault
- `idx_passwords_title` - Search by title
- `idx_tasks_vault_id` - Fast task lookups by vault
- `idx_tasks_status` - Filter by status
- `idx_tasks_due_date` - Sort/filter by due date
- `idx_users_username` - Login lookups

## Performance Characteristics

- **Read**: O(log n) with indexes
- **Write**: O(log n) for indexed inserts
- **Search**: O(log n) with proper indexes
- **Concurrent Access**: Full ACID support with proper locking
- **Storage Size**: ~20% larger than raw JSON due to indexes

**Best for**: Production deployments, large datasets, concurrent access, complex queries

## Configuration

```go
import "github.com/tip/pkg/storage/sqlite"

store, err := sqlite.NewStorage(sqlite.Options{
    DatabasePath: "~/.tip/data/tip.db",
    MaxOpenConns: 25,
    MaxIdleConns: 10,
    EnableWAL: true,  // Write-Ahead Logging for better concurrency
})
```

## Connection Pooling

The adapter manages a connection pool for optimal performance:
- Configurable max open/idle connections
- Connection lifetime management
- Prepared statement caching

## Transactions

All multi-operation updates use transactions for consistency:

```go
err := store.WithTransaction(func(tx sqlite.Tx) error {
    // All operations in this block are atomic
    if err := tx.CreatePassword(password); err != nil {
        return err
    }
    if err := tx.LogAuditEvent(event); err != nil {
        return err
    }
    return nil
})
```

## Backup and Restore

```go
// Create backup
err := store.Backup("backup_2024_01_01.db")

// Restore from backup
err := store.Restore("backup_2024_01_01.db")
```

## Migration System

Database schema is versioned and migrates automatically:
- Migrations run on startup
- Version tracking in `schema_migrations` table
- Backward-compatible migrations only
- Failed migrations prevent startup

## Encryption at Rest

Sensitive fields are encrypted before storage:
- Password fields encrypted with AES-256-GCM
- Encryption keys derived from vault master password
- Non-sensitive metadata stored plaintext for querying
