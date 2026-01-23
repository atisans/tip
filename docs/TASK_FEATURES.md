# Task Manager Features

## Overview

The Task Manager is a core component of Tip, designed for comprehensive task and workflow management. It supports personal task tracking, team collaboration, and integration with password management workflows.

## Data Model

### Task Structure
```go
type Task struct {
    ID          string    `json:"id"`           // Unique identifier
    Title       string    `json:"title"`        // Task title/description
    Description string    `json:"description"` // Detailed description
    Status      string    `json:"status"`      // pending, in_progress, completed
    Priority    string    `json:"priority"`    // low, medium, high, critical
    DueDate     time.Time `json:"due_date"`    // When task is due
    AssignedTo  string    `json:"assigned_to"` // User assignment (remote mode)
    Category    string    `json:"category"`    // Work, Personal, Development, Finance
    Tags        []string  `json:"tags"`        // Custom tags for organization
    CreatedAt   time.Time `json:"created_at"`  // Creation timestamp
    UpdatedAt   time.Time `json:"updated_at"`  // Last modification
    CompletedAt time.Time `json:"completed_at"`// When task was completed
}
```

## Core Features

### 1. Task CRUD Operations

#### Create Tasks
```bash
# Basic task creation
tip task add "Fix login bug"

# With priority
tip task add "Fix security issue" --priority critical

# With due date
tip task add "Quarterly review" --due "2025-03-31"

# With category
tip task add "Refactor auth module" --category development

# With all attributes
tip task add "Deploy to production" \
  --priority high \
  --due tomorrow \
  --category work \
  --description "Complete all pre-deployment checks"
```

#### Read/Get Tasks
```bash
# Get specific task details
tip task get 1

# List all tasks (default: all statuses)
tip task list

# List with filters
tip task list --status pending
tip task list --priority high
tip task list --category work
tip task list --due today
tip task list --status in_progress --priority critical
```

#### Update Tasks
```bash
# Edit task
tip task edit 1 --title "Updated title"
tip task edit 1 --description "New description"
tip task edit 1 --priority high
tip task edit 1 --due "next Monday"
tip task edit 1 --category development
```

#### Delete Tasks
```bash
# Delete single task
tip task delete 1

# Bulk delete completed tasks (future)
tip task delete --status completed

# Delete by category
tip task delete --category finance
```

### 2. Task Status Management

#### Status Lifecycle
- **pending** - Task created but not started
- **in_progress** - Currently being worked on
- **completed** - Task finished

#### Status Commands
```bash
# Start working on a task
tip task start 1       # Marks as in_progress

# Complete a task
tip task complete 1    # Marks as completed

# Update status directly
tip task edit 1 --status pending
```

### 3. Priority System

#### Priority Levels
- **low** - Background work, non-urgent
- **medium** - Standard priority (default)
- **high** - Important, needs attention soon
- **critical** - Urgent, blocking other work

#### Usage
```bash
# Set priority when adding
tip task add "Critical security patch" --priority critical

# Update priority
tip task edit 1 --priority high

# Filter by priority
tip task list --priority critical
tip task list --priority high,critical  # Multiple priorities

# Sort by priority (default in list view)
# Critical and High appear first
```

### 4. Due Dates and Reminders

#### Date Format Support
```bash
# Absolute dates
tip task add "Release v1.0" --due "2025-02-15"
tip task add "Meeting" --due "2025-01-15 14:30"

# Relative dates (smart parsing)
tip task add "Daily standup" --due today
tip task add "Sprint review" --due tomorrow
tip task add "Project kickoff" --due "next Monday"
tip task add "Quarterly planning" --due "in 2 weeks"
```

#### Filtering by Due Date
```bash
# Tasks due today
tip task list --due today

# Overdue tasks
tip task list --due overdue

# Tasks due this week
tip task list --due "this week"

# Tasks due in specific period
tip task list --due "next 7 days"

# Combined filters
tip task list --status in_progress --due today --priority high
```

### 5. Categories

Predefined categories for organization:
- **Work** - Job-related tasks
- **Personal** - Personal life tasks
- **Development** - Technical/coding tasks
- **Finance** - Money and billing related

#### Category Commands
```bash
# List available categories
tip password category list

# Add custom category
tip password category add freelance
tip password category add health
tip password category add legal

# Use category when adding task
tip task add "Doctor appointment" --category health

# Filter by category
tip task list --category work
tip task list --category development
```

### 6. Tags

Flexible tagging system for additional organization:

```bash
# Add tags to task (when creating)
tip task add "Implement API" --tag backend --tag api

# Add tags to existing task
tip task tag add 1 urgent
tip task tag add 1 documentation

# Remove tags
tip task tag remove 1 urgent

# List tags
tip task tag list

# Filter by tag
tip task list --tag backend
tip task list --tag urgent
```

### 7. Search and Filtering

Comprehensive search capabilities:

```bash
# Search by title/description
tip task search "login bug"
tip task search "database migration"

# Search with filters
tip task search "auth" --status in_progress
tip task search "deploy" --priority high
tip task search "api" --category development

# Advanced filters
tip task list \
  --status in_progress \
  --priority high \
  --category work \
  --due today \
  --tag urgent

# Search in specific category
tip task search "refactor" --category development
```

### 8. Team Collaboration (Remote Mode)

