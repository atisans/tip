# Tip - Password Manager + Task Manager

## Project Vision
Tip is a comprehensive self-hosted platform that seamlessly integrates password management (similar to 1Password) with task management capabilities. The platform is designed with a multi-tier architecture that provides flexibility for different use cases while maintaining security and simplicity.

## Core Components

### 1. CLI Tool (`tip`)
A powerful command-line interface that operates in two distinct modes:
- **Local Mode**: Direct file/database access for offline-first usage
- **Remote Mode**: HTTP client communication with self-hosted server
- **Storage Flexibility**: JSON files or SQLite database backend
- **Security**: End-to-end encryption with master password protection

### 2. Web Server (`tip-server`)
Self-hosted backend service providing:
- **RESTful API**: Complete CRUD operations for passwords and tasks
- **OAuth Authentication**: GitHub and Google login integration
- **Token Management**: CLI access tokens with expiration
- **Dashboard API**: Web interface for data management
- **Multi-tenant**: Isolated vaults per user/organization
- **Database**: SQLite for simplicity and reliability
- **Real-time Sync**: Conflict resolution and data synchronization

### 3. Web Platform (`tip-web`)
Future browser-based interface offering:
- **Full UI**: Complete password and task management
- **Real-time Collaboration**: Live updates and sharing
- **Browser Extension**: Auto-fill and quick access
- **Mobile Responsive**: Cross-device compatibility

## Current Implementation Status

### Completed Components
- [x] **Task Manager Core** (`tip.go`)
  - [x] Complete CRUD operations for tasks
  - [x] JSON persistence with timestamps
  - [x] Comprehensive test suite (`tip_test.go`)
  - [x] Memory-efficient data structures

### Pending Components
- [ ] **Password Manager Core** - Encryption, CRUD, generation
- [ ] **Storage Layer** - JSON/SQLite adapters, remote client
- [ ] **CLI Interface** - Command parsing, configuration, modes
- [ ] **Web Server** - API, authentication, database
- [ ] **Web Platform** - Frontend, real-time features

## Key Design Principles

### Security First
- **Zero-Knowledge Architecture**: Server never sees unencrypted data
- **Master Password**: Single point of authentication with key derivation
- **End-to-End Encryption**: AES-256-GCM for data at rest and in transit
- **Secure Memory**: Automatic wiping of sensitive data from memory

### Flexibility & Choice
- **Storage Options**: JSON files for simplicity, SQLite for performance
- **Operation Modes**: Local for offline, Remote for collaboration
- **Deployment Options**: Self-hosted, Docker, or binary installation
- **Configuration**: Extensive customization via config files

### Developer Experience
- **Clean Architecture**: Separated concerns with clear interfaces
- **Comprehensive Testing**: Unit, integration, and end-to-end tests
- **Documentation**: Complete API docs and user guides
- **Extensibility**: Plugin system for custom features

## Target Use Cases

### Individual Users
- **Personal Password Vault**: Secure storage for all credentials
- **Task Management**: Personal to-do lists with reminders
- **Local Usage**: Offline-first with optional cloud sync
- **Cross-Device**: Sync between laptop, desktop, and mobile

### Teams & Organizations
- **Shared Passwords**: Encrypted sharing among team members
- **Collaborative Tasks**: Project management with assignments
- **Access Control**: Role-based permissions and audit logs
- **Self-Hosted**: Complete data ownership and control

### Developers & Power Users
- **CLI Integration**: Scriptable automation and workflows
- **API Access**: RESTful API for custom integrations
- **Configuration**: Fine-grained control over all aspects
- **Extensions**: Plugin system for custom functionality

## Technical Highlights

### Performance
- **Optimized Storage**: Efficient data structures and indexing
- **Caching**: Redis for frequently accessed data
- **Lazy Loading**: On-demand data retrieval
- **Compression**: Reduced storage and bandwidth usage

### Reliability
- **Atomic Operations**: Consistent data state
- **Backup/Restore**: Complete data export/import
- **Migration Tools**: Seamless upgrades and data migration
- **Health Monitoring**: Built-in diagnostics and metrics

### Compliance
- **Data Privacy**: GDPR-compliant data handling
- **Security Standards**: Industry best practices
- **Audit Trails**: Complete operation logging
- **Access Controls**: Granular permission management

## Task Manager Features (Implemented)
- [x] Add, complete, and delete tasks
- [x] JSON persistence (save/load from file)
- [x] Task tracking with timestamps (created/completed)
- [x] Full test coverage

