# GitLab Toolkit Plugin

A comprehensive, intelligent workflow for GitLab project management with specialized agents for project initialization, MR review, and pipeline debugging.

## Overview

The GitLab Toolkit Plugin provides systematic approaches to GitLab administration and development workflows. Instead of just executing API calls, it guides you through understanding current state, making informed decisions, and validating results—ensuring your GitLab projects are properly configured and maintained.

## Philosophy

Managing GitLab projects requires more than just API commands. You need to:
- **Verify before acting**: Check current state before making changes
- **Ask clarifying questions**: Understand project needs and team preferences
- **Explain implications**: Know what each setting does before applying
- **Validate after changes**: Confirm settings were applied correctly

This plugin embeds these practices into intelligent workflows that run automatically when you use GitLab commands.

## TePS'EG GitLab

```bash
GITLAB_URL="https://gitlab.tepseg.com"
```

## Session Context (Auto-Detection)

When you start a Claude session in a GitLab project, the plugin automatically shows your current work status:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 my-project (feature/user-profile, 2 uncommitted)
📋 내 이슈 (2)
   → #45 사용자 프로필 리팩토링
   → #46 API 문서 업데이트
🔀 내 MR (1)
   → !23 feat: user profile refactor
📝 미커밋 (2 files)
   M src/components/UserProfile.tsx
   M src/hooks/useUser.ts
📌 최근: a1b2c3d refactor: split useUser hook
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Displayed information:**
- Current branch and git status
- My assigned issues (opened)
- My MRs (opened)
- Uncommitted changes
- Last commit

This enables seamless session continuity - Claude knows exactly where you left off.

---

## Setup

### 1. Environment Variables

```bash
# Linux/macOS
export GITLAB_URL="https://gitlab.tepseg.com"
export GITLAB_TOKEN="glpat-xxxxxxxxxxxx"
export GITLAB_PROJECT_ID="206"

# Windows PowerShell
$env:GITLAB_URL = "https://gitlab.tepseg.com"
$env:GITLAB_TOKEN = "glpat-xxxxxxxxxxxx"
$env:GITLAB_PROJECT_ID = "206"
```

### 2. Personal Access Token

GitLab > Settings > Access Tokens:
- `api` - Full API access (recommended)
- `read_repository` / `write_repository`
- `read_registry` / `write_registry`

### 3. Verify Setup

```bash
./skills/gitlab-toolkit/scripts/check-env.sh
```

---

## Main Command: `/gitlab-toolkit`

Launches a guided GitLab project setup and management workflow.

**Usage:**
```bash
/gitlab-toolkit project setup
```

Or simply:
```bash
/gitlab-toolkit
```

The command will guide you through project configuration interactively.

## The 7-Phase Workflow

### Phase 1: Environment Verification

**Goal**: Ensure GitLab connection is properly configured

**What happens:**
- Checks GITLAB_URL, GITLAB_TOKEN, GITLAB_PROJECT_ID
- Tests API connection
- Verifies user permissions

**If environment not configured:**
```
Missing environment variables. Please set:
export GITLAB_URL="https://gitlab.tepseg.com"
export GITLAB_TOKEN="glpat-xxxxxxxxxxxx"
export GITLAB_PROJECT_ID="your-project-id"
```

**Critical**: Workflow will NOT proceed without valid environment.

### Phase 2: Project Discovery

**Goal**: Understand current project state and needs

**What happens:**
- Fetches current project settings
- Checks protected branches, labels, milestones
- Identifies what's configured vs missing
- **Asks about project needs**:
  - Project type (Web app, API, Library)
  - Team size (Solo, Small, Large)
  - Branching strategy (Git Flow, GitHub Flow)
  - CI/CD requirements

**Example output:**
```
Current Project State:
✅ Container Registry - enabled
❌ main branch - not protected
❌ Labels - only 2 configured
❌ Issue Board - not set up

What type of project is this?
```

### Phase 3: Security Configuration

**Goal**: Set up branch protection and security settings

**What happens:**
- **Presents protection options to user**:
  - Strict (main): No direct push, Maintainers merge
  - Standard (develop): Developers push, no force push
  - Light (feature): Everyone push, no force push
- **Waits for user approval before applying**
- Applies protection rules
- Verifies settings were applied

