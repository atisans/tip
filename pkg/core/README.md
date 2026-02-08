# Core Package

Core domain models and business logic for Tip.

## Overview

This package contains the fundamental domain types and business rules that define the Tip application's core functionality. It is framework-agnostic and has no external dependencies beyond the standard library.

## Domain Models

### Vault
Represents an encrypted container for passwords and tasks.

```go
type Vault struct {
    ID          string    `json:"id"`
    Name        string    `json:"name"`
    Description string    `json:"description"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
    OwnerID     string    `json:"owner_id"`
}
```

### Password
Represents a stored password entry.

```go
type Password struct {
    ID          string            `json:"id"`
    VaultID     string            `json:"vault_id"`
    Title       string            `json:"title"`
    Username    string            `json:"username"`
    Password    string            `json:"password"` // Encrypted
    URL         string            `json:"url"`
    Notes       string            `json:"notes"`
    Tags        []string          `json:"tags"`
    CustomFields map[string]string `json:"custom_fields"`
    CreatedAt   time.Time         `json:"created_at"`
    UpdatedAt   time.Time         `json:"updated_at"`
}
```

### Task
Represents a task or todo item.

```go
type Task struct {
    ID          string    `json:"id"`
    VaultID     string    `json:"vault_id"`
    Title       string    `json:"title"`
    Description string    `json:"description"`
    Status      TaskStatus `json:"status"`
    Priority    Priority  `json:"priority"`
    DueDate     *time.Time `json:"due_date,omitempty"`
    Tags        []string  `json:"tags"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
    CompletedAt *time.Time `json:"completed_at,omitempty"`
}
```

### User
Represents a user account.

```go
type User struct {
    ID           string    `json:"id"`
    Username     string    `json:"username"`
    Email        string    `json:"email"`
    PasswordHash string    `json:"-"` // Never serialized
    CreatedAt    time.Time `json:"created_at"`
    UpdatedAt    time.Time `json:"updated_at"`
    LastLoginAt  *time.Time `json:"last_login_at,omitempty"`
}
```

## Business Rules

### Password Management
- Passwords must be encrypted before storage
- Password strength is evaluated on creation
- Password history is tracked for auditing
- Passwords can be shared with other users

### Task Management
- Tasks can have priorities: Low, Medium, High, Critical
- Tasks can have statuses: Pending, In Progress, Completed, Cancelled
- Tasks support due dates and reminders
- Tasks can be filtered by tags, status, and priority

### Vault Management
- Vaults are encrypted with user master password
- Each vault has a unique encryption key
- Vaults support multiple users (collaboration)
- Vault access is controlled via permissions

## Usage

```go
import "github.com/tip/pkg/core"

// Create a new vault
vault := &core.Vault{
    Name: "Personal",
    Description: "My personal passwords",
}

// Create a password entry
password := &core.Password{
    VaultID: vault.ID,
    Title: "GitHub",
    Username: "john.doe",
    URL: "https://github.com",
}

// Create a task
task := &core.Task{
    VaultID: vault.ID,
    Title: "Update passwords",
    Priority: core.PriorityHigh,
}
```

## Testing

All domain models have comprehensive unit tests ensuring:
- Proper serialization/deserialization
- Validation rules
- Business logic correctness
- Edge case handling
