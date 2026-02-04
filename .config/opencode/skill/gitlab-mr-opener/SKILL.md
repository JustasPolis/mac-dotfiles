---
name: gitlab-mr-opener
description: Creates GitLab merge requests using glab CLI. Use when asked to "create MR", "open MR", "create merge request", "open merge request", or when user shares a branch and wants to create an MR for it.
---

# GitLab MR Opener

Create merge requests using the `glab` CLI with proper templates and conventions.

## Prerequisites

- `glab` CLI installed and authenticated
- Git repository with GitLab remote

## Workflow

### 1. Gather Branch Info

```bash
# Get current branch
git branch --show-current

# Get commits ahead of base branch
git log origin/main..HEAD --oneline
# or
git log origin/develop..HEAD --oneline

# Check glab availability
glab --version
```

### 2. Find MR Template

Search for MR templates in standard locations:

```bash
# GitLab templates location
ls .gitlab/merge_request_templates/
```

Common template paths:
- `.gitlab/merge_request_templates/Merge Request.md`
- `.gitlab/merge_request_templates/default.md`

### 3. Ask User for MR Details

Before creating MR, confirm with user:
- **Target branch**: main, develop, or custom
- **MR title**: Suggest based on branch name/commits
- **Options**: squash commits, remove source branch, draft MR

## MR Title Format

Use this format for MR titles:
```
<TICKET-ID> <Description>
```

Examples:
- `POD-10589 Fix incorrect newsletter deeplink values`
- `POD-12345 Add user profile settings screen`
- `STAFF-100 Update analytics tracking`

Do NOT use brackets around the ticket ID or platform prefixes like `[iOS]`.

### 4. Review Changes

```bash
# Show diff to understand changes for description
git diff origin/<target-branch>..HEAD
```

### 5. Push Branch (if needed)

```bash
git push -u origin <branch-name>
```

### 6. Create MR with Template

Use HEREDOC to pass description with proper formatting:

```bash
glab mr create \
  --target-branch <target> \
  --title "<title>" \
  --squash-before-merge \
  --remove-source-branch \
  --description "$(cat <<'EOF'
### Task
<link to ticket>

### Description
<technical description of changes>

### Conformity
- [ ] Checklist item 1
- [ ] Checklist item 2

### Media
<screenshots/videos if UI changes>

<reviewers and assignments from template>
EOF
)"
```

## MR Description Guidelines

### Task Section
- Link to JIRA/ticket if branch contains ticket ID (e.g., `POD-12345`)
- Format: `https://podimo.atlassian.net/browse/POD-12345`

### Description Section
Based on git diff, summarize:
- What the change does
- Why it was done this way
- Key files/components affected

### Conformity Section
Copy checklist from template as-is for user to check later.

### Media Section
- Write "N/A - No UI changes" if no UI changes
- Otherwise, placeholder for user to add screenshots

### Reviewers/Assignments
Copy reviewer assignments from template (e.g., `/assign me`, `/assign_reviewer @user`).

## Common Options

| Flag | Description |
|------|-------------|
| `--target-branch` | Target branch for merge |
| `--title` | MR title |
| `--squash-before-merge` | Squash commits on merge |
| `--remove-source-branch` | Delete branch after merge |
| `--draft` | Create as draft/WIP |
| `--description` | MR description body |

## Output

Return the MR URL to user when complete:
```
https://gitlab.com/<namespace>/<project>/-/merge_requests/<id>
```