**Example:**
```
I recommend the following branch protection:

main branch:
- Direct push: DISABLED (MR only)
- Force push: DISABLED
- Merge: Maintainers only
- Pipeline must succeed: YES

Do you want to apply these settings?
```

### Phase 4: Labels & Organization

**Goal**: Set up label system for issue tracking

**What happens:**
- Presents label scheme options:
  - Type labels (bug, feature, enhancement, docs)
  - Priority labels (priority::critical, priority::high, etc.)
  - Status labels (status::todo, status::in-progress, etc.)
- **Waits for user approval**
- Creates labels
- Sets up Issue Board with status columns

### Phase 5: CI/CD Configuration

**Goal**: Set up CI/CD variables and registries

**What happens:**
- Checks existing CI/CD configuration
- **Asks about needs**:
  - Environments (dev, staging, production)
  - Secrets to store
  - Container/Package registry needs
- Creates variables with proper protection (masked for secrets)
- Enables registries if needed

### Phase 6: Webhooks & Integrations

**Goal**: Set up external integrations

**What happens:**
- **Asks about integrations**:
  - Slack notifications
  - Discord notifications
  - External CI triggers
- Configures webhooks with proper events
- Tests webhook delivery

### Phase 7: Validation & Summary

**Goal**: Verify all settings and document what was done

**Example output:**
```
✅ GitLab Project Setup Complete

Security:
- main branch protected (no direct push)
- Force push disabled
- MR required for all changes

Organization:
- 12 labels created (type, priority, status)
- Issue board configured with 4 columns

CI/CD:
- 3 protected variables set
- Container registry enabled

Next steps:
- Add team members with appropriate roles
- Create first milestone
- Set up pipeline schedules
```

---

## Commands (46 Total)

### Bootstrap & Setup

| Command | Hint | Description |
|---------|------|-------------|
| `/gl-bootstrap` | `[group] [subgroup] [project]` | Create groups, subgroups, projects, invite members (detects .git) |
| `/gl-group` | `create\|list\|members\|settings` | Group/Subgroup management |
| `/gl-transfer` | `move\|archive\|export\|import` | Transfer project, archive/unarchive |
| `/gl-templates` | `nodejs\|python\|docker\|k8s` | Generate CI/CD pipeline templates |
| `/gl-audit` | `access\|tokens\|security` | Access & permission audit |

### Git Operations

| Command | Hint | Description |
|---------|------|-------------|
| `/gl-commit` | - | Stage and commit with conventional message |
| `/gl-clean-branches` | - | Clean up [gone] branches and worktrees |

### Core Management

| Command | Hint | Description |
|---------|------|-------------|
| `/gl-issue` | `create\|assign\|link\|confidential\|comments` | Issue, Assignees, Links, Comments |
| `/gl-mr` | `create\|merge\|review\|approve\|comments` | MR, Reviewers, Approvals, Discussions |
| `/gl-inbox` | `reviews\|approvals\|assigned\|todos` | My pending items dashboard |
| `/gl-milestone` | `create\|close\|list` | Milestones |
| `/gl-labels` | `create\|list\|delete` | Labels (Scoped) |
| `/gl-release` | `v1.0.0 [--notes]` | Release & Tags |
| `/gl-wiki` | `create\|update\|list` | Wiki Pages |
| `/gl-snippet` | `create\|list\|delete` | Code Snippets |
| `/gl-board` | `create\|list\|add-list` | Issue Board |

### CI/CD

| Command | Hint | Description |
|---------|------|-------------|
| `/gl-pipeline` | `run\|cancel\|retry\|schedule` | Pipeline & Schedules |
| `/gl-variables` | `create KEY VALUE [--masked]` | CI/CD Variables |
| `/gl-runners` | `list\|register\|pause` | Runners |
| `/gl-environments` | `create\|stop\|list` | Deployment Environments |
| `/gl-coverage` | `!id\|report\|diff` | Test Coverage Reports |

### Registry & Access

| Command | Hint | Description |
|---------|------|-------------|
| `/gl-registry` | `list\|tags\|delete` | Container & Package Registry |
| `/gl-deploy-keys` | `list\|add\|remove` | SSH Deploy Keys for CI/CD |
| `/gl-tokens` | `create\|revoke\|list` | Project/Group Access Tokens |
| `/gl-security` | `vulns\|deps\|audit` | Vulnerabilities & Dependencies |

