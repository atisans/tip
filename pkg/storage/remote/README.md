# Remote Storage Client

HTTP client for remote Tip server storage synchronization.

## Overview

This package implements the client-side storage interface for communicating with a remote Tip server via REST API. It enables cloud synchronization, multi-device access, and collaboration features.

## Features

- Full REST API client implementation
- Automatic authentication token management
- Exponential backoff retry logic
- Offline mode with local caching
- Conflict detection and resolution
- Bandwidth-efficient sync (delta updates)
- Request/response logging and debugging

## Architecture

The remote storage adapter implements the same storage interface as local adapters:

```go
type Storage interface {
    ListVaults() ([]core.Vault, error)
    GetVault(id string) (*core.Vault, error)
    CreateVault(vault *core.Vault) error
    UpdateVault(vault *core.Vault) error
    DeleteVault(id string) error
    
    ListPasswords(vaultID string) ([]core.Password, error)
    GetPassword(id string) (*core.Password, error)
    CreatePassword(password *core.Password) error
    UpdatePassword(password *core.Password) error
    DeletePassword(id string) error
    
    // ... task methods
}
```

This allows seamless switching between local and remote storage.

## Authentication

### Token Management
- JWT access tokens for API requests
- Refresh tokens for session continuity
- Automatic token refresh before expiry
- Secure token storage (keyring/os-specific)

### Authentication Flow
```go
client := remote.NewClient(remote.Options{
    ServerURL: "https://api.tip.io",
})

// Login
err := client.Authenticate("username", "password")

// Token is automatically used for subsequent requests
vaults, err := client.ListVaults()
```

## Offline Support

### Cache Strategy
- Recent data cached locally in SQLite
- Read operations served from cache when offline
- Write operations queued for sync when online
- Automatic conflict resolution on reconnection

### Sync Process
1. **Pull phase**: Download server changes
2. **Merge phase**: Resolve conflicts
3. **Push phase**: Upload local changes
4. **Commit phase**: Update local cache

## Error Handling

### Retry Logic
- Exponential backoff for transient errors
- Maximum retry count: 3
- Retry on: 5xx errors, network timeouts
- No retry on: 4xx errors, authentication failures

### Network Errors
```go
vaults, err := client.ListVaults()
if err != nil {
    if errors.Is(err, remote.ErrOffline) {
        // Handle offline mode
    } else if errors.Is(err, remote.ErrUnauthorized) {
        // Re-authenticate
    }
}
```

## Configuration

```go
client := remote.NewClient(remote.Options{
    ServerURL:       "https://api.tip.io",
    Timeout:         30 * time.Second,
    MaxRetries:      3,
    EnableCache:     true,
    CacheDirectory:  "~/.tip/cache",
    AutoSync:        true,
    SyncInterval:    5 * time.Minute,
})
```

## Conflict Resolution

When the same item is modified on multiple devices:

1. **Server wins**: Remote changes override local (default)
2. **Local wins**: Local changes override remote
3. **Manual**: User decides which version to keep
4. **Merge**: Combine non-conflicting changes

```go
client.SetConflictStrategy(remote.ConflictMerge)
```

## Performance

- **Connection pooling**: Reuse HTTP connections
- **Compression**: gzip for request/response bodies
- **Delta sync**: Only transfer changed fields
- **Batch operations**: Multiple items per request
- **ETags**: Conditional requests to avoid re-downloads

## Security

- TLS 1.3 for all connections
- Certificate pinning (optional)
- Request signing for sensitive operations
- No plaintext password storage in cache
- Secure memory handling for tokens
