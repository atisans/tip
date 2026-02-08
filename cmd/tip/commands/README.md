# CLI Commands Package

This package contains the Cobra CLI command implementations for the Tip password and task manager.

## Commands

### Planned Commands

**Vault Management**
- `vault create` - Create a new encrypted vault
- `vault open` - Open and unlock an existing vault
- `vault close` - Lock and close the current vault
- `vault list` - List available vaults
- `vault delete` - Delete a vault

**Password Management**
- `password add` - Add a new password entry
- `password get` - Retrieve a password
- `password list` - List all password entries
- `password delete` - Remove a password entry
- `password generate` - Generate a secure password
- `password share` - Securely share a password

**Task Management**
- `task add` - Add a new task
- `task list` - List tasks with filtering options
- `task complete` - Mark a task as complete
- `task delete` - Remove a task
- `task edit` - Modify an existing task

**Configuration**
- `config get` - Get configuration value
- `config set` - Set configuration value
- `config list` - Show all configuration settings

## Structure

Each command will be implemented as a separate Go file following Cobra conventions:
- `vault.go` - Vault management commands
- `password.go` - Password management commands
- `task.go` - Task management commands
- `config.go` - Configuration commands
- `root.go` - Root command and global flags

## Usage

```bash
tip --help                    # Show help
tip vault create myvault      # Create vault
tip password add github       # Add password
tip task add "Review PR"      # Add task
```