### Project Settings

| Command | Hint | Description |
|---------|------|-------------|
| `/gl-project` | `protect\|registry\|badges` | Protected Branches, Registry |
| `/gl-settings` | `show\|update` | Project Settings |
| `/gl-members` | `add\|remove\|list` | Members & Permissions |
| `/gl-webhook` | `create\|list\|delete` | Webhooks |
| `/gl-cleanup` | `registry\|pipelines` | Resource Cleanup |
| `/gl-template` | `list\|issue\|mr\|create` | Issue/MR Templates |
| `/gl-notify` | `settings\|mute\|watch` | Notification Settings |

### Repository Operations

| Command | Hint | Description |
|---------|------|-------------|
| `/gl-files` | `browse\|view\|edit\|create` | Browse & Edit Files |
| `/gl-blame` | `file:line` | Line-by-Line History |
| `/gl-tags` | `list\|create\|delete\|protect` | Git Tags Management |
| `/gl-compare` | `main...feature` | Branch Comparison |
| `/gl-revert` | `commit SHA\|mr !id` | Revert Commits/MRs |
| `/gl-cherry-pick` | `SHA --to branch` | Cherry-Pick Commits |
| `/gl-conflicts` | `!id\|check\|resolve` | Conflict Resolution |
| `/gl-fork` | `create\|sync\|upstream` | Fork Management |

### Workflow Helpers

| Command | Hint | Description |
|---------|------|-------------|
| `/gl-search` | `query [--scope]` | Search Issues, MRs, Code |
| `/gl-activity` | `[--since today]` | Project Activity Feed |
| `/gl-stats` | `[--period month]` | Project Statistics |
| `/gl-draft` | `!id\|ready !id` | Draft/WIP MR Management |
| `/gl-auto-merge` | `!id\|cancel !id` | Auto-Merge on Pipeline Success |

---

## Agents (8 Total)

### Project & Infrastructure

#### `gitlab-project-initializer`
Sets up GitLab projects with production-ready configuration including branch protection, labels, boards, and CI/CD settings.

#### `gitlab-pipeline-debugger`
Analyzes failed pipelines, identifies root causes, and suggests fixes.

#### `gitlab-security-auditor`
Audits project security including vulnerabilities, dependencies, and settings.

### Git & Repository

#### `gitlab-git-workflow`
Handles Git operations including commits, branch cleanup, and worktree management.

#### `gitlab-code-navigator`
Navigates repository files, history, and branches. Handles blame, compare, cherry-pick, revert, and tags.

### Issue & MR Management

#### `gitlab-issue-manager`
Manages GitLab issues, labels, and milestones.

#### `gitlab-mr-workflow`
Manages Merge Requests including creation, review, conflicts, and merging.

### Registry & Access

#### `gitlab-registry-manager`
Manages Container Registry, Package Registry, Deploy Keys, and Access Tokens.

---

## Usage Examples

### Bootstrap New GitLab Project

```bash
/gl-bootstrap
```

**What happens:**
1. Checks for `.git` directory
2. If no .git: Guides through group/subgroup/project creation
3. If .git exists: Offers to connect to existing or create new project
4. Interactive numbered selection for groups, subgroups, members
5. Sets up git remote and pushes initial commit
6. Optionally invites team members

### Protect main branch (no direct push)

```bash
/gl-project protect main
```

**What happens:**
1. Shows current protection status
2. Presents protection level options (Strict/Standard/Light)
3. Waits for your choice
4. Applies protection
5. Verifies and reports result

### Create Issue with Time Tracking

```bash
/gl-issue create "Bug: Login fails on Safari" --labels bug
/gl-issue estimate #123 8h
/gl-issue spend #123 4h
```

**What happens:**
1. Asks for issue details (type, priority)
2. Shows preview before creation
3. Creates issue
4. Reports result with URL

### Create MR with Issue linking

```bash
/gl-mr create --closes 123
```

**What happens:**
1. Checks for uncommitted changes
2. Verifies branch is pushed
3. Analyzes commits for title suggestion
4. Asks for MR details (title, description, reviewers)
5. Shows preview
6. Creates MR with `Closes #123`
7. Reports result with URL and next steps

### Schedule Nightly Pipeline