## Password Manager Features (Essential)

### Core Functionality
- [x] **Quick Add**: `tip add github "username"` - Fast password creation
- [x] **Smart Search**: `tip find github` - Fuzzy matching by name/URL
- [x] **Categories**: Work, Personal, Development, Finance
- [x] **Password Generation**: Configurable rules (length, chars)
- [x] **Secure Notes**: Store additional sensitive information
- [x] **Clipboard Integration**: `tip copy github` - Copy to clipboard
- [x] **Import/Export**: CSV/JSON backup and migration

### Security Features
- [x] **Master Password**: Single authentication point
- [x] **Auto-Lock**: Configurable timeout (5, 15, 30 minutes)
- [x] **Password History**: Track last 5 password versions
- [x] **Audit Log**: Track all access and modifications
- [x] **Memory Protection**: Auto-wipe sensitive data

### Task Manager Features (Enhanced)
- [x] **Priority Levels**: Low, Medium, High, Critical
- [x] **Due Dates**: Natural language parsing ("tomorrow", "next friday")
- [x] **Quick Add**: `tip task "Fix bug" --high --due tomorrow`
- [x] **Categories**: Same categories as passwords
- [x] **Templates**: Reusable task patterns
- [x] **Progress Tracking**: Visual completion indicators

## Architecture Overview

### Multi-Tier Architecture

#### Tier 1: Client Applications
```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   CLI Tool      │  │   Web Platform  │  │ Browser Extension│
│   (tip)         │  │   (tip-web)     │  │   (future)       │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
                    ┌─────────────────┐
                    │   HTTP/HTTPS    │
                    │   Communication │
                    └─────────────────┘
```

#### Tier 2: Server Infrastructure
```
                    ┌─────────────────┐
                    │   Web Server    │
                    │   (tip-server)  │
                    └─────────────────┘
                               │
                    ┌─────────────────┐
                    │   Authentication│
                    │   (JWT/OAuth)   │
                    └─────────────────┘
                               │
                    ┌─────────────────┐
                    │   Business Logic│
                    │   (Core APIs)   │
                    └─────────────────┘
                               │
                    ┌─────────────────┐
                    │   Database      │
                    │   (SQLite)      │
                    └─────────────────┘
```

