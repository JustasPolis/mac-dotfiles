---
name: jira
description: Manages JIRA issues, projects, and workflows using jira cli. Use when asked to "create JIRA ticket", "search JIRA", "update JIRA issue", "transition issue", "sprint planning", or "epic management".
---

# JIRA Management Skill

A comprehensive skill for managing JIRA issues, projects, and workflows.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [API Choice](#api-choice)
- [Skill Workflow](#skill-workflow)
  - [Bug Creation](#1-bug-creation-workflow)
  - [Issue Search and Management](#2-issue-search-and-management)
  - [Attachments](#3-attachments)
  - [Sprint Management](#4-sprint-management)
- [POD Project Specifics](#pod-project-specifics)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

This skill provides intelligent JIRA management capabilities including:
- Creating and managing issues with proper field validation
- Searching and filtering issues using JQL
- Managing workflows and transitions
- Working with epics, sprints, and agile boards
- Adding comments, attachments, and links

## Prerequisites

### Environment Configuration
- `JIRA_API_TOKEN`: API token for authentication
- JIRA user email for authentication

## API Choice

### Use JIRA REST API for:
- **Creating issues** - jira cli has problems with required custom fields
- **Updating issues** - better control over field formats
- **Attachments** - cli doesn't support attachments

### Use jira cli for:
- **Sprint management** (`jira sprint list`, `jira sprint add`)
- **Viewing issues** (`jira issue view`)
- **Simple searches** (`jira issue list`)

## Skill Workflow

### 1. Bug Creation Workflow

#### Step 1: Gather Requirements
Ask the user for:
- **Project key** (e.g., "POD") - NEVER ASSUME
- **Summary** (title) - use format `[Platform] Description` (e.g., `[iOS] Bug title`)
- **Priority** (Lowest, Low, Medium, High, Highest)
- **Labels** (e.g., iOS, Android)
- **Sprint** - ask which sprint to add to
- **Steps to Reproduce** - clear steps to reproduce the bug
- **Actual Results** - what actually happens (the bug behavior)
- **Expected Results** - what should happen instead
- **Attachments** - screenshots or files to attach

#### Step 2: Field Guidelines

**Description field:**
- Use ONLY for explaining "why this is a bug" or additional context
- Do NOT put steps/actual/expected in description
- Can be left empty/null if the bug is self-explanatory

**Separate fields for bugs:**
- Steps to Reproduce -> `customfield_10029`
- Actual Results -> `customfield_10043`
- Expected Results -> `customfield_10044`

#### Step 3: Create Bug via REST API

```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  -u "USER_EMAIL:$JIRA_API_TOKEN" \
  "https://podimo.atlassian.net/rest/api/3/issue" \
  -d '{
    "fields": {
      "project": {"key": "PROJECT_KEY"},
      "issuetype": {"name": "Bug"},
      "summary": "[Platform] Bug summary",
      "priority": {"name": "Medium"},
      "labels": ["iOS"],
      "description": null,
      "customfield_10030": "user@example.com",
      "customfield_10124": {"id": "10236"},
      "customfield_10029": {
        "type": "doc",
        "version": 1,
        "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Steps here"}]}]
      },
      "customfield_10043": {
        "type": "doc",
        "version": 1,
        "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Actual result here"}]}]
      },
      "customfield_10044": {
        "type": "doc",
        "version": 1,
        "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Expected result here"}]}]
      }
    }
  }'
```

#### Step 4: Add to Sprint
After creating the issue, add to sprint using jira cli:
```bash
jira sprint add <SPRINT_ID> <ISSUE_KEY>
```

### 2. Issue Search and Management

Use jira cli for searching:
```bash
# List issues in a project
jira issue list --project POD

# Search with JQL
jira issue list --jql "project = POD AND type = Bug AND labels = iOS"

# View specific issue
jira issue view POD-12345
```

### 3. Attachments

Use REST API for attachments:

```bash
# First copy file to remove spaces in filename if needed
cp "/path/with spaces/file.png" /tmp/attachment.png

# Upload attachment
curl -s -X POST \
  -u "USER_EMAIL:$JIRA_API_TOKEN" \
  -H "X-Atlassian-Token: no-check" \
  -F "file=@/tmp/attachment.png" \
  "https://podimo.atlassian.net/rest/api/3/issue/ISSUE_KEY/attachments"
```

**Important:** File paths with spaces cause issues with curl. Copy the file to /tmp with a simple filename first.

### 4. Sprint Management

```bash
# List sprints for a project
jira sprint list --table --plain --project POD --state active,future

# Add issue to sprint
jira sprint add <SPRINT_ID> <ISSUE_KEY>
```

## POD Project Specifics

### Required Custom Fields for Bugs
| Field | Custom Field ID | Notes |
|-------|-----------------|-------|
| User Account | customfield_10030 | Email address (required) |
| Bug type | customfield_10124 | Use `{"id": "10236"}` for "Production bug" |
| Steps to reproduce | customfield_10029 | ADF format |
| Actual results | customfield_10043 | ADF format |
| Expected results | customfield_10044 | ADF format |

### Bug Type Options
| ID | Value |
|----|-------|
| 10236 | Production bug |

### Common Sprints
| ID | Name | Use Case |
|----|------|----------|
| 571 | Bugs | Platform-specific bugs with [iOS]/[Android] prefix |
| 570 | Bugs | General/mixed backlog items |
| 1660 | Quality improvements | Technical tasks (cleanup, refactoring, tech debt) |

### Default Values for iOS Tasks
- **Default label**: `ios`
- **Default sprint for technical tasks**: Quality improvements (ID: 1660)

### Atlassian Document Format (ADF)
Rich text fields require ADF format:
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [{"type": "text", "text": "Your text here"}]
    }
  ]
}
```

## Best Practices

1. **Bug titles**: Use platform prefix `[iOS]`, `[Android]`, `[MOB]`, `[Web]`
2. **Description**: Keep empty or minimal - use dedicated fields for steps/actual/expected
3. **Attachments**: Always attach screenshots for visual bugs
4. **Sprints**: Use sprint 571 for platform-specific bugs
5. **Labels**: Add platform label (iOS, Android) for filtering

## Troubleshooting

### jira cli custom field errors
**Problem:** `customfield_XXXXX is required` errors when using jira cli
**Solution:** Use REST API instead - jira cli has issues with required custom fields

### Attachment upload fails
**Problem:** `Failed to open/read local data from file/application`
**Solution:** Copy file to /tmp with simple filename (no spaces)

### HTTP 000 response
**Problem:** curl returns HTTP code 000
**Solution:** Check file path, ensure no special characters in filename
