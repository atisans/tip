# CLI Reference

## Command Structure

```bash
tip <global-flags> <command> <subcommand> [args] [flags]
```

## Global Flags

```bash
--config=<path>     # Configuration file path
--mode=<local|remote> # Operation mode
--storage=<json|sqlite> # Storage backend
--vault=<name>      # Vault name (multi-vault support)
--verbose           # Verbose output
--quiet             # Minimal output
--help              # Show help
--version           # Show version
```

## Configuration Commands

```bash
tip config init                    # Initialize configuration
tip config show                    # Show current configuration
tip config set --key=<key> --value=<value>       # Set configuration value
tip config get --key=<key>               # Get configuration value
tip config reset                   # Reset to defaults
```

## Vault Management

```bash
tip vault init --name=<name>              # Initialize new vault
tip vault list                     # List all vaults
tip vault switch --name=<name>            # Switch to vault
tip vault delete --name=<name>            # Delete vault
tip vault backup --path=<path>            # Backup vault
tip vault restore --path=<path>           # Restore vault
tip vault info                     # Show vault information
```

## Authentication Commands

```bash
tip auth login                     # Login to remote server
tip auth logout                    # Logout from remote server
tip auth status                    # Show authentication status
tip auth refresh                   # Refresh authentication token
tip unlock                         # Unlock local vault
tip lock                           # Lock local vault
```

## Password Management Commands

### Basic CRUD

```bash
tip password add --name=<name>            # Add new password
tip password get --name=<name>            # Get password details
tip password edit --name=<name>           # Edit password
tip password delete --name=<name>         # Delete password
tip password list                  # List all passwords
```

### Advanced Features

```bash
tip password search --query=<query>        # Search passwords
tip password copy --name=<name>           # Copy password to clipboard
tip password share --name=<name> --user=<user>   # Share password with user
```

### Organization

```bash
tip password category list         # List categories
tip password category add --name=<name>   # Add category
tip password tag list              # List tags
tip password tag add --name=<name> --tag=<tag>  # Add tag to password
```

## Task Management Commands

### Basic CRUD

```bash
tip task add --description="..."         # Add new task
tip task list                      # List all tasks
tip task get --id=<id>                  # Get task details
tip task edit --id=<id>                 # Edit task
tip task delete --id=<id>               # Delete task
```

### Task Operations

```bash
tip task complete --id=<id>             # Mark task as complete
tip task start --id=<id>                # Mark task as in progress
tip task assign --id=<id> --user=<user>        # Assign task to user
```

### Organization

```bash
tip task list --status=pending     # List tasks by status
tip task list --priority=high      # List tasks by priority
tip task list --due=today          # List tasks due today
```

## Synchronization Commands

```bash
tip sync                           # Sync with remote server
tip sync status                    # Show sync status
tip sync force                     # Force full sync
tip export --format=<format>                # Export data (json, csv)
tip import --file=<file>                  # Import data
```

## Examples

### Quick Start
```bash
# Initialize configuration
tip config init

# Create your first vault
tip vault init --name=personal

# Add a password
tip password add --name=github --username=myuser

# Add a task
tip task add --description="Review code" --priority=high --due=tomorrow

# List all passwords in current vault
tip password list

# List all tasks
tip task list

# Complete a task
tip task complete --id=1
```

### Working with Multiple Vaults
```bash
# Create separate vaults for different contexts
tip vault init --name=work
tip vault init --name=personal
tip vault init --name=finance

# Switch between vaults
tip vault switch --name=work

# Add password to specific vault without switching
tip --vault=finance password add --name="bank_account"

# List vaults
tip vault list
```

### Password Management
```bash
# Generate a random password
tip password generate --length=32 --special

# Add with specific category
tip password add --name=github --username=alice --category=development

# Search passwords
tip password search --query=github

# Copy password to clipboard
tip password copy --name=github

# Share password with team member (remote mode)
tip password share --name=github --user=alice@example.com

# Tag a password
tip password tag add --name=github --tag=important
```

### Task Workflows
```bash
# Add task with multiple attributes
tip task add --description="Complete project" --priority=high --due="2025-01-15" --category=work

# Start working on a task
tip task start --id=1

# View task details
tip task get --id=1

# Assign to team member (remote mode)
tip task assign --id=1 --user=alice@example.com

# List tasks by status
tip task list --status=in_progress

# List high priority tasks due today
tip task list --priority=high --due=today
```

