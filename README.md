# Tip

A self-hosted password and task manager combining secure credential storage with intelligent task management. Built with Go, featuring end-to-end encryption, multi-device sync, and team collaboration.

## Features

**Password Management**
- AES-256-GCM encryption with Argon2id key derivation
- Secure password generation and strength evaluation
- Organization via categories, tags, and custom fields
- Clipboard integration with auto-clear
- Password history and version management
- Secure password sharing (remote mode)
- Full-text search and duplicate detection

**Task Management**
- Complete task lifecycle with priority and due dates
- Categories and tags for organization
- Task assignment and collaboration
- Status tracking and filtering
- Due date reminders and calendar integration
- Link tasks to passwords and resources

**Operational Modes**
- Local Mode - Offline-first with JSON or SQLite storage
- Remote Mode - Server-based with end-to-end encryption
- Sync - Automatic conflict resolution and backup

**Security**
- Master password with no plaintext storage
- End-to-end encryption on all data
- Auto-lock with configurable timeout
- Complete audit trails
- Breach detection integration
- Zero-knowledge architecture (remote mode)

## Quick Start

```bash
# Initialize configuration
tip config init

# Create your first vault
tip vault init personal

# Add passwords
tip password add github --username myuser

# Add tasks
tip task add "Review code" --priority high

# List and manage
tip password list
tip task list
```

## Documentation

- **[Task Tracking](TASKS.md)** - Development tasks with completion status
- **[Roadmap](docs/ROADMAP.md)** - Development timeline and milestones
- **[CLI Reference](docs/CLI_REFERENCE.md)** - Complete command reference with examples
- **[Password Features](docs/PASSWORD_FEATURES.md)** - Detailed password management guide
- **[Task Features](docs/TASK_FEATURES.md)** - Comprehensive task management features
- **[Server API](docs/SERVER_API.md)** - REST API endpoints and examples
- **[Architecture](docs/ARCHITECTURE.md)** - System design and technical details
- **[Project Overview](docs/PROJECT_OVERVIEW.md)** - Vision and design principles

## Installation

### From Source
```bash
git clone https://github.com/atisans/tip
cd tip
go build -o tip ./cmd/tip
```

### Docker
```bash
docker-compose up -d tip-server
```

## Configuration

Configuration stored in `~/.config/tip/config.yml`:

```yaml
mode: local              # local or remote
storage: json            # json or sqlite
vault: personal          # default vault
server:
  url: https://tip.example.com
security:
  auto_lock_timeout: 15  # minutes
  password_history: 5
```

## Development

### Prerequisites
- Go 1.24+
- Make or Mage
- Docker (optional)

### Running Tests
```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run task manager tests
go test ./... -run Task
```

### Build
```bash
# Build CLI
go build -o tip ./cmd/tip

# Build Server
go build -o tip-server ./cmd/server

# Docker build
docker build -t tip:latest .
```

## Use Cases

**Individual Users**
- Secure personal password vault
- Task and todo list management
- Cross-device password sync
- Offline-first operation

**Teams**
- Shared password management
- Collaborative task tracking
- Team member permissions
- Audit trails and compliance

**Developers**
- CLI-based automation
- REST API integration
- Custom field support
- Git-friendly configuration

## Security Notes

- Master password never stored, only derived key
- All sensitive data encrypted at rest and in transit
- Uses industry-standard cryptographic algorithms
- Comprehensive audit logging
- Regular security assessments recommended

## Self-Hosted Deployment

Tip is designed for self-hosted deployment:

```bash
# Using Docker Compose
docker-compose up -d

# Manual deployment
tip-server --config config.yaml

# Enable TLS
tip-server --config config.yaml --tls-cert cert.pem --tls-key key.pem
```

## License

MIT License - See [LICENSE](LICENSE)

## Contributing

Contributions welcome! Please see the development roadmap in [docs/ROADMAP.md](docs/ROADMAP.md)

## Support

- Documentation: [docs/](docs/)
- Issues: GitHub Issues
- Security: See [SECURITY.md](SECURITY.md) for responsible disclosure
