# API v1 Package

RESTful API v1 endpoints for the Tip server.

## Overview

This package implements the version 1 REST API for the Tip password and task management server.

## API Design

The API follows RESTful principles with the following conventions:
- JSON request/response format
- HTTP status codes for error handling
- JWT authentication via Authorization header
- Resource-based URL structure

## Endpoints

### Authentication
```
POST   /api/v1/auth/register     - Register new user
POST   /api/v1/auth/login        - User login
POST   /api/v1/auth/logout       - User logout
POST   /api/v1/auth/refresh      - Refresh access token
```

### Vault Management
```
GET    /api/v1/vaults            - List user vaults
POST   /api/v1/vaults            - Create new vault
GET    /api/v1/vaults/{id}       - Get vault details
PUT    /api/v1/vaults/{id}       - Update vault
DELETE /api/v1/vaults/{id}       - Delete vault
```

### Password Management
```
GET    /api/v1/vaults/{id}/passwords       - List passwords
POST   /api/v1/vaults/{id}/passwords       - Add password
GET    /api/v1/passwords/{id}              - Get password
PUT    /api/v1/passwords/{id}              - Update password
DELETE /api/v1/passwords/{id}              - Delete password
POST   /api/v1/passwords/{id}/share        - Share password
```

### Task Management
```
GET    /api/v1/vaults/{id}/tasks   - List tasks
POST   /api/v1/vaults/{id}/tasks   - Create task
GET    /api/v1/tasks/{id}          - Get task
PUT    /api/v1/tasks/{id}          - Update task
DELETE /api/v1/tasks/{id}          - Delete task
POST   /api/v1/tasks/{id}/complete - Mark complete
```

### Synchronization
```
GET    /api/v1/sync/status         - Get sync status
POST   /api/v1/sync/changes        - Get changes since timestamp
POST   /api/v1/sync/push           - Push local changes
```

## Authentication

All endpoints (except auth endpoints) require a valid JWT token:

```
Authorization: Bearer <jwt_token>
```

## Error Responses

```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Username or password is incorrect",
    "details": {}
  }
}
```

## Implementation Notes

- Uses Chi router for HTTP handling
- Middleware for authentication, logging, and rate limiting
- Request validation using go-playground/validator
- Structured logging with zap