### Data Management
```bash
# Create backup of vault
tip vault backup --path=~/backups/personal.bak

# Restore from backup
tip vault restore --path=~/backups/personal.bak

# Export all data as JSON
tip export --format=json > backup.json

# Export as CSV (passwords only)
tip export --format=csv > passwords.csv

# Import data from backup
tip import --file=backup.json
```

### Remote Synchronization
```bash
# Login to remote server
tip auth login

# Check authentication status
tip auth status

# Sync local vault with remote
tip sync

# Force full synchronization
tip sync force

# Check sync status and last sync time
tip sync status

# Logout
tip auth logout
```

### Configuration Management
```bash
# Show current configuration
tip config show

# Set storage backend to SQLite
tip config set --key=storage --value=sqlite

# Change operation mode to remote
tip config set --key=mode --value=remote

# Set server address for remote mode
tip config set --key=server --value=https://tip.example.com

# Reset to defaults
tip config reset
```

### Token Management (Remote Mode)
```bash
# Generate CLI token for automation
tip auth token create --name="backup-script" --expires=90d

# List active tokens
tip auth token list

# Get token details
tip auth token info --id=<id>

# Extend token expiry
tip auth token refresh --id=<id> --expires=90d

# Revoke token
tip auth token revoke --id=<id>
```

### Category Management
```bash
# List predefined categories
tip password category list

# Add custom category
tip password category add --name=freelance

# Create categories for organization
tip password category add --name=health
tip password category add --name=legal
```

## Configuration File

The configuration is stored in `~/.config/tip/config.yml`:

```yaml
# Operation mode: local or remote
mode: local

# Storage backend: json or sqlite
storage: json

# Default vault name
vault: personal

# Remote server settings (for remote mode)
server:
  url: https://tip.example.com
  timeout: 30

# Security settings
security:
  auto_lock_timeout: 15 # minutes
  password_history: 5

# Output settings
output:
  verbose: false
  color: true
```

## Security Notes

- No plaintext logging of sensitive data
- Use `tip unlock` before accessing vault contents in local mode
- Use `tip lock` to secure vault after operations
- Master password is never stored; derived key is used for encryption
- CLI tokens in remote mode have configurable expiration
- Always use `--mode=remote` over untrusted networks
- Vault backups are encrypted with the same master password
- Use `tip config set --key=auto_lock_timeout --value=5` for auto-lock after 5 minutes

## Flags and Options

### Common Flags for All Commands
```bash
--config=<path>     # Use alternate configuration file
--vault=<name>      # Specify vault (overrides config)
--verbose           # Enable verbose output
--quiet             # Suppress non-essential output
--help              # Show command help
```

### Password Command Flags
```bash
--category=<name>   # Filter or assign category
--tags=<tag1,tag2>  # Add tags to password
--url=<url>         # Associated URL/website
--username=<name>   # Username for login
--notes=<text>      # Additional notes
```

### Task Command Flags
```bash
--status=<status>   # Filter by status (pending, in_progress, completed)
--priority=<level>  # Filter by priority (low, medium, high, critical)
--due=<date>        # Set/filter by due date
--assigned=<user>   # Filter by assignee (remote mode)
--category=<name>   # Filter or assign category
```

### Generation Flags
```bash
--length=<n>        # Password length (default: 16)
--special           # Include special characters
--no-numbers        # Exclude numbers
--no-symbols        # Exclude symbols
--uppercase         # Require uppercase letters
```

## Error Handling

Common error messages and solutions:

```bash
"Vault not found"
→ Use `tip vault list` to see available vaults
→ Use `tip vault switch --name=<name>` to switch vaults

"Item not found"
→ Use `tip password list` or `tip task list` to find IDs
→ Make sure you're in the correct vault

"Authentication failed"
→ Use `tip auth login` to authenticate with remote server
→ Check your API token with `tip auth status`

"Storage locked"
→ Use `tip unlock` and enter your master password
→ Configure auto-lock timeout with `tip config set --key=auto_lock_timeout --value=<minutes>`
```