#### Task Assignment
```bash
# Assign task to team member
tip task assign 1 alice@example.com
tip task assign 1 bob@example.com

# Reassign task
tip task edit 1 --assigned bob@example.com

# List tasks assigned to me
tip task list --assigned me

# List tasks assigned to specific user
tip task list --assigned alice@example.com

# Tasks by assignee
tip task list --assigned "Bob Smith"
```

#### Comments and Updates (Future)
```bash
# Add comment to task
tip task comment 1 "Added database indexes for performance"

# View comments
tip task get 1 --verbose  # Shows all comments

# @mention team members
tip task comment 1 "@alice please review when ready"
```

### 9. Task History and Timestamps

#### Tracked Timestamps
- **CreatedAt** - When task was created
- **UpdatedAt** - When task was last modified
- **CompletedAt** - When task was marked complete
- **LastModifiedBy** - Who last modified (remote mode)

#### View History
```bash
# See when task was created/updated
tip task get 1 --verbose

# Show all task changes (future)
tip task history 1

# Changes in time range
tip task history 1 --from "2 weeks ago" --to today
```

## Advanced Features

### 1. Task Templates

Reusable task patterns:

```bash
# Create task from template
tip task template use weekly-standup

# Define custom templates
tip task template create daily-checklist \
  --items "Review emails,Check messages,Plan day"

# Available built-in templates
tip task template list
```

### 2. Recurring Tasks (Future)

Automatic task creation:

```bash
# Create recurring task
tip task add "Weekly standup" --recur weekly --due Friday

# Daily tasks
tip task add "Morning review" --recur daily

# Custom recurrence
tip task add "Sprint planning" --recur "every other week"
```

### 3. Task Dependencies (Future)

Link related tasks:

```bash
# Mark task depends on another
tip task depends 2 on 1  # Task 2 depends on Task 1

# View task dependencies
tip task get 1 --dependencies

# Filter by blocking/blocked
tip task list --blocked   # Tasks waiting on others
tip task list --blocking  # Tasks blocking others
```

### 4. Progress Tracking

#### Subtasks (Future)
```bash
# Add subtask
tip task subtask add 1 "Unit tests"
tip task subtask add 1 "Integration tests"
tip task subtask add 1 "Deploy to staging"

# Complete subtask
tip task subtask complete 1 2  # Complete subtask 2 of task 1

# View task with subtasks
tip task get 1 --verbose  # Shows progress: 2/3 complete
```

## Integration Features

### Password-Task Linking

Link tasks to password-protected resources:

```bash
# Task related to password
tip task add "Update github" --related password:github

# View related items
tip task get 1 --related
```

### Calendar Integration

View tasks on calendar:

```bash
# Show calendar for current month
tip task calendar

# Show tasks in week view
tip task calendar --view week

# Show tasks in day view
tip task calendar --view day
```

## Output Formatting

### List View
```bash
# Default table format
tip task list

# Compact format
tip task list --format compact

# JSON format (for scripting)
tip task list --format json

# CSV format
tip task list --format csv

# Count only
tip task list --count
```

### Details View
```bash
# Full task details
tip task get 1 --verbose

# Show in different formats
tip task get 1 --format json
tip task get 1 --format yaml
```

## Statistics and Reporting

### Task Statistics
```bash
# Count tasks by status
tip task stats

# Completion rate
tip task stats --metric completion

# Priority distribution
tip task stats --metric priority

# Burndown chart (future)
tip task chart --type burndown --from "2 weeks ago"
```

### Filtering Examples
```bash
# Show all overdue tasks
tip task list --due overdue

# Show this week's high priority items
tip task list --priority high --due "this week"

# Show my in-progress work
tip task list --status in_progress --category work

# Show all tasks tagged urgent
tip task list --tag urgent

# Show tasks from specific assignee
tip task list --assigned alice
```

## Command Aliases

Shorthand commands:

```bash
# List alias for `task list`
tip t list

# Add alias
tip t add "New feature"

# Complete alias
tip t complete 1

# Get alias
tip t get 1

# Search alias
tip t search "bug"
```

## Storage Modes

### Local Mode (JSON)
- All tasks stored in `~/.tip/vaults/<vault>/tasks.json`
- No encryption (optional)
- Fast for personal use

### Local Mode (SQLite)
- Tasks in local SQLite database
- Better performance with many tasks
- Full-text search capability

### Remote Mode
- Tasks synced with server
- Enabled collaboration
- Conflict resolution
- Accessible from multiple devices

## Best Practices

1. **Use Categories Consistently** - Keep tasks organized by type
2. **Set Realistic Due Dates** - Use smart date parsing for natural language
3. **Tag for Flexibility** - Add custom tags for filtering and reporting
4. **Update Status Regularly** - Keep task status current for accurate reporting
5. **Use Priority Wisely** - Don't mark everything as high priority
6. **Add Descriptions** - Include context for future reference
7. **Regular Review** - Weekly task review and updates
8. **Archive Completed** - Clear completed tasks periodically

## Testing

The Task Manager includes comprehensive tests:

```bash
# Run task tests
go test ./... -run Task

# With verbose output
go test ./... -run Task -v

# With coverage
go test ./... -run Task -cover
```

## Future Enhancements

- [ ] Recurring task automation
- [ ] Task dependencies and blocking
- [ ] Subtasks and milestones
- [ ] Time tracking integration
- [ ] Calendar integration
- [ ] Slack/Teams notifications
- [ ] Email reminders
- [ ] Mobile app support
- [ ] AI-powered prioritization
- [ ] Task templates library