#### Tier 3: Storage Layer
```
                    ┌─────────────────┐
                    │   Storage       │
                    │   Abstraction   │
                    └─────────────────┘
                               │
         ┌─────────────────────┼─────────────────────┐
         │                     │                     │
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   JSON Files    │  │   SQLite DB     │  │   Remote API    │
│   (Local)       │  │   (Local/Server)│  │   (Server)      │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### Operation Modes

#### Local Mode (Offline-First)
```
CLI → Storage Interface → JSON/SQLite → Encrypted Vault
```
- **Data Flow**: Direct local storage access
- **Encryption**: Client-side encryption before storage
- **Performance**: Maximum speed, no network latency
- **Security**: Data never leaves user's machine
- **Use Case**: Personal usage, high-security environments

#### Remote Mode (Collaborative)
```
CLI → HTTP Client → Server API → Authentication → Database
```
- **Data Flow**: Encrypted data sent to server
- **Encryption**: End-to-end encryption, server stores encrypted data
- **Performance**: Network latency but enables collaboration
- **Security**: Zero-knowledge architecture
- **Use Case**: Team collaboration, multi-device sync

#### Hybrid Mode (Best of Both)
```
CLI → Local Cache → Remote Sync → Conflict Resolution
```
- **Data Flow**: Local storage with periodic remote sync
- **Encryption**: Local encryption + remote encrypted backup
- **Performance**: Local speed with remote reliability
- **Security**: Redundant encrypted storage
- **Use Case**: Power users, reliability requirements

## Feature Matrix

### Password Management
| Feature | Local Mode | Remote Mode | Web Platform |
|---------|------------|-------------|--------------|
| Add Password | ✅ | ✅ | ✅ |
| Edit Password | ✅ | ✅ | ✅ |
| Delete Password | ✅ | ✅ | ✅ |
| Search Passwords | ✅ | ✅ | ✅ |
| Generate Password | ✅ | ✅ | ✅ |
| Categories/Tags | ✅ | ✅ | ✅ |
| Secure Sharing | ❌ | ✅ | ✅ |
| Audit Logs | ✅ | ✅ | ✅ |
| Import/Export | ✅ | ✅ | ✅ |

### Task Management
| Feature | Local Mode | Remote Mode | Web Platform |
|---------|------------|-------------|--------------|
| Add Task | ✅ | ✅ | ✅ |
| Complete Task | ✅ | ✅ | ✅ |
| Delete Task | ✅ | ✅ | ✅ |
| List Tasks | ✅ | ✅ | ✅ |
| Due Dates | ✅ | ✅ | ✅ |
| Assignments | ❌ | ✅ | ✅ |
| Collaboration | ❌ | ✅ | ✅ |
| Reminders | ✅ | ✅ | ✅ |

### Security Features
| Feature | Implementation |
|---------|----------------|
| Master Password | PBKDF2/Argon2id key derivation |
| Data Encryption | AES-256-GCM |
| Secure Input | Terminal password masking |
| Memory Protection | Automatic sensitive data wiping |
| Transport Security | TLS 1.3 for all communications |
| Authentication | JWT with refresh tokens |
| Access Control | Role-based permissions |

## Command Design Principles

- **Structured Organization**: Commands grouped by functionality
- **Comprehensive Coverage**: All operations available via CLI
- **Consistent Patterns**: Standard add/get/list/delete workflow
- **Global Configuration**: Centralized settings management
- **Multi-Vault Architecture**: Isolated vaults with separate encryption

## Detailed Command Reference

### Command Structure
```
tip <global-flags> <command> <subcommand> [args] [flags]
```

### Global Flags
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

### Configuration Commands
```
tip config init                    # Initialize configuration
tip config show                    # Show current configuration
tip config set <key> <value>       # Set configuration value
tip config get <key>               # Get configuration value
tip config reset                   # Reset to defaults
```

### Vault Management
```
tip vault init <name>              # Initialize new vault
tip vault list                     # List all vaults
tip vault switch <name>           # Switch to vault
tip vault delete <name>           # Delete vault
tip vault backup <path>           # Backup vault
tip vault restore <path>          # Restore vault
tip vault info                     # Show vault information
```

### Authentication Commands
```
tip auth login                     # Login to remote server
tip auth logout                    # Logout from remote server
tip auth status                    # Show authentication status
tip auth refresh                   # Refresh authentication token
tip unlock                         # Unlock local vault
tip lock                           # Lock local vault
```

### Password Management Commands
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

### Task Management Commands
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

### Token Management Commands
```
tip token create                   # Create CLI access token
tip token list                     # List active tokens
tip token revoke <id>              # Revoke token
tip token info <id>                # Get token details
```

### Category Management Commands
```
tip category list                  # List categories
tip category add <name>            # Add new category
tip category delete <name>         # Delete category
```

### Synchronization Commands
```
tip sync                           # Sync with remote server
tip sync status                    # Show sync status
tip sync force                     # Force full sync
tip export <format>                # Export data (json, csv)
tip import <file>                  # Import data
```

## Implementation Strategy

### Phase 1: Core Foundation
1. **Password Manager Library**
   - Data structures and models
   - Encryption/decryption utilities
   - CRUD operations with validation
   - Comprehensive test coverage

2. **Storage Abstraction**
   - Interface definition for storage backends
   - JSON file implementation
   - SQLite database implementation
   - Migration utilities between backends

### Phase 2: CLI Implementation
1. **Command Framework**
   - Cobra-based command structure
   - Configuration management with Viper
   - Local and remote mode switching
   - Secure password input handling

2. **Core Commands**
   - Task management (refactor existing)
   - Password management (new)
   - Configuration and setup
   - Import/export functionality

### Phase 3: Server Infrastructure
1. **Web Server**
   - HTTP server with Gin/Chi router
   - JWT authentication middleware
   - API endpoint implementation
   - Database integration

2. **API Design**
   - RESTful endpoints for all operations
   - Versioned API structure
   - Error handling and validation
   - Rate limiting and security

### Phase 4: Integration & Polish
1. **Client-Server Integration**
   - Remote storage implementation
   - Sync conflict resolution
   - Offline mode support
   - Performance optimization

2. **Advanced Features**
   - Search and filtering
   - Categories and tags
   - Audit logging
   - Backup and restore

## Next Steps
- [ ] Finalize password manager data models
- [ ] Implement encryption layer with Argon2id
- [ ] Create storage interface and JSON/SQLite adapters
- [ ] Build CLI with local/remote mode support
- [ ] Implement web server with authentication
- [ ] Create comprehensive test suite
- [ ] Design and implement web platform UI
