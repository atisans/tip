# Password Manager Features

## Overview

The Password Manager is the core secure storage component of Tip, designed to securely manage passwords with military-grade encryption, flexible organization, and team sharing capabilities.

## Data Model

### Password Structure
```go
type Password struct {
    ID           string            `json:"id"`            // Unique identifier
    Name         string            `json:"name"`          // Service/app name
    Username     string            `json:"username"`      // Login username/email
    Password     string            `json:"password"`      // Encrypted password
    URL          string            `json:"url"`           // Associated website/app
    Notes        string            `json:"notes"`         // Additional notes (encrypted)
    Category     string            `json:"category"`      // Work, Personal, Development, Finance
    Tags         []string          `json:"tags"`          // Custom tags
    CreatedAt    time.Time         `json:"created_at"`    // Creation timestamp
    UpdatedAt    time.Time         `json:"updated_at"`    // Last modification
    LastUsed     time.Time         `json:"last_used"`     // Last accessed
    LastModifiedBy string          `json:"last_modified_by"` // (remote mode)
    CustomFields map[string]string `json:"custom_fields"` // Extra fields (encrypted)
    History      []PasswordVersion `json:"history"`       // Password history (5 versions)
}

type PasswordVersion struct {
    Password  string    `json:"password"`
    UpdatedAt time.Time `json:"updated_at"`
}
```

## Core Features

### 1. Password CRUD Operations

#### Create Passwords
```bash
# Basic password entry (prompts for password)
tip password add github

# With username
tip password add github --username alice

# With all details
tip password add github \
  --username alice@example.com \
  --url https://github.com/login \
  --category development \
  --notes "Personal GitHub account"

# Auto-open browser after adding (future)
tip password add github --url https://github.com --open
```

#### Read/Get Passwords
```bash
# Get password details (returns decrypted)
tip password get github

# List all passwords
tip password list

# List passwords in specific category
tip password list --category work
tip password list --category development

# Show only passwords (not full details)
tip password list --format compact
```

#### Update Passwords
```bash
# Edit password entry
tip password edit github --username newuser

# Update password
tip password edit github --password-prompt  # Interactive prompt

# Update other fields
tip password edit github --notes "Updated notes"
tip password edit github --category work
tip password edit github --url "https://new-url.com"

# Update custom fields
tip password edit github --custom field1=value1 field2=value2
```

#### Delete Passwords
```bash
# Delete single password
tip password delete github --confirm

# Delete without confirmation prompt
tip password delete github --force

# Bulk delete by category
tip password delete --category finance --confirm
```

### 2. Password Generation

Intelligent password generation with customizable rules:

#### Basic Generation
```bash
# Generate default password (16 chars, mixed case, numbers, symbols)
tip password generate

# Specify length
tip password generate --length 32
tip password generate --length 64

# Only letters
tip password generate --no-numbers --no-symbols

# Passphrase (easier to remember)
tip password generate --passphrase --words 4
# Example: "correct-horse-battery-staple"

# PIN/numeric only
tip password generate --digits-only --length 6

# Copy to clipboard directly
tip password generate --length 24 --copy
```

#### Advanced Generation Options
```bash
# No ambiguous characters (avoid 0/O, 1/l, etc.)
tip password generate --no-ambiguous

# Exclude specific characters
tip password generate --exclude "!@#"

# Require specific character types
tip password generate --require-uppercase --require-numbers

# Symbol-heavy (for complex requirements)
tip password generate --special --length 20

# Use specific character sets
tip password generate --charset "abcdefghijklmnopqrstuvwxyz0123456789"
```

#### Generate and Save
```bash
# Generate and immediately save to password entry
tip password add github --generate --username alice

# Generate and copy to clipboard
tip password generate --copy | tip password add github --stdin

# Interactive generation and save
tip password generate --interactive
```

### 3. Password Strength Evaluation

#### Strength Analysis
```bash
# Check password strength
tip password strength "myPassword123!"
# Output: Strong (Score: 85/100)

# Analyze saved password
tip password get github --strength

# Check against common breaches
tip password check github  # Warns if in known breach databases

# Password requirements
tip password requirements github  # Shows specific requirements for service
```

#### Strength Criteria
- Length (8-16-20+ characters)
- Character variety (upper, lower, numbers, symbols)
- Not in common password lists
- Not matching username
- No dictionary words
- No sequential patterns (123, abc, etc.)

### 4. Password History

Keep track of password changes:

```bash
# View password history
tip password history github

# Show last 5 password changes
tip password history github --limit 5

# Restore previous password
tip password restore github --version 2

# Clear history
tip password clear-history github --confirm

# View change dates
tip password history github --timestamps
```

### 5. Search and Discovery

Comprehensive search capabilities:

```bash
# Search by name
tip password search github

# Search by username
tip password search --username alice

# Search by URL/domain
tip password search --url "github.com"

# Search by category
tip password list --category work

# Search by tags
tip password list --tag important

# Advanced search (all matches)
tip password search "auth" --search-notes --search-usernames

# Case-insensitive fuzzy matching
tip password search git
# Returns: github, gitlab, gitea, etc.

# Multiple criteria
tip password search "api" --category development --tag deprecated
```

