# Architecture

## Project Structure

```
tip/
├── cmd/
│   ├── tip/                 # CLI application
│   │   ├── main.go          # CLI entry point
│   │   ├── commands/        # Command implementations
│   │   │   ├── task.go      # Task management commands
│   │   │   ├── password.go  # Password management commands
│   │   │   ├── config.go    # Configuration commands
│   │   │   └── auth.go      # Authentication commands
│   │   └── main_test.go
│   └── server/              # Web server application
│       ├── main.go          # Server entry point
│       ├── api/             # API route handlers
│       │   ├── v1/          # API version 1
│       │   │   ├── auth.go  # Authentication endpoints
│       │   │   ├── passwords.go # Password endpoints
│       │   │   ├── tasks.go # Task endpoints
│       │   │   └── users.go # User management
│       │   └── middleware.go # HTTP middleware
│       └── main_test.go
├── pkg/
│   ├── core/                # Shared business logic
│   │   ├── models.go        # Data structures and models
│   │   ├── task.go          # Task manager implementation
│   │   ├── password.go      # Password manager implementation
│   │   ├── crypto.go        # Encryption/decryption utilities
│   │   ├── generator.go     # Password generation utilities
│   │   └── validator.go     # Input validation
│   ├── storage/             # Storage abstraction layer
│   │   ├── interfaces.go    # Storage interface definitions
│   │   ├── json/            # JSON file storage
│   │   │   ├── storage.go   # JSON storage implementation
│   │   │   └── migration.go # JSON migration utilities
│   │   ├── sqlite/          # SQLite database storage
│   │   │   ├── storage.go   # SQLite storage implementation
│   │   │   ├── schema.go    # Database schema
│   │   │   └── migration.go # SQLite migration utilities
│   │   └── remote/          # Remote API storage
│   │       ├── client.go    # HTTP client implementation
│   │       ├── auth.go      # Remote authentication
│   │       └── sync.go      # Synchronization logic
│   ├── config/              # Configuration management
│   │   ├── config.go        # Configuration structures
│   │   ├── loader.go        # Configuration loading
│   │   └── validator.go     # Configuration validation
│   └── utils/               # Utility functions
│       ├── terminal.go      # Terminal interaction utilities
│       ├── crypto.go        # Cryptographic helper functions
│       └── logger.go        # Logging utilities
├── internal/                # Internal packages (not exported)
│   ├── database/            # Database management
│   │   ├── connection.go    # Database connection handling
│   │   ├── migrations/      # Database migrations
│   │   └── queries.go       # Common database queries
│   └── auth/                # Authentication internals
│       ├── jwt.go           # JWT token management
│       ├── hash.go          # Password hashing
│       └── session.go       # Session management
├── web/                     # Web platform (future)
│   ├── frontend/            # Frontend application
│   │   ├── src/             # Source code
│   │   ├── public/          # Static assets
│   │   └── package.json     # Dependencies
│   └── extension/           # Browser extension
│       ├── manifest.json    # Extension manifest
│       └── src/             # Extension source
├── docs/                    # Documentation
├── scripts/                 # Build and deployment scripts
├── tests/                   # Integration and end-to-end tests
├── tip.go                   # Task manager core (legacy, to be refactored)
├── tip_test.go              # Task manager tests (legacy)
├── go.mod
├── go.sum
├── .gitignore
├── LICENSE
├── Dockerfile               # Docker configuration
├── docker-compose.yml       # Docker compose setup
└── README.md
```
tip/
├── cmd/
│   └── tip/
│       ├── main.go          (CLI entry point)
│       └── main_test.go
├── pkg/
│   ├── core/                # Shared business logic
│   │   ├── task.go          # Task manager
│   │   ├── password.go      # Password manager
│   │   └── crypto.go        # Encryption utilities
│   ├── storage/             # Storage layer
│   │   ├── local.go         # Local file storage
│   │   ├── remote.go        # Remote API client
│   │   └── interfaces.go    # Storage abstractions
│   └── api/                 # Server API
│       ├── server.go        # HTTP server
│       ├── handlers.go      # API handlers
│       └── middleware.go    # Auth, logging, etc.
├── docs/                    # Documentation
├── tip.go                   # Task manager core (to be refactored)
├── tip_test.go              # Task manager tests
├── go.mod
├── .gitignore
├── LICENSE
└── README.md
```

## Current Implementation

### Task Manager Core (`tip.go`)
- `item` struct: Task with ID, task name, done status, timestamps
- `List` type: Slice of items with methods
- Methods:
  - `Add(task string)` - Add new task
  - `Complete(id int)` - Mark task as done
  - `Delete(id int)` - Remove task
  - `Save(filename string)` - Persist to JSON
  - `Get(filename string)` - Load from JSON

### Storage
- JSON file format
- Flat file storage
- No encryption currently

## Detailed Architecture

### Core Components

#### 1. Business Logic Layer (`pkg/core/`)

**Models (`models.go`)**
```go
type Vault struct {
    ID          string      `json:"id"`
    Name        string      `json:"name"`
    CreatedAt   time.Time   `json:"created_at"`
    UpdatedAt   time.Time   `json:"updated_at"`
    Passwords   []Password  `json:"passwords"`
    Tasks       []Task      `json:"tasks"`
    Metadata    VaultMeta   `json:"metadata"`
}