```bash
/gl-pipeline schedule "Nightly Build" --cron "0 2 * * *"
```

### Clean Container Registry

```bash
/gl-cleanup registry --older-than 30d --keep 10
```

### Check My Inbox (Pending Reviews/Approvals)

```bash
/gl-inbox
```

**What happens:**
1. Shows MRs where you're a reviewer
2. Shows MRs awaiting your approval
3. Shows issues/MRs assigned to you
4. Shows GitLab todos (mentions, notifications)
5. Offers quick actions for each item

### Manage Issue Assignees

```bash
/gl-issue assign #123 @jane
```

**What happens:**
1. Shows current assignees
2. Presents add/remove options
3. Updates assignees
4. Reports who was notified

### Link Related Issues

```bash
/gl-issue link #123
```

**What happens:**
1. Shows current linked issues
2. Asks for link type (related, blocked by, blocking)
3. Creates the link
4. Warns about blocking dependencies

### Set Issue Confidential

```bash
/gl-issue confidential #123
```

**What happens:**
1. Explains confidentiality implications
2. Confirms the change
3. Shows who can still see the issue

### Manage MR Reviewers

```bash
/gl-mr review !45
```

**What happens:**
1. Shows current reviewers
2. Allows adding/removing reviewers
3. Sends notification to new reviewers

### Approve/Unapprove MR

```bash
/gl-mr approve !45
```

**What happens:**
1. Shows current approval status
2. Checks if you can approve
3. Applies your approval
4. Reports if MR is ready to merge

### View MR Comments & Discussions

```bash
/gl-mr comments !45
```

**What happens:**
1. Shows all discussions (resolved/unresolved)
2. Allows replying to specific threads
3. Can resolve discussions
4. Supports line-by-line code comments

---

## When to Use This Plugin

**Use for:**
- New project setup and configuration
- Branch protection and security hardening
- Issue and MR management with proper workflows
- CI/CD configuration and troubleshooting
- Team onboarding (standardized labels, boards)
- Production readiness checks

**Don't use for:**
- Simple git operations (use git directly)
- One-off API calls (use curl)
- Non-GitLab repositories

---

## Production Checklist

### Required

- [ ] main branch protected (`push_access_level: 0`)
- [ ] Force Push disabled
- [ ] MR required (Pipeline must succeed)
- [ ] CODEOWNERS configured
- [ ] CI/CD Variables masked

### Recommended

- [ ] Scoped Labels system
- [ ] Kanban Board
- [ ] Webhooks (Slack/Discord)
- [ ] Pipeline Schedules
- [ ] Registry Cleanup automation

---

## Troubleshooting

### Environment variables not set

**Issue**: Commands fail with "Missing environment variables"

**Solution**:
```bash
export GITLAB_URL="https://gitlab.tepseg.com"
export GITLAB_TOKEN="glpat-xxxxxxxxxxxx"
export GITLAB_PROJECT_ID="your-project-id"
```

Run `./skills/gitlab-toolkit/scripts/check-env.sh` to verify.

### 401 Unauthorized

**Issue**: API calls return 401

**Solution**:
- Token expired: Generate new one in GitLab > Settings > Access Tokens
- Token scopes insufficient: Ensure `api` scope is included
- Wrong token: Verify GITLAB_TOKEN value

### 403 Forbidden

**Issue**: API calls return 403

**Solution**:
- Check your project role (need Maintainer+ for protected branches)
- Verify token has correct scopes
- Some features require Premium (Approval Rules, Push Rules)

### 404 Not Found

**Issue**: API calls return 404

**Solution**:
- Verify GITLAB_PROJECT_ID is correct
- Project may have been renamed or moved
- Use project ID (number) not path

### Branch already protected

**Issue**: Cannot protect branch, returns 409

**Solution**:
- This is often fine—branch is already protected
- To update, first unprotect then reprotect
- Or use update API endpoint

### Pipeline keeps failing

**Issue**: Pipeline fails after configuration

**Solution**:
1. Check job logs: `/gl-pipeline logs [job_id]`
2. Common causes:
   - Missing CI/CD variables
   - Docker image issues
   - Test failures
   - Resource limits

---

## Tips

