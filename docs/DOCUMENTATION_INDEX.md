# Documentation Index

Complete documentation for the Tip password and task manager project.

## Quick Navigation

### Getting Started
- **[README.md](../README.md)** - Project overview and quick start
- **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** - Vision, features, and design principles
- **[ROADMAP.md](ROADMAP.md)** - Development timeline and milestones

### User Documentation
- **[CLI_REFERENCE.md](CLI_REFERENCE.md)** - Complete CLI command reference with examples
- **[PASSWORD_FEATURES.md](PASSWORD_FEATURES.md)** - Password management guide
- **[TASK_FEATURES.md](TASK_FEATURES.md)** - Task management guide

### Developer Documentation
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design and technical architecture
- **[SERVER_API.md](SERVER_API.md)** - REST API endpoints and integration guide

## Document Descriptions

### README.md
**Purpose**: Project introduction and quick reference
**Contents**:
- Feature overview with emojis
- Quick start guide
- Installation instructions
- Configuration example
- Development setup
- Use cases and security notes
- Deployment information

**Read this if**: You're new to Tip or want a high-level overview

### PROJECT_OVERVIEW.md
**Purpose**: Comprehensive project vision and design
**Contents**:
- Project vision and goals
- Core components (CLI, Server, Web Platform)
- Implementation status (completed vs pending)
- Key design principles
- Target use cases
- Technical highlights
- Feature matrix (password/task management across modes)
- Architecture overview (multi-tier design)
- Implementation strategy (4 phases)

**Read this if**: You want to understand project goals and architecture

### CLI_REFERENCE.md
**Purpose**: Complete command-line interface documentation
**Contents**:
- Command structure and syntax
- Global flags
- All command categories:
  - Configuration
  - Vault management
  - Authentication
  - Password management
  - Task management
  - Synchronization
- Practical examples for all major workflows
- Configuration file format
- Security best practices
- Flags and options reference
- Error handling and troubleshooting

**Read this if**: You need to use Tip from the command line

### PASSWORD_FEATURES.md
**Purpose**: Detailed password manager feature documentation
**Contents**:
- Data model (Password struct)
- Core CRUD operations with examples
- Password generation (multiple options)
- Strength evaluation and breach detection
- Password history and versioning
- Search, discovery, and filtering
- Categories and tags
- Custom fields
- Clipboard integration
- Secure notes storage
- Sharing capabilities (remote mode)
- Import/export functionality
- Security analysis and audit
- Vault organization
- Encryption standards
- Advanced features (duplicates, expiration)
- Output formatting
- Statistics and reporting
- Best practices
- Future enhancements

**Read this if**: You want to master password management features

### TASK_FEATURES.md
**Purpose**: Detailed task manager feature documentation
**Contents**:
- Task data model (Task struct)
- Core CRUD operations with examples
- Status lifecycle (pending, in_progress, completed)
- Priority system (low, medium, high, critical)
- Due dates with smart parsing
- Categories and tags
- Search and filtering
- Team collaboration and assignment
- Task history and timestamps
- Advanced features:
  - Task templates
  - Recurring tasks
  - Task dependencies
  - Subtasks and progress tracking
- Password-task linking
- Calendar integration
- Output formatting options
- Statistics and reporting
- Command aliases
- Storage modes
- Best practices
- Future enhancements

**Read this if**: You want to master task management features

### ARCHITECTURE.md
**Purpose**: Technical system design and implementation details
**Contents**:
- Project structure and directory layout
- Current implementation status
- Detailed architecture sections:
  - Business logic layer (models, managers, crypto)
  - Storage abstraction (interfaces and implementations)
  - CLI architecture (Cobra framework)
  - Server architecture (Chi router)
  - API design and endpoints
  - Authentication and authorization
- Technology stack for CLI, Server, Database, Security, Development
- Deployment architecture (local, production, monitoring)
- Design decisions and rationale
- Implementation priorities
- OAuth integration flow
- Command philosophy and design
- Security features matrix

**Read this if**: You're a developer implementing Tip features

### SERVER_API.md
**Purpose**: REST API reference and integration guide
**Contents**:
- Base URL and versioning
- Standard response format
- Authentication methods:
  - OAuth (GitHub, Google)
  - Direct login
  - Token refresh
  - Token management
- User profile endpoints
- Token management (create, list, revoke, extend)
- Vault management endpoints
- Password management endpoints
  - CRUD operations
  - Search, generate, share
  - Access control
- Task management endpoints
  - CRUD operations
  - Status management
  - Assignment
- Synchronization endpoints
- Health check endpoints
- Error codes and handling
- Rate limiting
- Webhook definitions (future)

**Read this if**: You're integrating with Tip server or developing server features

### ROADMAP.md
**Purpose**: Development timeline and phase planning
**Contents**:
- 11 development phases with weekly breakdowns
- Phase 1-10 detailed tasks:
  - Foundation & Architecture
  - Core Business Logic
  - Cryptography & Security
  - Storage Layer Implementation
  - CLI Implementation
  - Web Server Implementation
  - Integration & Synchronization
  - Advanced Features & Polish
  - Testing & Quality Assurance
  - Deployment & Operations
