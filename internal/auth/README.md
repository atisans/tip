# Authentication Package

Internal authentication and authorization logic.

## Overview

This package implements the authentication and authorization infrastructure for Tip. It handles user authentication, session management, password hashing, and access control.

## Purpose

This package is **internal** and should not be imported by external packages. Use the public APIs in `pkg/core` and `pkg/config` for authentication-related operations.

## Responsibilities

### Authentication
- User credential verification
- Password hashing and validation
- Multi-factor authentication (TOTP)
- Session token generation and validation

### Authorization
- Role-based access control (RBAC)
- Permission checking
- Resource-level access control
- Audit logging for auth events

### Security
- Argon2id password hashing
- JWT token management
- Secure session handling
- Rate limiting for auth attempts

## Architecture

### Components

```
internal/auth/
├── hasher.go          # Password hashing (Argon2id)
├── jwt.go              # JWT token management
├── session.go          # Session management
├── rbac.go             # Role-based access control
├── totp.go             # TOTP/2FA implementation
├── middleware.go       # HTTP middleware for auth
└── README.md           # This file
```

## Password Hashing

Uses Argon2id for secure password hashing:

```go
import "github.com/tip/internal/auth"

// Hash password
hash, err := auth.HashPassword("user_password")

// Verify password
valid, err := auth.VerifyPassword("user_password", hash)
```

### Argon2id Parameters
- Time: 3 iterations
- Memory: 64MB
- Parallelism: 4 threads
- Salt length: 16 bytes
- Key length: 32 bytes

## JWT Tokens

Token structure:
- Access tokens: 15 minute expiry
- Refresh tokens: 7 day expiry
- HS256 algorithm for signing

```go
// Generate tokens
accessToken, refreshToken, err := auth.GenerateTokens(userID)

// Validate token
claims, err := auth.ValidateToken(accessToken)

// Refresh access token
newAccessToken, err := auth.RefreshAccessToken(refreshToken)
```

## Session Management

Server-side session management:

```go
// Create session
session, err := auth.CreateSession(userID, clientInfo)

// Validate session
session, err := auth.GetSession(sessionID)

// Revoke session
err := auth.RevokeSession(sessionID)

// Revoke all user sessions
err := auth.RevokeAllUserSessions(userID)
```

## Role-Based Access Control

### Roles
- `admin`: Full system access
- `user`: Standard user access
- `viewer`: Read-only access
- `guest`: Limited access

### Permissions
Permissions are granular:
- `vault:create`, `vault:read`, `vault:update`, `vault:delete`
- `password:create`, `password:read`, `password:update`, `password:delete`
- `task:create`, `task:read`, `task:update`, `task:delete`

### Usage

```go
// Check permission
allowed := auth.HasPermission(userID, "password:delete", vaultID)

// Check role
isAdmin := auth.HasRole(userID, "admin")

// Get user permissions
perms, err := auth.GetUserPermissions(userID)
```

## TOTP/2FA

Time-based One-Time Password support:

```go
// Generate TOTP secret
secret, qrCode, err := auth.GenerateTOTPSecret(userID)

// Verify TOTP code
valid := auth.VerifyTOTP(userID, code)

// Enable 2FA
err := auth.Enable2FA(userID, secret, confirmedCode)

// Disable 2FA
err := auth.Disable2FA(userID, password)
```

## HTTP Middleware

For protecting HTTP endpoints:

```go
// Require authentication
router.Use(auth.RequireAuth())

// Require specific permission
router.With(auth.RequirePermission("vault:delete")).
    Delete("/api/v1/vaults/{id}", handler)

// Require admin role
router.With(auth.RequireRole("admin")).
    Get("/api/v1/admin/users", handler)
```

## Security Considerations

- All password hashes use salt
- Timing-safe comparison for secrets
- Rate limiting on auth endpoints
- Audit logging of all auth events
- Secure session storage
- CSRF protection for web endpoints
- Secure cookie settings (HttpOnly, Secure, SameSite)

## Testing

Test utilities provided:

```go
// Create test user with known password
user := auth.CreateTestUser(t, "username", "password")

// Generate test tokens
token := auth.GenerateTestToken(t, userID)

// Mock auth for testing
auth.MockAuthentication(t, userID, []string{"user"})
```
