---
description: Create and manage GitLab Merge Requests with intelligent workflow
argument-hint: "create | merge !id | review !id | approve !id | comments !id | list"
allowed-tools: Bash(curl:*), Bash(git:*), AskUserQuestion, TodoWrite
---

# GitLab Merge Request Management

You are helping a developer manage GitLab Merge Requests. Follow a systematic approach: understand current state, gather requirements, create MR, and verify.

## Core Principles

- **Check git status first**: Ensure changes are committed and pushed
- **Detect linked issues**: Offer to auto-link related issues
- **Follow project conventions**: Match existing MR title/description patterns
- **Verify before creating**: Show preview and wait for approval

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `create` - Create MR from current branch
- `create --closes #id` - Create MR that closes an issue
- `merge !id` - Merge an MR
- `list` - List open MRs
- `review !id` - Manage reviewers (add/remove/list)
- `approve !id` - Approve or unapprove an MR
- `comments !id` - View and add comments/discussions
- (empty) - Analyze current branch and suggest action

---

## Context Gathering

**Always start by gathering context:**

```bash
# Current branch
git branch --show-current

# Default branch
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'

# Unpushed commits
git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline -5

# Uncommitted changes
git status --short

# Recent commits on this branch
git log --oneline -10
```

---

## Workflow: Create MR

**Phase 1: Pre-flight Checks**

1. Check for uncommitted changes:
   - If found, **ask user**: "You have uncommitted changes. Commit first?"
   - If user agrees, help create commit

2. Check if branch is pushed:
   - If not pushed, **ask user**: "Branch not pushed. Push now?"
   - Push with `-u` flag

3. Check if MR already exists:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?source_branch=$(git branch --show-current)&state=opened"
   ```
   - If exists, show link and ask what to do

**Phase 2: Gather MR Details**

1. Analyze commits to suggest title:
   ```bash
   git log --oneline $(git merge-base HEAD origin/main)..HEAD
   ```

2. **Ask user for MR details** using AskUserQuestion:
   - Title? (suggest based on commits/branch name)
   - Link to issue? (show recent issues)
   - Description? (offer template)
   - Labels?
   - Reviewers?

3. If issue provided, format description with `Closes #id`

**Phase 3: Confirm Creation**

1. **Show preview**:
   ```
   I'll create this Merge Request:

   Title: Fix login bug on Safari
   Source: fix/login-safari → main
   Commits: 3

   Description:
   ## Summary
   - Fixed Safari-specific login issue
   - Added browser detection

   Closes #123

   Labels: bug, browser-compat
   Reviewers: @jane

   Options:
   - Delete source branch after merge: Yes
   - Squash commits: Yes

   Proceed?
   ```

2. **Wait for user approval**

**Phase 4: Create MR**

1. Create the MR:
   ```bash
   curl --request POST \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --header "Content-Type: application/json" \
     --data '{
       "source_branch": "[current-branch]",
       "target_branch": "main",
       "title": "[title]",
       "description": "## Summary\n\n[description]\n\nCloses #123",
       "labels": "bug",
       "remove_source_branch": true,
       "squash": true
     }' \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests"
   ```

2. **Report result**:
   ```
   ✅ Merge Request created!

   !45: Fix login bug on Safari
   URL: https://gitlab.tepseg.com/group/project/-/merge_requests/45

   Status: Open
   Pipeline: Running...
   Linked: Closes #123

   Next steps:
   - Wait for pipeline to pass
   - Get review from @jane
   - Merge when ready
   ```

---

## Workflow: Merge MR

**Phase 1: Verify MR Status**

1. Get MR details:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
     jq '{title, state, merge_status, has_conflicts, pipeline: .head_pipeline.status}'
   ```

2. **Check merge readiness**:
   - Pipeline passed?
   - No conflicts?
   - Approved? (if required)
   - Discussions resolved?

3. If not ready, **explain what's blocking**:
   ```
   ❌ Cannot merge !45 yet:

   - Pipeline: failed (1 job failed)
   - Conflicts: Yes (2 files)
   - Approvals: 0/1 required

   What would you like to do?
   - View pipeline logs
   - Resolve conflicts
   - Request approval
   ```

**Phase 2: Confirm Merge**

1. **Show merge preview**:
   ```
   Ready to merge !45:

   Title: Fix login bug on Safari
   Commits: 3 (will be squashed)
   Target: main
   Closes: #123

   Options:
   - Squash commits: Yes
   - Delete source branch: Yes

   Proceed with merge?
   ```

2. **Wait for user approval**

**Phase 3: Execute Merge**

1. Merge the MR:
   ```bash
   curl --request PUT \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --data "squash=true&should_remove_source_branch=true" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/merge"
   ```

2. **Report result**:
   ```
   ✅ Merged successfully!

   !45: Fix login bug on Safari
   Merged into: main
   Commit: abc1234

   Closed issues:
   - #123: Login fails on Safari

   Branch fix/login-safari deleted.
   ```

---

## Workflow: List MRs

1. Get open MRs:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?state=opened&per_page=20"
   ```