type Password struct {
    ID          string            `json:"id"`
    Name        string            `json:"name"`
    Username    string            `json:"username"`
    Password    string            `json:"password"` // Encrypted
    URL         string            `json:"url"`
    Notes       string            `json:"notes"`
    Category    string            `json:"category"`
    Tags        []string          `json:"tags"`
    CreatedAt   time.Time         `json:"created_at"`
    UpdatedAt   time.Time         `json:"updated_at"`
    LastUsed    time.Time         `json:"last_used"`
    CustomFields map[string]string `json:"custom_fields"`
}

type Task struct {
    ID          string    `json:"id"`
    Title       string    `json:"title"`
    Description string    `json:"description"`
    Status      string    `json:"status"` // pending, in_progress, completed
    Priority    string    `json:"priority"` // low, medium, high
    DueDate     time.Time `json:"due_date"`
    AssignedTo  string    `json:"assigned_to"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
    CompletedAt time.Time `json:"completed_at"`
}
```

**Task Manager (`task.go`)**
- Refactored from existing `tip.go`
- Enhanced with categories, priorities, due dates
- Support for task assignments and collaboration
- Full CRUD operations with validation

**Password Manager (`password.go`)**
- Complete password lifecycle management
- Password generation with customizable rules
- Secure password sharing capabilities
- Audit trail for all password operations

**Cryptography (`crypto.go`)**
- AES-256-GCM encryption for data at rest
- Argon2id key derivation from master password
- Secure random number generation
- Memory-safe cryptographic operations

**Password Generator (`generator.go`)**
- Configurable password generation
- Support for passphrases and PINs
- Password strength evaluation
- Custom generation rules per category

#### 2. Storage Abstraction Layer (`pkg/storage/`)

**Storage Interface (`interfaces.go`)**
```go
type Storage interface {
    // Vault operations
    CreateVault(vault *Vault) error
    GetVault(id string) (*Vault, error)
    UpdateVault(vault *Vault) error
    DeleteVault(id string) error
    ListVaults() ([]*Vault, error)
    
    // Password operations
    CreatePassword(vaultID string, password *Password) error
    GetPassword(vaultID, id string) (*Password, error)
    UpdatePassword(vaultID string, password *Password) error
    DeletePassword(vaultID, id string) error
    ListPasswords(vaultID string) ([]*Password, error)
    SearchPasswords(vaultID, query string) ([]*Password, error)
    
    // Task operations
    CreateTask(vaultID string, task *Task) error
    GetTask(vaultID, id string) (*Task, error)
    UpdateTask(vaultID string, task *Task) error
    DeleteTask(vaultID, id string) error
    ListTasks(vaultID string) ([]*Task, error)
    SearchTasks(vaultID, query string) ([]*Task, error)
    
    // Sync operations
    GetLastModified(vaultID string) (time.Time, error)
    SetLastModified(vaultID string, timestamp time.Time) error
}
```

**JSON Storage (`json/storage.go`)**
- File-based storage with atomic writes
- JSON schema validation
- Backup and restore functionality
- Migration utilities between versions

**SQLite Storage (`sqlite/storage.go`)**
- Database connection pooling
- Prepared statements for performance
- Transaction support for consistency
- Full-text search capabilities

**Remote Storage (`remote/client.go`)**
- HTTP client with retry logic
- Authentication token management
- Offline mode support with caching
- Conflict resolution strategies

#### 3. Configuration Management (`pkg/config/`)

**Configuration Structure**
```go
type Config struct {
    // General settings
    AppName     string `yaml:"app_name"`
    Version     string `yaml:"version"`
    Debug       bool   `yaml:"debug"`
    
    // Storage settings
    Storage     StorageConfig `yaml:"storage"`
    
    // Security settings
    Security    SecurityConfig `yaml:"security"`
    
    // Server settings (remote mode)
    Server      ServerConfig `yaml:"server"`
    
    // CLI settings
    CLI         CLIConfig `yaml:"cli"`
}

type StorageConfig struct {
    Backend     string `yaml:"backend"` // json, sqlite, remote
    Path        string `yaml:"path"`
    Encryption  bool   `yaml:"encryption"`
    Backup      bool   `yaml:"backup"`
    BackupPath  string `yaml:"backup_path"`
}

type SecurityConfig struct {
    MasterPasswordRequired bool `yaml:"master_password_required"`
    AutoLockMinutes       int  `yaml:"auto_lock_minutes"`
    MemoryProtection      bool `yaml:"memory_protection"`
    AuditLogging          bool `yaml:"audit_logging"`
}
```

#### 4. Server Infrastructure (`cmd/server/`)

**HTTP Server (`main.go`)**
- Graceful shutdown handling
- Request logging and metrics
- Rate limiting and throttling
- Health check endpoints

**API Handlers (`api/v1/`)**
- RESTful API design
- Request/response validation
- Error handling and status codes
- API versioning support

**Authentication (`middleware.go`)**
- JWT token validation
- Refresh token rotation
- Session management
- CORS handling

### Data Flow Architecture

#### Local Mode (JSON Storage)
```
CLI Command
    ↓
Configuration Loader
    ↓
Storage Interface (JSON)
    ↓
Encryption Layer
    ↓
File System (Encrypted JSON)
    ↓
Response to CLI
```

#### Local Mode (SQLite Storage)
```
CLI Command
    ↓
Configuration Loader
    ↓
Storage Interface (SQLite)
    ↓
Encryption Layer
    ↓
Database (Encrypted SQLite)
    ↓
Response to CLI
```

#### Remote Mode
```
CLI Command
    ↓
Configuration Loader
    ↓
Storage Interface (Remote)
    ↓
HTTP Client (with Auth)
    ↓
Server API
    ↓
Authentication Middleware
    ↓
Business Logic
    ↓
Database (SQLite)
    ↓
Encrypted Response
    ↓
CLI Response
```

### Security Architecture

#### Encryption Flow
```
Master Password
    ↓
Argon2id Key Derivation
    ↓
Encryption Key (32 bytes)
    ↓
AES-256-GCM Encryption
    ↓
Encrypted Data Storage
```

#### Authentication Flow
```
User Credentials
    ↓
Server Authentication
    ↓
JWT Token Generation
    ↓
Client Token Storage
    ↓
API Request with Token
    ↓
Token Validation
    ↓
Authorized Access
```

### Performance Considerations

#### Caching Strategy
- **In-Memory Cache**: Frequently accessed vaults
- **File System Cache**: Encrypted data caching
- **Database Cache**: Query result caching
- **HTTP Cache**: API response caching

#### Optimization Techniques
- **Lazy Loading**: Load data on demand
- **Batch Operations**: Group multiple operations
- **Connection Pooling**: Database connection reuse
- **Compression**: Reduce storage and bandwidth

### Error Handling Strategy

#### Error Categories
- **Validation Errors**: Input validation failures
- **Authentication Errors**: Auth/authorization failures
- **Storage Errors**: Database/file system errors
- **Network Errors**: HTTP client/server errors
- **Encryption Errors**: Cryptographic operation failures

#### Error Response Format
```go
type ErrorResponse struct {
    Code      string    `json:"code"`
    Message   string    `json:"message"`
    Details   string    `json:"details,omitempty"`
    Timestamp time.Time `json:"timestamp"`
    RequestID string    `json:"request_id,omitempty"`
}
```

### Storage Options

#### Option A: Unified Storage
- Single encrypted vault containing both passwords and tasks
- Master password required for all operations
- Simplified backup/restore

#### Option B: Separated Storage
- Passwords in encrypted vault
- Tasks in separate (possibly unencrypted) storage
- Independent access control

#### Option C: Database Storage
- SQLite or similar database
- Separate tables for passwords and tasks
- More complex but more flexible queries

### Security Considerations

#### Encryption
- AES-256 for data at rest
- Argon2id for key derivation from master password
- Secure random salts

#### Authentication
- Master password as primary auth
- Optional key file for 2FA
- Session management for CLI

#### Data Protection
- Memory wiping after operations
- Secure password input (no echo, hidden from history)
- No plaintext logging of sensitive data

## Command Line Interface Design

### Command Structure Reference

#### Global Structure
```
tip <global-flags> <command> <subcommand> [args] [flags]
```

#### Global Flags
```
--config <path>     # Configuration file path
--mode <local|remote> # Operation mode
--storage <json|sqlite> # Storage backend
--vault <name>      # Vault name (multi-vault support)
--verbose           # Verbose output
--quiet             # Minimal output
--help              # Show help
--version           # Show version
```

#### Configuration Commands
```
tip config init                    # Initialize configuration
tip config show                    # Show current configuration
tip config set <key> <value>       # Set configuration value
tip config get <key>               # Get configuration value
tip config reset                   # Reset to defaults
```

#### Vault Management
```
tip vault init <name>              # Initialize new vault
tip vault list                     # List all vaults
tip vault switch <name>           # Switch to vault
tip vault delete <name>           # Delete vault
tip vault backup <path>           # Backup vault
tip vault restore <path>          # Restore vault
tip vault info                     # Show vault information
```

#### Authentication Commands
```
tip auth login                     # Login to remote server (OAuth)
tip auth logout                    # Logout from remote server
tip auth status                    # Show authentication status
tip auth refresh                   # Refresh authentication token
tip unlock                         # Unlock local vault
tip lock                           # Lock local vault
```

#### Password Management Commands
```
# Basic CRUD
tip password add <name>            # Add new password
tip password get <name>            # Get password details
tip password edit <name>           # Edit password
tip password delete <name>        # Delete password
tip password list                  # List all passwords

# Advanced features
tip password search <query>       # Search passwords
tip password generate              # Generate password
tip password copy <name>           # Copy password to clipboard
tip password share <name> <user>   # Share password with user

# Organization
tip password category list         # List categories
tip password category add <name>  # Add category
tip password tag list              # List tags
tip password tag add <name> <tag>  # Add tag to password
```

#### Task Management Commands
```
# Basic CRUD
tip task add "description"         # Add new task
tip task list                      # List all tasks
tip task get <id>                  # Get task details
tip task edit <id>                 # Edit task
tip task delete <id>               # Delete task

# Task operations
tip task complete <id>             # Mark task as complete
tip task start <id>                # Mark task as in progress
tip task assign <id> <user>        # Assign task to user

# Organization
tip task list --status pending     # List tasks by status
tip task list --priority high      # List tasks by priority
tip task list --due today          # List tasks due today
```

#### Token Management Commands
```
tip token create                   # Create CLI access token
tip token list                     # List active tokens
tip token revoke <id>              # Revoke token
tip token info <id>                # Get token details
```

#### Category Management Commands
```
tip category list                  # List categories
tip category add <name>            # Add new category
tip category delete <name>         # Delete category
```

#### Synchronization Commands
```
tip sync                           # Sync with remote server
tip sync status                    # Show sync status
tip sync force                     # Force full sync
tip export <format>                # Export data (json, csv)
tip import <file>                  # Import data
```
tip <global-flags> <command> <subcommand> [args] [flags]
```

#### Global Flags
```
--config <path>     # Configuration file path
--mode <local|remote> # Operation mode
--storage <json|sqlite> # Storage backend
--vault <name>      # Vault name (multi-vault support)
--verbose           # Verbose output
--quiet             # Minimal output
--help              # Show help
--version           # Show version
```

#### Configuration Commands
```
tip config init                    # Initialize configuration
tip config show                    # Show current configuration
tip config set <key> <value>       # Set configuration value
tip config get <key>               # Get configuration value
tip config reset                   # Reset to defaults
```

#### Vault Management
```
tip vault init <name>              # Initialize new vault
tip vault list                     # List all vaults
tip vault switch <name>           # Switch to vault
tip vault delete <name>           # Delete vault
tip vault backup <path>           # Backup vault
tip vault restore <path>          # Restore vault
tip vault info                     # Show vault information
```

#### Authentication Commands
```
tip auth login                     # Login to remote server (OAuth)
tip auth logout                    # Logout from remote server
tip auth status                    # Show authentication status
tip auth refresh                   # Refresh authentication token
tip unlock                         # Unlock local vault
tip lock                           # Lock local vault
```

#### Password Management Commands
```
tip password add <name>            # Add new password
tip password get <name>            # Get password details
tip password edit <name>           # Edit password
tip password delete <name>        # Delete password
tip password list                  # List all passwords
tip password search <query>       # Search passwords
tip password generate              # Generate password
tip password copy <name>           # Copy password to clipboard
```

#### Task Management Commands
```
tip task add "description"         # Add new task
tip task list                      # List all tasks
tip task get <id>                  # Get task details
tip task edit <id>                 # Edit task
tip task delete <id>               # Delete task
tip task complete <id>             # Mark task as complete
tip task start <id>                # Mark task as in progress
```

#### Token Management Commands
```
tip token create                   # Create CLI access token
tip token list                     # List active tokens
tip token revoke <id>              # Revoke token
tip token info <id>                # Get token details
```

#### Category Management Commands
```
tip category list                  # List categories
tip category add <name>            # Add new category
tip category delete <name>         # Delete category
```

#### Synchronization Commands
```
tip sync                           # Sync with remote server
tip sync status                    # Show sync status
tip sync force                     # Force full sync
```

#### Data Management Commands
```
tip export <format>                # Export data (json, csv)
tip import <file>                  # Import data
tip backup                         # Create backup
tip restore <path>                 # Restore backup
```

## Server API Design

### API Versioning
```
Base URL: https://tip.example.com/api/v1
Headers: Authorization: Bearer <token>
Content-Type: application/json
```

### Authentication Endpoints
```
GET    /auth/oauth/github           # GitHub OAuth login
GET    /auth/oauth/google           # Google OAuth login
GET    /auth/oauth/callback         # OAuth callback
POST   /auth/login                  # Direct login (email/password)
POST   /auth/logout                 # User logout
POST   /auth/refresh                # Refresh JWT token
GET    /auth/profile                # Get user profile
PUT    /auth/profile                # Update user profile
```

### Token Management Endpoints
```
GET    /auth/tokens                 # List active CLI tokens
POST   /auth/tokens                 # Create new CLI token
DELETE /auth/tokens/:id             # Revoke CLI token
PUT    /auth/tokens/:id             # Update token (extend expiry)
```

### Vault Management Endpoints
```
GET    /vaults                     # List user vaults
POST   /vaults                     # Create new vault
GET    /vaults/:id                 # Get vault details
PUT    /vaults/:id                 # Update vault
DELETE /vaults/:id                 # Delete vault
POST   /vaults/:id/backup          # Backup vault
POST   /vaults/:id/restore         # Restore vault
```

### Password Management Endpoints
```
GET    /vaults/:vaultId/passwords  # List passwords
POST   /vaults/:vaultId/passwords  # Create password
GET    /vaults/:vaultId/passwords/:id # Get password
PUT    /vaults/:vaultId/passwords/:id # Update password
DELETE /vaults/:vaultId/passwords/:id # Delete password
GET    /vaults/:vaultId/passwords/search # Search passwords
POST   /vaults/:vaultId/passwords/generate # Generate password
POST   /vaults/:vaultId/passwords/:id/share # Share password
```

### Task Management Endpoints
```
GET    /vaults/:vaultId/tasks      # List tasks
POST   /vaults/:vaultId/tasks      # Create task
GET    /vaults/:vaultId/tasks/:id  # Get task
PUT    /vaults/:vaultId/tasks/:id  # Update task
DELETE /vaults/:vaultId/tasks/:id  # Delete task
POST   /vaults/:vaultId/tasks/:id/complete # Complete task
POST   /vaults/:vaultId/tasks/:id/assign   # Assign task
```

### Synchronization Endpoints
```
GET    /sync/status                # Get sync status
POST   /sync/full                   # Full synchronization
POST   /sync/incremental            # Incremental sync
GET    /sync/last-modified/:vaultId # Get last modified timestamp
```

### API Response Format
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2025-01-08T10:00:00Z",
    "request_id": "req_123456789",
    "version": "v1"
  },
  "errors": []
}
```

## Technology Stack

### CLI Application
- **Language**: Go 1.24+
- **CLI Framework**: Cobra (command parsing)
- **Configuration**: Viper (config management)
- **HTTP Client**: net/http with custom retry logic
- **Terminal**: termios for secure input
- **Crypto**: golang.org/x/crypto (argon2, aes)
- **Testing**: Testify for assertions

### Web Server
- **Language**: Go 1.24+
- **HTTP Router**: Chi (lightweight, middleware-focused)
- **OAuth**: golang.org/x/oauth2 (GitHub, Google)
- **Authentication**: golang-jwt/jwt
- **Database**: SQLite with modernc.org/sqlite driver
- **Validation**: go-playground/validator
- **Logging**: logrus or zap
- **Metrics**: Prometheus client library
- **CORS**: chi/middleware CORS handler

### Database
- **Primary**: SQLite (embedded, reliable)
- **Migrations**: golang-migrate/migrate
- **Connection Pooling**: database/sql stdlib
- **Query Builder**: squirrel (optional)

### Security
- **Encryption**: AES-256-GCM (crypto/aes)
- **Key Derivation**: Argon2id (golang.org/x/crypto/argon2)
- **Random**: crypto/rand
- **TLS**: Let's Encrypt with cert-manager

### Development Tools
- **Testing**: Go testing + Testify
- **Linting**: golangci-lint
- **Formatting**: gofmt, goimports
- **Documentation**: godoc
- **Build**: Mage or Makefile
- **Containerization**: Docker + Docker Compose

### Web Platform (Future)
- **Frontend**: Next.js (React-based)
- **Styling**: Tailwind CSS
- **State Management**: Zustand or Redux Toolkit
- **HTTP Client**: Axios or Fetch API
- **Real-time**: WebSockets with Socket.io
- **Build**: Vite or Next.js build system

## Deployment Architecture

### Local Development
```
Docker Compose
├── tip-cli (build)
├── tip-server (build)
├── SQLite (volume)
└── Redis (optional)
```

### Production Deployment
```
Kubernetes / Docker Swarm
├── tip-server (replicated)
├── SQLite (persistent volume)
├── Redis (cluster)
├── Nginx (reverse proxy)
└── Let's Encrypt (TLS)
```

### Monitoring & Observability
- **Health Checks**: /health, /ready endpoints
- **Metrics**: Prometheus metrics endpoint
- **Logging**: Structured JSON logs
- **Tracing**: OpenTelemetry (optional)
- **Alerting**: Prometheus AlertManager

## Design Decisions Made

1. **CLI Framework**: Cobra confirmed with simplified command structure
2. **HTTP Router**: Chi confirmed for lightweight, middleware-focused approach
3. **Database**: SQLite confirmed with embedded deployment
4. **Authentication**: OAuth (GitHub/Google) + JWT for API access
5. **Token Management**: CLI tokens with expiration and revocation
6. **Feature Focus**: Essential features only, not full 1Password replacement
7. **Web Platform**: Dashboard for viewing data and managing tokens only

### Implementation Priorities

1. **Core CLI**: Structured commands with comprehensive functionality
2. **Essential Security**: Master password + OAuth + token management
3. **Multi-Vault Support**: Complete vault lifecycle management
4. **Storage Flexibility**: JSON/SQLite with mode switching
5. **Web Dashboard**: OAuth login + token management + data viewing

### OAuth Integration Flow

1. **User Login**: Redirect to GitHub/Google OAuth
2. **Authorization**: User grants access to Tip application
3. **Token Creation**: Server creates JWT with user info
4. **CLI Access**: User generates CLI tokens via web dashboard
5. **API Usage**: CLI uses tokens for authenticated requests
6. **Token Management**: Web interface for token lifecycle

### Command Architecture Highlights

- **Hierarchical Structure**: Clear command grouping by functionality
- **Consistent Patterns**: Standard add/get/list/delete across all modules
- **Global Configuration**: Centralized settings with vault switching
- **Comprehensive Coverage**: All operations accessible via CLI
- **Multi-Mode Support**: Seamless local/remote mode switching
- **Advanced Features**: Categories, tags, search, sharing, sync

### Security & Architecture

- **Zero-Knowledge**: Server stores encrypted data only
- **OAuth Integration**: GitHub/Google authentication for web platform
- **Token-Based Access**: CLI tokens with expiration and revocation
- **End-to-End Encryption**: AES-256-GCM for all sensitive data
- **Multi-Tenant**: Isolated vaults per user/organization
- **Audit Trail**: Complete operation logging and tracking

#### Global Configuration
- **Centralized Config**: Single configuration file manages all settings
- **Mode Switching**: Seamless transition between local and remote modes
- **Storage Backend**: Runtime switching between JSON and SQLite
- **Verbose Control**: Detailed logging when needed, quiet mode for automation

#### Vault Management
- **Multi-Vault Support**: Organize passwords and tasks by project/client
- **Isolation**: Each vault has separate encryption and authentication
- **Backup/Restore**: Complete vault backup and migration capabilities
- **Vault Switching**: Quick context switching between vaults

#### Authentication Strategy
- **OAuth Integration**: GitHub and Google login for web platform
- **Token Management**: Separate CLI tokens for automated access
- **Local Security**: Master password for local vault access
- **Session Management**: Secure token refresh and revocation

#### Security Features
- **Encryption**: End-to-end encryption for all sensitive data
- **Token Security**: Expiring tokens with revocation capability
- **Memory Protection**: Secure handling of sensitive information
- **Audit Trail**: Complete logging of all operations