### 6. Categories

Organize passwords by type:

Predefined categories:
- **Work** - Work-related credentials
- **Personal** - Personal accounts
- **Development** - Dev tools, APIs, SDKs
- **Finance** - Banking, payment services

#### Category Management
```bash
# List categories
tip password category list

# Add custom category
tip password category add freelance
tip password category add healthcare
tip password category add legal

# Assign category when adding
tip password add google --category personal

# Move password to category
tip password edit github --category development

# List all passwords in category
tip password list --category work

# Rename category
tip password category rename personal home

# Delete category
tip password category delete freelance --move-to personal
```

### 7. Tags

Flexible labeling beyond categories:

```bash
# Add tags when creating
tip password add github --tag "mfa" --tag "important"

# Add tags to existing password
tip password tag add github security
tip password tag add github 2fa

# Remove tag
tip password tag remove github deprecated

# List all tags
tip password tag list

# Filter by tag
tip password list --tag "mfa"
tip password list --tag "backup"

# Multiple tags
tip password list --tag "important,security"
```

Common tags:
- `mfa` - Multi-factor authentication enabled
- `shared` - Password shared with team
- `expiring` - Password needs to be changed soon
- `security` - Security-critical account
- `backup` - Backup account
- `deprecated` - Old/unused account
- `important` - Critical account
- `review` - Needs review/update

### 8. Custom Fields

Add custom information to passwords:

```bash
# Add custom fields when creating
tip password add aws \
  --custom account-id=123456789 \
  --custom mfa-device=arn:aws:iam::...

# Add custom field to existing
tip password edit github --custom field-name="field value"

# View custom fields
tip password get github --verbose

# Remove custom field
tip password edit github --remove-custom field-name

# Examples of custom fields
--custom security_question="Your mother's maiden name?"
--custom backup_codes="code1, code2, code3..."
--custom recovery_email="backup@example.com"
--custom phone_number="555-1234"
```

### 9. Clipboard Integration

Secure clipboard handling:

```bash
# Copy password to clipboard
tip password copy github
# Message: "Password copied to clipboard. Expires in 30 seconds."

# Copy with extended timeout
tip password copy github --timeout 60

# Copy username
tip password copy github --username

# Copy custom field
tip password copy github --field account-id

# Paste and add password
tip password add --paste-username --paste-password

# Clear clipboard
tip password clear-clipboard

# Auto-clear on app exit
# Configured in security settings
```

### 10. Secure Notes

Store encrypted notes with passwords:

```bash
# Add notes when creating
tip password add bank \
  --notes "Branch: Downtown, Account: 12345"

# Edit notes
tip password edit github --notes "2FA: SMS to 555-0123"

# View notes
tip password get github --notes

# Notes are fully encrypted and separate from passwords

# Examples
tip password add corporate-vpn \
  --notes "VPN Key: <key>\nServer: vpn.corp.com:443"

tip password add email \
  --notes "Recovery email: backup@example.com\nSecond email: secondary@example.com"
```

### 11. Sharing (Remote Mode Only)

Share passwords securely with team members:

```bash
# Share with single user
tip password share github alice@example.com

# Share with multiple users
tip password share github alice@example.com bob@example.com

# Share with read-only access
tip password share github alice@example.com --read-only

# Share with time limit
tip password share github alice@example.com --expires "7 days"

# View who has access
tip password access github

# Revoke access
tip password share github --revoke alice@example.com

# Shared passwords show indicator
tip password list --shared
```

#### Sharing Workflow
1. Password owner initiates share
2. Recipient receives notification
3. Recipient can view/use password
4. Owner can revoke at any time
5. All access is logged

### 12. Import/Export

Move passwords in and out:

#### Export
```bash
# Export all passwords (encrypted JSON)
tip export passwords --format json > backup.json

# Export specific category
tip export passwords --category work --format json

# Export as CSV (with warning about security)
tip export passwords --format csv --warning

# Export with password history
tip export passwords --include-history

# Encrypt export with second password
tip export passwords --encrypt-with "export-password"
```

#### Import
```bash
# Import from backup
tip import backup.json

# Import from CSV
tip import passwords.csv

# Import from other password managers
tip import --from 1password backup.agilekeychain
tip import --from bitwarden export.json
tip import --from lastpass export.csv

# Merge with existing (skip duplicates)
tip import backup.json --merge

# Merge and override
tip import backup.json --merge --override

# Preview before importing
tip import backup.json --dry-run
```

#### Supported Import Formats
- JSON (Tip format)
- CSV (standard format)
- 1Password `.agilekeychain`
- Bitwarden JSON
- LastPass CSV
- Firefox exported passwords

### 13. Security Analysis

