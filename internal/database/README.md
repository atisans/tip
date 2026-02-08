# Database Package

Internal database management and utilities.

## Overview

This package contains internal database-related functionality that is not exposed through the public storage interface. It handles low-level database operations, connection management, and internal data access patterns.

## Purpose

This package is **internal** and should not be imported by external packages or CLI/server code directly. Use the `pkg/storage/sqlite` package instead for public storage operations.

## Responsibilities

### Connection Management
- Database connection pooling
- Connection lifecycle management
- Health checks and monitoring
- Failover and recovery

### Schema Management
- Migration execution
- Schema versioning
- Rollback procedures
- Schema validation

### Internal Data Access
- Raw SQL queries for complex operations
- Batch operations
- Database-specific optimizations
- Internal reporting queries

## Structure

```
internal/database/
├── connection.go    # Connection pool management
├── migrations/      # Database migrations
│   ├── 001_initial_schema.sql
│   ├── 002_add_indexes.sql
│   └── ...
├── queries.go       # Internal query builders
├── transactions.go  # Transaction helpers
└── README.md        # This file
```

## Migrations

Migrations are SQL files that update the database schema:

### Migration File Format
```sql
-- 001_initial_schema.sql
-- +migrate Up
CREATE TABLE vaults (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

-- +migrate Down
DROP TABLE vaults;
```

### Running Migrations

Migrations are automatically applied on startup by the storage layer. Manual migration:

```go
import "github.com/tip/internal/database"

err := database.Migrate(db, "up")
err := database.Migrate(db, "down")
err := database.MigrateTo(db, 5) // Migrate to specific version
```

## Connection Pool

```go
pool, err := database.NewPool(database.PoolConfig{
    MaxOpenConns: 25,
    MaxIdleConns: 10,
    ConnMaxLifetime: time.Hour,
})
```

## Internal Queries

For complex operations that don't fit the storage interface:

```go
// Get vault statistics
stats, err := database.GetVaultStats(ctx, db, vaultID)

// Batch update passwords
err := database.BatchUpdatePasswords(ctx, db, updates)

// Complex search with joins
results, err := database.SearchAcrossVaults(ctx, db, query)
```

## Testing

This package includes test helpers:

```go
// Create test database
db := database.NewTestDB(t)
defer db.Close()

// Reset database to known state
database.ResetTestDB(t, db)

// Load test fixtures
database.LoadFixtures(t, db, "testdata/fixtures.sql")
```

## Security

- All queries use parameterized statements to prevent SQL injection
- Sensitive data is encrypted before storage
- Connection strings never contain credentials in code
- Audit logging for sensitive operations

## Performance

- Prepared statements are cached and reused
- Bulk operations use transactions
- Indexes are maintained for common query patterns
- Query performance is monitored and logged
