---
description: Intelligent Draft MR management - prevent accidental merges, signal readiness
argument-hint: "!id | ready !id | list"
allowed-tools: Bash(curl:*), Bash(git:*), AskUserQuestion, TodoWrite
---

# GitLab Draft MR Management

You are helping a developer manage draft (WIP) merge requests. Follow a systematic approach: verify state, explain implications, apply changes, validate results.

## Core Principles

- **Verify current state first**: Check if MR is already draft/ready
- **Explain implications**: What happens when marking as draft/ready
- **Pre-flight checks**: Verify MR is ready before marking ready
- **Confirm before changes**: Always ask before modifying MR state

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `!id` - Mark MR as draft (or show status if already draft)
- `ready !id` - Mark MR as ready for review
- `list` - List all draft MRs with context
- (empty) - Analyze current branch MR status

---

## Workflow: Mark as Draft

**Phase 1: Verify Current State**

1. **Check environment**:
   ```bash
   echo "Project: $GITLAB_PROJECT_ID"
   ```

2. **Get MR details**:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
     jq '{
       iid, title, draft,
       state, author: .author.username,
       reviewers: [.reviewers[].username],
       pipeline: .head_pipeline.status
     }'
   ```

3. **Present current state**:
   ```
   MR !45: Fix login bug on Safari

   Current Status: ✅ Ready for review
   Author: @jane
   Reviewers: @bob, @alice
   Pipeline: passed

   This MR has:
   - 2 reviewers assigned
   - 3 comments (1 unresolved)
   - Pipeline passed
   ```

**Phase 2: Explain Implications**

```
Marking !45 as Draft will:

⚠️  Effects:
- Add "Draft:" prefix to title
- Prevent merging (even with approvals)
- Signal to reviewers: "not ready yet"
- Keep existing reviewers assigned

✅ Preserved:
- All comments and discussions
- Pipeline results
- Assignees and labels

Reviewers @bob and @alice will be notified.

Proceed with marking as draft?
```

**Phase 3: Apply Change (After User Confirmation)**

```bash
# Get current title and add Draft: prefix
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"title": "Draft: Fix login bug on Safari"}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]"
```

**Phase 4: Validate and Report**

1. **Verify change applied**:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
     jq '{title, draft}'
   ```

2. **Report result**:
   ```
   ✅ MR !45 marked as draft

   Title: Draft: Fix login bug on Safari
   Status: 🚧 Work in Progress

   Changes:
   - Cannot be merged until marked ready
   - Reviewers notified of status change

   When you're ready:
   /gl-draft ready !45
   ```

---

## Workflow: Mark as Ready

**Phase 1: Verify Current State**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
  jq '{
    title, draft, state,
    has_conflicts,
    merge_status,
    pipeline: .head_pipeline.status,
    reviewers: [.reviewers[].username],
    user_notes_count
  }'
```

**Phase 2: Pre-Flight Checks**

Before marking ready, verify:

```
MR !45: Draft: Fix login bug on Safari

Pre-flight Checks:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Pipeline: passed
✅ No conflicts with main
⚠️  Reviewers: None assigned
⚠️  Unresolved discussions: 1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Recommendations before marking ready:
1. Assign reviewers for faster review
2. Resolve discussion from @bob

Proceed anyway, or fix issues first?
1. Mark as ready now
2. Assign reviewers first
3. View unresolved discussions
4. Cancel
```

**Phase 3: Apply Change (After User Decision)**

If user chooses to proceed:
```bash
# Remove "Draft: " prefix from title
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"title": "Fix login bug on Safari"}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]"
```

**Phase 4: Validate and Report**

```
✅ MR !45 is now ready for review!

Title: Fix login bug on Safari
Status: 👀 Ready for review

Pre-merge checklist:
- [ ] Assign reviewers: /gl-mr review !45
- [ ] Get approvals
- [ ] Resolve 1 discussion
- [ ] Merge when ready

💡 Tip: Enable auto-merge to merge when pipeline passes:
   /gl-auto-merge !45
```

---

## Workflow: List All Drafts

**Phase 1: Gather Draft MRs**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?state=opened&wip=yes" | \
  jq '.[] | {
    iid, title,
    author: .author.username,
    source_branch,
    created_at,
    pipeline: .head_pipeline.status,
    updated_at
  }'
```

**Phase 2: Analyze and Categorize**

Group by status:
- Ready to be marked ready (pipeline passed, no conflicts)
- Needs work (pipeline failed, has conflicts)
- Stale (no activity > 7 days)

**Phase 3: Present with Context**

```
🚧 Draft Merge Requests (4)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ READY TO MARK READY (2)
   Pipeline passed, no conflicts

!48  Draft: Add OAuth support          @jane    3d ago
     └─ feature/oauth → main
     └─ Pipeline: ✅ passed
     └─ 0 unresolved discussions

!46  Draft: Refactor auth module       @bob     5d ago
     └─ refactor/auth → main
     └─ Pipeline: ✅ passed
     └─ 2 unresolved discussions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  NEEDS WORK (1)
   Has issues to resolve

!45  Draft: Fix login bug              @jane    1w ago
     └─ fix/login → main
     └─ Pipeline: ❌ failed
     └─ Reason: test:unit failed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💤 STALE (1)
   No activity > 7 days

!40  Draft: Update dependencies        @alice   2w ago
     └─ chore/deps → main
     └─ Consider: close or update

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
1. Mark !48 as ready (recommended)
2. Mark all ready drafts as ready
3. View failed pipeline for !45
4. Close stale !40

What would you like to do?
```

---

## Workflow: Current Branch Status

When no arguments, check current branch:

**Phase 1: Detect Current Branch MR**

```bash
# Get current branch
BRANCH=$(git branch --show-current)

# Find MR for this branch
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?source_branch=$BRANCH&state=opened"
```

**Phase 2: Present Status**

```
📍 Current Branch: feature/login

MR Status: !45 (Draft)

Title: Draft: Fix login bug on Safari
Status: 🚧 Work in Progress
Pipeline: ✅ passed
Conflicts: None

This MR is currently a draft.
Pipeline passed - ready to mark as ready?

1. Mark as ready
2. Keep as draft
3. View MR details
```

---

## Smart Features

1. **Auto-detect WIP patterns**: Recognize "WIP:", "Draft:", "[WIP]", "[DRAFT]"
2. **Pipeline awareness**: Warn if marking ready with failed pipeline
3. **Reviewer check**: Suggest adding reviewers when marking ready
4. **Stale detection**: Highlight drafts with no recent activity
5. **Batch operations**: Mark multiple drafts ready at once

---

## Error Handling

- **Already draft**: "!45 is already a draft. No changes needed."
- **Already ready**: "!45 is already ready for review. No changes needed."
- **Not found**: "MR !45 not found. Check the ID and try again."
- **No permission**: "Cannot modify !45. You may not have access."