#### Audit and Compliance
```bash
# Check for weak passwords
tip password audit --strength low

# Find duplicate passwords (security risk)
tip password audit --duplicates

# Check for credentials in breaches
tip password audit --breach-check

# Passwords not changed recently
tip password audit --last-changed "more than 90 days"

# Unused passwords
tip password audit --unused "more than 6 months"

# Generate audit report
tip password audit --report > security_audit.txt
```

### 14. Vault Management

Organize passwords by vault:

```bash
# Create separate vaults
tip vault init work
tip vault init personal
tip vault init finance

# Switch vaults
tip vault switch work

# Add password to specific vault
tip --vault finance password add bank

# List passwords in current vault
tip password list

# Move password between vaults (future)
tip password move github --from personal --to work

# Vault info
tip vault info
```

## Encryption and Security

### Encryption Standards
- **Algorithm**: AES-256-GCM
- **Key Derivation**: Argon2id (NIST recommended)
- **Authentication**: Authenticated encryption
- **Data at Rest**: Encrypted in storage
- **Data in Transit**: TLS 1.3

### Master Password
```bash
# Set master password
tip unlock
# Enter master password: [hidden input]

# Change master password
tip password change-master

# Master password never stored, only derived key
# 20-second delay between wrong attempts (brute-force protection)
```

### Auto-Lock Feature
```bash
# Auto-lock timeout in minutes
tip config set security.auto_lock_timeout 15

# Lock vault manually
tip lock

# Unlock vault
tip unlock

# Check lock status
tip auth status
```

## Advanced Features

### Duplicate Detection

```bash
# Check for duplicate passwords (risky)
tip password audit --duplicates

# Find accounts with same password as specified
tip password find-same-as github

# Change duplicate passwords (guided)
tip password deduplicate
```

### Breach Detection

```bash
# Check if password is in known breaches
# Uses haveibeenpwned.com API (anonymous checking)
tip password check github

# Scan all passwords
tip password audit --breach-check

# Automatic breach checking (background)
# Enabled with: tip config set security.breach_check true
```

### Password Expiration

```bash
# Set password expiration date
tip password edit github --expires "2025-04-15"

# Mark password as expiring soon
tip password edit github --tag expiring

# Show expiring passwords
tip password list --expiring

# Automatic reminders (future)
# tip config set security.password_expiration_reminder 30 days
```

## Output and Formatting

### List View Options
```bash
# Default table view
tip password list

# Show only names
tip password list --format names

# Compact view
tip password list --format compact

# JSON output (for scripting)
tip password list --format json

# CSV export
tip password list --format csv > passwords.csv

# Count only
tip password list --count

# Show creation dates
tip password list --created

# Show last used
tip password list --last-used
```

### Detailed View
```bash
# Full details with all fields
tip password get github --verbose

# Hide sensitive info
tip password get github --mask-password

# Show in different formats
tip password get github --format json
tip password get github --format yaml
```

## Statistics and Reporting

```bash
# Password count by category
tip password stats

# Passwords by strength
tip password stats --by strength

# Passwords by age
tip password stats --by age

# Security report
tip password report --security

# Compliance report
tip password report --compliance
```

## Best Practices

1. **Unique Passwords** - Use different password for each service
2. **Strong Master Password** - 20+ characters, mixed case, numbers, symbols
3. **Regular Updates** - Change passwords every 90 days
4. **Backup Regularly** - `tip export` weekly
5. **Review Sharing** - Remove unnecessary shared access
6. **Audit Periodically** - `tip password audit` monthly
7. **Secure Notes** - Store recovery codes and 2FA setup info
8. **Use Generation** - Let Tip generate complex passwords
9. **Enable MFA** - Tag accounts with MFA enabled
10. **Delete Unused** - Remove old/duplicate accounts

## Storage Modes

### Local Mode (JSON)
- Passwords stored in `~/.tip/vaults/<vault>/passwords.json`
- Encrypted at rest with master password
- No server required
- Manual backups needed

### Local Mode (SQLite)
- Passwords in local SQLite database
- Better performance
- Full-text search
- Better data integrity

### Remote Mode
- Passwords synced to server
- End-to-end encrypted
- Access from multiple devices
- Team sharing capability
- Automatic backups
- Collaborative management

## Command Reference Quick List

```bash
# Add/Remove
tip password add <name>
tip password delete <name>

# View
tip password get <name>
tip password list [--category <cat>]
tip password search <query>

# Update
tip password edit <name>
tip password copy <name>

# Organization
tip password category add <name>
tip password tag add <name> <tag>

# Security
tip password generate
tip password strength <password>
tip password audit
tip password history <name>

# Sharing (remote)
tip password share <name> <user>

# Import/Export
tip export passwords --format json
tip import backup.json
```

## Future Enhancements

- [ ] Browser extension auto-fill
- [ ] TOTP/2FA integration
- [ ] Hardware security key support
- [ ] Password strength meter in real-time
- [ ] Automatic password rotation
- [ ] Passwordless authentication
- [ ] API key management
- [ ] SSH key management
- [ ] Credit card secure storage
- [ ] Identity document storage
- [ ] Integration with identity providers
- [ ] Machine learning-based security alerts