- Phase 11: Web Platform Development
- Advanced Features & Future Development
- Success metrics (technical and user)
- Implementation notes

**Read this if**: You want to understand the development plan and status

## By Role

### End Users
1. Start: [README.md](../README.md) - Quick overview
2. Learn: [CLI_REFERENCE.md](CLI_REFERENCE.md) - Command guide
3. Master: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md) and [TASK_FEATURES.md](TASK_FEATURES.md)
4. Advanced: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) for operational modes

### Administrators
1. Start: [README.md](../README.md)
2. Deploy: [ARCHITECTURE.md](ARCHITECTURE.md#deployment-architecture)
3. Maintain: [ROADMAP.md](ROADMAP.md) for version planning
4. Secure: [ARCHITECTURE.md](ARCHITECTURE.md#security-features) and [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md#security-first)

### CLI Developers
1. Start: [ARCHITECTURE.md](ARCHITECTURE.md#cli-design)
2. Reference: [CLI_REFERENCE.md](CLI_REFERENCE.md)
3. Features: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md) and [TASK_FEATURES.md](TASK_FEATURES.md)
4. Plan: [ROADMAP.md](ROADMAP.md)

### Backend Developers
1. Start: [ARCHITECTURE.md](ARCHITECTURE.md)
2. API: [SERVER_API.md](SERVER_API.md)
3. Features: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md) and [TASK_FEATURES.md](TASK_FEATURES.md)
4. Plan: [ROADMAP.md](ROADMAP.md)

### Security Reviewers
1. Overview: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md#key-design-principles)
2. Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#technology-stack) and [ARCHITECTURE.md](ARCHITECTURE.md#security-features)
3. Features: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md#encryption-and-security)
4. API: [SERVER_API.md](SERVER_API.md#authentication)

## Feature Cross-Reference

### Password Management
- Commands: [CLI_REFERENCE.md](CLI_REFERENCE.md#password-management-commands)
- Features: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#password-manager-passwordgo)
- API: [SERVER_API.md](SERVER_API.md#password-management)
- Overview: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md#password-management)

### Task Management
- Commands: [CLI_REFERENCE.md](CLI_REFERENCE.md#task-management-commands)
- Features: [TASK_FEATURES.md](TASK_FEATURES.md)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#task-manager-taskgo)
- API: [SERVER_API.md](SERVER_API.md#task-management)
- Overview: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md#task-manager-features-enhanced)

### Vault Management
- Commands: [CLI_REFERENCE.md](CLI_REFERENCE.md#vault-management)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#vault-management)
- API: [SERVER_API.md](SERVER_API.md#vault-management)
- Overview: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md#vault-management)

### Authentication
- Commands: [CLI_REFERENCE.md](CLI_REFERENCE.md#authentication-commands)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#oauth-integration-flow)
- API: [SERVER_API.md](SERVER_API.md#authentication)
- Features: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md#master-password)

### Synchronization
- Commands: [CLI_REFERENCE.md](CLI_REFERENCE.md#synchronization-commands)
- API: [SERVER_API.md](SERVER_API.md#synchronization)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#operation-modes)
- Overview: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md#operation-modes)

### Security
- Features: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md#encryption-and-security)
- Best Practices: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md#best-practices) and [TASK_FEATURES.md](TASK_FEATURES.md#best-practices)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md#security-features)
- Overview: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md#security-first)

## Examples and Workflows

### Quick Start Workflows
- Basic usage: [README.md](../README.md#quick-start)
- CLI examples: [CLI_REFERENCE.md](CLI_REFERENCE.md#examples)
- API examples: [SERVER_API.md](SERVER_API.md)

### Common Tasks
- Creating passwords: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md#1-password-crud-operations)
- Managing tasks: [TASK_FEATURES.md](TASK_FEATURES.md#1-task-crud-operations)
- Sharing passwords: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md#11-sharing-remote-mode-only)
- Team collaboration: [TASK_FEATURES.md](TASK_FEATURES.md#8-team-collaboration-remote-mode)
- Backup and restore: [CLI_REFERENCE.md](CLI_REFERENCE.md#data-management)

### Advanced Workflows
- Multi-vault management: [CLI_REFERENCE.md](CLI_REFERENCE.md#working-with-multiple-vaults)
- Password security audit: [PASSWORD_FEATURES.md](PASSWORD_FEATURES.md#13-security-analysis)
- Task reporting: [TASK_FEATURES.md](TASK_FEATURES.md#statistics-and-reporting)
- Custom integration: [SERVER_API.md](SERVER_API.md)

## Document Maintenance

**Last Updated**: January 8, 2025

**Structure**:
- docs/ directory contains all documentation
- Each feature has dedicated document (PASSWORD_FEATURES, TASK_FEATURES, etc.)
- CLI_REFERENCE covers command-line usage
- ARCHITECTURE covers technical design
- SERVER_API covers REST API
- README provides quick reference
- ROADMAP tracks development

**Cross-linking**: All documents reference related content for easy navigation

**Keep Updated**:
- Update feature docs when new commands added
- Update CLI_REFERENCE with new CLI options
- Update SERVER_API when endpoints change
- Update ROADMAP as phases complete
- Update ARCHITECTURE with design decisions