2. **Present as table**:
   ```
   Open Merge Requests (5):

   !45  Fix login bug           main ← fix/login    ✅ Pipeline passed   @john
   !44  Add dark mode           main ← feature/dark ⏳ Pipeline running  @jane
   !43  Update dependencies     main ← chore/deps   ❌ Pipeline failed   @john

   What would you like to do?
   ```

---

## Smart Features

1. **Branch name parsing**: Extract issue ID from branch name (e.g., `fix/123-login` → #123)
2. **Commit analysis**: Suggest title based on commit messages
3. **Template matching**: Match project's MR template if exists
4. **Auto-linking**: Detect issue references in commits

---

## Workflow: Manage Reviewers

**Phase 1: Get Current Reviewers**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
  jq '{reviewers: [.reviewers[].username], author: .author.username}'
```

**Phase 2: Present Options**

```
MR !45: Fix login bug on Safari

Current reviewers:
- @jane (assigned)
- @bob (assigned)

Available actions:
1. Add reviewer
2. Remove reviewer
3. Request re-review

What would you like to do?
```

**Phase 3: Add/Remove Reviewer**

```bash
# Get project members for selection
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/all?per_page=50" | \
  jq '.[] | {username, name, access_level}'

# Update reviewers
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"reviewer_ids": [user_id1, user_id2]}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]"
```

**Phase 4: Report Result**

```
✅ Reviewers updated for !45

Added: @alice
Removed: @bob

Current reviewers:
- @jane
- @alice

They will be notified via email.
```

---

## Workflow: Approve MR

**Phase 1: Check Approval Status**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/approvals" | \
  jq '{
    approved: .approved,
    approvals_required: .approvals_required,
    approvals_left: .approvals_left,
    approved_by: [.approved_by[].user.username]
  }'
```

**Phase 2: Present Status**

```
MR !45: Fix login bug on Safari

Approval Status:
- Required: 2 approvals
- Current: 1/2 ✅
- Approved by: @jane

You (@john) have not approved yet.

Actions:
1. Approve this MR
2. View changes first
3. Add comment instead

What would you like to do?
```

**Phase 3: Approve or Unapprove**

```bash
# Approve
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/approve"

# Unapprove (revoke)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/unapprove"
```

**Phase 4: Report Result**

```
✅ You approved !45

Approval Status: 2/2 ✅
- @jane
- @john (you)

This MR is now ready to merge!
```

---

## Workflow: Comments & Discussions

**Phase 1: Get Discussions**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/discussions" | \
  jq '.[] | {
    id,
    resolved: (.notes[0].resolvable and .notes[0].resolved),
    author: .notes[0].author.username,
    body: .notes[0].body,
    created_at: .notes[0].created_at,
    replies: (.notes | length - 1)
  }'
```

**Phase 2: Present Discussions**

```
MR !45: Fix login bug on Safari

Discussions (5 total, 2 unresolved):

🔴 Unresolved:
1. @jane (2h ago): "Should we add a test for Safari?"
   └─ 2 replies

2. @bob (1h ago): "Consider using feature detection instead"
   └─ No replies

🟢 Resolved:
3. @alice: "Typo in line 45" ✅

Actions:
1. Reply to discussion
2. Add new comment
3. Resolve discussion
4. View all comments

What would you like to do?
```

**Phase 3: Add Comment**

```bash
# Add general note
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"body": "LGTM! Great fix."}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/notes"

# Reply to discussion
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"body": "Good point, I will add tests."}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/discussions/[discussion_id]/notes"

# Resolve discussion
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "resolved=true" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/discussions/[discussion_id]"
```

**Phase 4: Report Result**

```
✅ Comment added to !45

Your comment:
"Good point, I will add tests in the next commit."

Discussion status:
- Unresolved: 2 → 1
- @jane's discussion now resolved

Tip: Use '/gl-mr comments !45 resolve-all' to resolve all discussions.
```

---

## Workflow: Add Line Comment

For code review comments on specific lines:

```bash
# Get diff positions
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/changes" | \
  jq '.changes[] | {old_path, new_path}'

# Add line comment
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "body": "Consider using const here",
    "position": {
      "base_sha": "[base_sha]",
      "start_sha": "[start_sha]",
      "head_sha": "[head_sha]",
      "position_type": "text",
      "new_path": "src/auth.js",
      "new_line": 45
    }
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/discussions"
```

---

## Error Handling

- **Not on feature branch**: Warn user, suggest creating branch first
- **Conflicts detected**: Offer to help resolve
- **Pipeline failed**: Show failed job logs
- **Merge blocked**: Explain blocking rules and how to resolve
- **Already approved**: Inform user, offer to unapprove
- **Cannot approve own MR**: Explain GitLab restriction
- **Discussion not found**: Show available discussion IDs
