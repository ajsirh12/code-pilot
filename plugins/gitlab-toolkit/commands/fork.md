---
description: Manage forks - create, sync with upstream, contribute back
argument-hint: "create | sync | upstream | list"
allowed-tools: Bash(curl:*), Bash(git:*), AskUserQuestion, TodoWrite
---

# GitLab Fork Management

You are helping a developer manage forked repositories.

## Core Principles

- **Stay in sync**: Keep fork updated with upstream
- **Contribute back**: Easy MR to upstream
- **Track origin**: Always know where code came from

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `create` - Fork a project
- `sync` - Sync fork with upstream
- `upstream` - Show upstream info and changes
- `list` - List your forks
- `mr` - Create MR to upstream
- (empty) - Show fork status

---

## Workflow: Fork Status

**Phase 1: Check If This Is a Fork**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" | \
  jq '{
    name,
    forked_from_project: .forked_from_project.path_with_namespace,
    fork_sync_enabled: .import_status
  }'
```

**Phase 2: Present Status**

```
🍴 Fork Status

Your fork: username/project
Upstream: original-team/project

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SYNC STATUS:

Branch: main
Your fork:  abc1234 (2 commits ahead)
Upstream:   xyz7890 (5 commits behind)

⚠️  Your fork is out of sync!

Commits in upstream not in your fork:
- xyz7890 feat: add new API endpoint
- uvw5678 fix: security patch
- rst3456 docs: update README
- opq2345 refactor: improve performance
- lmn1234 chore: update dependencies

Commits in your fork not in upstream:
- abc1234 feat: my new feature
- def5678 fix: local bug fix

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
1. Sync with upstream (merge)
2. Sync with upstream (rebase)
3. Create MR to upstream
4. View upstream changes

What would you like to do?
```

---

## Workflow: Create Fork

**Phase 1: Get Project to Fork**

```bash
# Get source project details
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/[source_project_id]" | \
  jq '{name, path_with_namespace, visibility, forks_count}'
```

**Phase 2: Confirm Fork**

```
🍴 Create Fork

Source: original-team/awesome-project
Visibility: Public
Stars: 234
Forks: 45

Fork will be created as: your-username/awesome-project

This will:
1. Copy all branches and tags
2. Copy all files and history
3. Set up upstream tracking

Create fork?
```

**Phase 3: Create Fork**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"namespace_id": "[your_namespace_id]"}' \
  "$GITLAB_URL/api/v4/projects/[source_project_id]/fork"
```

**Phase 4: Report Result**

```
✅ Fork created!

Your fork: your-username/awesome-project
URL: https://gitlab.tepseg.com/your-username/awesome-project

Upstream: original-team/awesome-project

Next steps:
1. Clone your fork:
   git clone git@gitlab.tepseg.com:your-username/awesome-project.git

2. Add upstream remote:
   git remote add upstream git@gitlab.tepseg.com:original-team/awesome-project.git

3. Start working on your changes
```

---

## Workflow: Sync with Upstream

**Phase 1: Check Sync Status**

```bash
# Compare fork with upstream
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/compare?from=main&to=forked_from_project:main"
```

**Phase 2: Choose Sync Method**

```
🔄 Sync with Upstream

Your fork is 5 commits behind upstream.

Sync methods:
1. Merge (recommended)
   - Creates merge commit
   - Preserves your history
   - Safe, no force push needed

2. Rebase
   - Cleaner history
   - Requires force push
   - May lose local commits if not careful

Which method?
```

**Phase 3: Sync via Merge**

```bash
# Using git commands
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

**Phase 4: Report Result**

```
✅ Fork synced!

Merged 5 commits from upstream:
- xyz7890 feat: add new API endpoint
- uvw5678 fix: security patch
- rst3456 docs: update README
- opq2345 refactor: improve performance
- lmn1234 chore: update dependencies

Your fork is now up to date with upstream.
Your local changes (2 commits) are preserved.
```

---

## Workflow: Create MR to Upstream

**Phase 1: Prepare MR**

```
🔀 Create MR to Upstream

Your branch: feature/my-improvement
Target: original-team/project (main)

Commits to contribute:
- abc1234 feat: add dark mode support
- def5678 feat: add theme configuration
- ghi9012 docs: update theme documentation

This will create a Merge Request in the upstream project.

Proceed?
```

**Phase 2: Create Cross-Fork MR**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "source_branch": "feature/my-improvement",
    "target_branch": "main",
    "target_project_id": [upstream_project_id],
    "title": "Add dark mode support",
    "description": "Adds configurable theme support..."
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests"
```

**Phase 3: Report Result**

```
✅ MR created in upstream project!

MR: !234 "Add dark mode support"
Target: original-team/project
Branch: feature/my-improvement → main

URL: https://gitlab.tepseg.com/original-team/project/-/merge_requests/234

The upstream maintainers will review your contribution.
```

---

## Workflow: List Your Forks

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects?owned=true" | \
  jq '.[] | select(.forked_from_project != null) | {
    name,
    fork_of: .forked_from_project.path_with_namespace,
    last_activity
  }'
```

Present as:
```
🍴 Your Forks (3)

awesome-project
  ↳ Forked from: original-team/awesome-project
  ↳ Last activity: 2 days ago
  ↳ Status: 3 commits behind

cool-library
  ↳ Forked from: cool-org/cool-library
  ↳ Last activity: 1 week ago
  ↳ Status: Up to date ✅

old-project
  ↳ Forked from: legacy/old-project
  ↳ Last activity: 3 months ago
  ↳ Status: 45 commits behind ⚠️
```

---

## Smart Features

1. **Auto-sync reminders**: Warn when far behind upstream
2. **Conflict detection**: Check for conflicts before sync
3. **Branch tracking**: Track which branches exist upstream
4. **Contribution stats**: Show your contributions to upstream

---

## Error Handling

- **Not a fork**: Project is not forked
- **Upstream deleted**: Original project no longer exists
- **Permission denied**: Cannot fork private project
- **Conflicts**: Manual merge required
