---
description: Intelligent auto-merge - automatically merge when pipeline succeeds
argument-hint: "!id | cancel !id | list"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Auto-Merge

You are helping a developer set up automatic merging when pipeline succeeds. Follow a systematic approach: verify eligibility, explain what will happen, enable, and monitor.

## Core Principles

- **Verify eligibility first**: All merge requirements must be met
- **Explain clearly**: Show exactly what happens when pipeline passes
- **Confirm before enabling**: User must approve auto-merge
- **Easy cancellation**: Allow cancel anytime before merge

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `!id` - Enable auto-merge for MR
- `cancel !id` - Cancel auto-merge
- `list` - List MRs with auto-merge enabled
- (empty) - Check auto-merge status for current branch MR

---

## Workflow: Enable Auto-Merge

**Phase 1: Verify Environment & Get MR Status**

1. **Check environment**:
   ```bash
   echo "Project: $GITLAB_PROJECT_ID"
   ```

2. **Get comprehensive MR status**:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
     jq '{
       iid, title, state, draft,
       source_branch, target_branch,
       merge_status, has_conflicts,
       pipeline: .head_pipeline.status,
       merge_when_pipeline_succeeds,
       squash, should_remove_source_branch
     }'
   ```

3. **Get approval status**:
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

4. **Check discussions**:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/discussions" | \
     jq '[.[] | select(.notes[0].resolvable == true and .notes[0].resolved == false)] | length'
   ```

**Phase 2: Eligibility Check**

Present comprehensive eligibility status:

```
🔄 Auto-Merge Eligibility Check for !45

MR: Fix login bug on Safari
Branches: feature/login → main

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REQUIREMENTS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ MR State: Open (not draft)
✅ Conflicts: None
⏳ Pipeline: Running (will wait)
✅ Approvals: 2/2 required ✓
   └─ @bob, @alice approved
✅ Discussions: All resolved

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RESULT: ✅ Eligible for auto-merge

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

When pipeline succeeds (ETA ~5 min):
- MR will be automatically merged into main
- Branch feature/login will be deleted
- Issue #123 will be closed (Closes #123)
- Squash: Yes (3 commits → 1)

Enable auto-merge?
```

**If NOT Eligible**:

```
❌ Cannot Enable Auto-Merge for !45

MR: Fix login bug on Safari

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BLOCKING ISSUES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ Approvals: 1/2 required
   └─ Need 1 more approval
   └─ Approved by: @bob
   └─ Suggested: @alice, @jane

❌ Unresolved Discussions: 2
   └─ @bob: "Consider adding tests"
   └─ @alice: "Check error handling"

✅ Pipeline: passed
✅ Conflicts: None

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Fix these issues first:

1. Request approval: /gl-mr approve !45
2. Resolve discussions: /gl-mr comments !45

Then try auto-merge again.
```

**Phase 3: Enable Auto-Merge (After User Confirmation)**

```bash
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "merge_when_pipeline_succeeds": true,
    "should_remove_source_branch": true,
    "squash": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/merge"
```

**Phase 4: Validate and Report**

1. **Verify auto-merge enabled**:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
     jq '{merge_when_pipeline_succeeds, head_pipeline}'
   ```

2. **Report with monitoring info**:
   ```
   ✅ Auto-Merge Enabled for !45

   Status: ⏳ Waiting for pipeline

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   Pipeline Progress:
   ├─ build        ✅ passed (1m 23s)
   ├─ test:unit    ⏳ running...
   ├─ test:e2e     ⏸️ pending
   └─ deploy       ⏸️ pending

   ETA: ~5 minutes

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   When complete:
   - Merge into: main
   - Delete branch: feature/login
   - Close issue: #123
   - Squash commits: Yes

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   To cancel before merge:
   /gl-auto-merge cancel !45

   You'll be notified when merge completes.
   ```

---

## Workflow: Cancel Auto-Merge

**Phase 1: Verify Auto-Merge Status**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
  jq '{
    title,
    merge_when_pipeline_succeeds,
    pipeline: .head_pipeline.status
  }'
```

**Phase 2: Confirm Cancellation**

```
⏳ Auto-Merge Active for !45

MR: Fix login bug on Safari
Pipeline: Running (3/5 jobs complete)

Cancel auto-merge?
- MR will NOT be merged when pipeline passes
- You can merge manually or re-enable auto-merge later

Proceed with cancellation?
```

**Phase 3: Cancel (After User Confirmation)**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/cancel_merge_when_pipeline_succeeds"
```

**Phase 4: Report Result**

```
✅ Auto-Merge Cancelled for !45

Status: Manual merge required

The MR will NOT be merged automatically.
Pipeline is still running.

Next steps:
- Wait for pipeline and merge manually: /gl-mr merge !45
- Re-enable auto-merge: /gl-auto-merge !45
```

---

## Workflow: List Auto-Merge MRs

**Phase 1: Get All MRs with Auto-Merge**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?state=opened" | \
  jq '.[] | select(.merge_when_pipeline_succeeds == true)'
```

**Phase 2: Get Pipeline Details for Each**

For each MR, get pipeline progress.

**Phase 3: Present Status**

```
⏳ Auto-Merge Queue (3 MRs)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

!45  Fix login bug on Safari
     └─ Pipeline: ⏳ running (3/5 jobs)
     └─ ETA: ~5 minutes
     └─ Will close: #123

!42  Add OAuth support
     └─ Pipeline: ⏳ running (1/5 jobs)
     └─ ETA: ~12 minutes
     └─ Will close: #118, #119

!40  Update dependencies
     └─ Pipeline: ⏳ running (4/5 jobs)
     └─ ETA: ~2 minutes
     └─ No linked issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Expected merge order:
1. !40 (~2 min)
2. !45 (~5 min)
3. !42 (~12 min)

Actions:
1. Cancel auto-merge for !45
2. Cancel all auto-merges
3. View pipeline details
```

---

## Workflow: Current Branch Status

When no arguments:

```bash
# Get current branch
BRANCH=$(git branch --show-current)

# Find MR for this branch
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?source_branch=$BRANCH&state=opened"
```

Present:
```
📍 Current Branch: feature/login

MR !45: Fix login bug on Safari

Auto-Merge: ❌ Not enabled
Pipeline: ✅ passed
Approvals: ✅ 2/2

This MR is ready for auto-merge!
Enable auto-merge?
```

---

## Smart Features

1. **Pipeline ETA**: Estimate time based on recent pipeline durations
2. **Merge order**: Show expected merge sequence
3. **Linked issues**: Show what issues will be closed
4. **Notification**: Alert when merge completes
5. **Failure handling**: Auto-notify if pipeline fails

---

## Error Handling

- **Already enabled**: "Auto-merge already enabled for !45"
- **Already merged**: "!45 has already been merged"
- **Pipeline failed**: "Cannot enable - pipeline failed. Fix and retry."
- **Draft MR**: "Cannot enable - MR is a draft. Mark ready first."
- **Has conflicts**: "Cannot enable - merge conflicts exist. Resolve first."
