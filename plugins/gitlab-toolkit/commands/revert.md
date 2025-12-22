---
description: Revert commits or merge requests
argument-hint: "commit SHA | mr !id"
allowed-tools: Bash(curl:*), Bash(git:*), AskUserQuestion, TodoWrite
---

# GitLab Revert

You are helping a developer safely revert changes.

## Core Principles

- **Verify before reverting**: Show exactly what will be undone
- **Create paper trail**: Revert via MR for visibility
- **Preserve history**: Never rewrite shared history

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `commit SHA` - Revert a specific commit
- `mr !id` - Revert an entire merged MR
- (empty) - Show recent commits/MRs to revert

---

## Workflow: Revert Commit

**Phase 1: Get Commit Details**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/commits/[sha]" | \
  jq '{
    short_id,
    title,
    author_name,
    created_at,
    parent_ids,
    stats: {additions, deletions, total}
  }'

# Get files changed
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/commits/[sha]/diff" | \
  jq '.[] | {old_path, new_path}'
```

**Phase 2: Confirm Revert**

```
⏪ Revert Commit

Commit: abc1234
Title: feat: add new login validation
Author: @jane
Date: 2 hours ago

Changes to revert:
- src/auth/login.js (+45 -12)
- src/auth/validation.js (+89 lines, new file)
- tests/login.test.js (+23 -5)

This will create a new commit that undoes these changes.
The original commit will remain in history.

Proceed with revert?
```

**Phase 3: Create Revert**

```bash
# Via API (creates revert commit directly)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"branch": "main"}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/commits/[sha]/revert"
```

**Phase 4: Report Result**

```
✅ Commit reverted!

Original: abc1234 "feat: add new login validation"
Revert:   xyz7890 "Revert \"feat: add new login validation\""

Changes undone:
- src/auth/login.js (restored)
- src/auth/validation.js (deleted)
- tests/login.test.js (restored)

The revert has been pushed to main.
```

---

## Workflow: Revert MR

**Phase 1: Get MR Details**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
  jq '{
    iid,
    title,
    author: .author.username,
    merged_at,
    merge_commit_sha,
    squash_commit_sha,
    changes_count
  }'
```

**Phase 2: Confirm Revert**

```
⏪ Revert Merge Request

MR: !42 "Add OAuth support"
Author: @bob
Merged: 3 days ago
Merge commit: def5678

This MR included:
- 12 commits (squashed to 1)
- 8 files changed
- +234 -56 lines

Related issues that were closed:
- #120 "Implement OAuth" (will NOT reopen)

Creating revert MR will:
1. Create new branch: revert-!42
2. Add revert commit
3. Open MR for review

This ensures visibility and review before undo.

Proceed?
```

**Phase 3: Create Revert MR**

```bash
# Create revert via MR (safer for merged MRs)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/revert"
```

**Phase 4: Report Result**

```
✅ Revert MR created!

Original: !42 "Add OAuth support"
Revert:   !48 "Revert \"Add OAuth support\""

URL: https://gitlab.tepseg.com/.../merge_requests/48

Status: Open (needs review)
Pipeline: Running...

Next steps:
1. Review the revert changes
2. Approve and merge when ready
3. Investigate and fix the issue
4. Re-implement properly later
```

---

## Workflow: Show Revertable Items

When no arguments provided:

```
⏪ Recent Items to Revert

RECENT COMMITS (main):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
abc1234  feat: add login validation    @jane   2h ago
def5678  Merge !42 into main          @bob    3d ago
ghi9012  fix: button styling          @jane   3d ago

RECENT MERGED MRs:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
!42  Add OAuth support     @bob    3d ago
!41  Fix auth bug          @jane   5d ago
!40  Update dependencies   @alice  1w ago

Which would you like to revert?
```

---

## Workflow: Revert to Branch

For protected branches, revert to new branch:

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"branch": "revert-abc1234"}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/commits/[sha]/revert"
```

Then create MR from the revert branch.

---

## Smart Features

1. **Impact analysis**: Show what will be affected by revert
2. **Dependent detection**: Warn if later commits depend on this
3. **Test reminder**: Suggest running tests after revert
4. **Rollback MR**: Option to create proper MR for review

---

## Error Handling

- **Already reverted**: Commit was already reverted
- **Conflicts**: Cannot auto-revert, suggest manual approach
- **Protected branch**: Create revert on new branch + MR
- **Merge commit**: Warn about complexity, suggest MR revert