- **Verify environment first**: All commands check env before acting
- **Trust the previews**: Commands show what will happen before doing it
- **Use workflow commands**: They guide you through complex operations
- **Check current state**: Commands show existing config before changes
- **Read error messages**: They include specific fixes

---

## Skills

| Skill | Description |
|-------|-------------|
| `gitlab-toolkit` | GitLab workflow automation (auth, patterns, error handling) |

### Skill Structure

```
skills/gitlab-toolkit/
├── SKILL.md              # Main (workflow decision tree)
├── references/           # Detailed docs
│   ├── api-patterns.md   # API call patterns, jq
│   ├── error-handling.md # Error codes, responses
│   └── protected-branches.md  # Branch protection
├── examples/             # Executable scripts
│   ├── project-init.sh   # Project initialization
│   └── cleanup.sh        # Resource cleanup
└── scripts/              # Utilities
    └── check-env.sh      # Environment check
```

---

## Directory Structure

```
gitlab-toolkit/
├── .claude-plugin/
│   └── plugin.json
├── commands/                          # 46 Slash Commands
│   ├── gitlab-toolkit.md              # Main workflow (7 phases)
│   ├── bootstrap.md                   # Project bootstrap (groups, subgroups, members)
│   ├── group.md                       # Group/Subgroup management
│   ├── transfer.md                    # Project transfer/archive
│   ├── templates-cicd.md              # CI/CD templates generator
│   ├── audit.md                       # Access & permission audit
│   │
│   │ # Core Management
│   ├── issue.md                       # Issue, Assignees, Links, Comments
│   ├── mr.md                          # MR, Reviewers, Approvals, Discussions
│   ├── inbox.md                       # My pending items dashboard
│   ├── milestone.md                   # Milestones
│   ├── labels.md                      # Labels (Scoped)
│   ├── release.md                     # Release, Tags
│   ├── wiki.md                        # Wiki Pages
│   ├── snippet.md                     # Code Snippets
│   ├── board.md                       # Issue Board
│   │
│   │ # CI/CD
│   ├── pipeline.md                    # Pipeline, Schedules
│   ├── variables.md                   # CI/CD Variables
│   ├── runners.md                     # Runners
│   ├── environments.md                # Deployment Environments
│   ├── coverage.md                    # Test Coverage
│   │
│   │ # Project Settings
│   ├── project.md                     # Protected Branches, Registry
│   ├── settings.md                    # Project Settings
│   ├── members.md                     # Members/Permissions
│   ├── webhook.md                     # Webhooks
│   ├── cleanup.md                     # Resource Cleanup
│   ├── template.md                    # Issue/MR Templates
│   ├── notify.md                      # Notification Settings
│   │
│   │ # Repository Operations
│   ├── files.md                       # Browse & Edit Files
│   ├── blame.md                       # Line-by-Line History
│   ├── tags.md                        # Git Tags
│   ├── compare.md                     # Branch Comparison
│   ├── revert.md                      # Revert Commits/MRs
│   ├── cherry-pick.md                 # Cherry-Pick
│   ├── conflicts.md                   # Conflict Resolution
│   ├── fork.md                        # Fork Management
│   │
│   │ # Workflow Helpers
│   ├── search.md                      # Search
│   ├── activity.md                    # Activity Feed
│   ├── stats.md                       # Statistics
│   ├── draft.md                       # Draft MR
│   └── auto-merge.md                  # Auto-Merge
│
├── skills/
│   └── gitlab-toolkit/                # GitLab Toolkit Skill
│       ├── SKILL.md
│       ├── references/
│       ├── examples/
│       └── scripts/
├── agents/
│   ├── project-initializer.md         # Project setup agent
│   ├── pipeline-debugger.md           # Pipeline debug agent
│   ├── git-workflow.md                # Git commit & branch cleanup
│   ├── issue-manager.md               # Issue, labels, milestones
│   ├── mr-workflow.md                 # MR lifecycle management
│   ├── code-navigator.md              # File history, blame, tags
│   ├── registry-manager.md            # Registry, deploy keys, tokens
│   └── security-auditor.md            # Security & vulnerability audit
├── hooks/
│   ├── hooks.json                     # Hook configuration
│   └── scripts/
│       └── detect-gitlab.sh           # SessionStart auto-detection
└── README.md
```

---

## Version

1.0.0

## Author

deekee (burlesquer@yonsei.ac.kr)
