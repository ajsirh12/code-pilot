---
description: View your GitLab inbox - pending reviews, approvals, assigned issues and MRs
argument-hint: "reviews | approvals | assigned | todos | all"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Inbox - My Pending Items

You are helping a developer stay on top of their GitLab responsibilities. Show pending reviews, approvals, assigned items, and todos in a clear, actionable format.

## Core Principles

- **Show what needs attention**: Prioritize items requiring action
- **Group by urgency**: Overdue → Today → This week
- **Provide quick actions**: Allow immediate response from inbox
- **Filter smartly**: Support filtering by type, project, urgency

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `reviews` - MRs where you are a reviewer
- `approvals` - MRs awaiting your approval
- `assigned` - Issues/MRs assigned to you
- `todos` - GitLab todos (mentions, assignments)
- `all` or (empty) - Show complete inbox dashboard

---

## Workflow: Complete Inbox Dashboard

**Phase 1: Gather All Data**

```bash
# Get current user
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/user" | jq '{id, username}'

# MRs where I'm reviewer
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/merge_requests?reviewer_username=[username]&state=opened&scope=all"

# MRs awaiting my approval (check each MR's approval status)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/merge_requests?state=opened&scope=all&per_page=50"

# Issues assigned to me
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/issues?assignee_username=[username]&state=opened&scope=all"

# MRs assigned to me
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/merge_requests?assignee_username=[username]&state=opened&scope=all"

# My todos
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/todos?state=pending"
```

**Phase 2: Present Dashboard**

```
📬 GitLab Inbox for @john

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 REVIEWS NEEDED (3)
   MRs where you are a reviewer

   !45  Fix login bug           project-a    @jane    2h ago   ⚡ Pipeline passed
   !42  Add OAuth support       project-a    @bob     1d ago   ⏳ Pipeline running
   !38  Update dependencies     project-b    @alice   3d ago   ❌ Pipeline failed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ APPROVALS PENDING (2)
   MRs awaiting your approval

   !44  Dark mode feature       project-a    @jane    4h ago   Ready to approve
   !41  API refactoring         project-b    @bob     2d ago   1/2 approvals

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📌 ASSIGNED TO YOU (5)

   Issues (3):
   #123  Login fails on Safari          priority::high      Due: Today ⚠️
   #118  Add dark mode toggle           priority::medium    Due: This week
   #115  Update documentation           priority::low       No due date

   MRs (2):
   !40  Your MR: Fix auth flow          ⏳ Waiting for review
   !39  Your MR: Add tests              ✅ Approved, ready to merge

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 TODOS (4)
   Mentions and notifications

   @jane mentioned you in !45 comment          2h ago
   @bob requested your review on !42           1d ago
   You were assigned to #123                   2d ago
   Pipeline failed on !40                      3d ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quick Actions:
1. Review !45 (oldest pending review)
2. Approve !44 (ready for approval)
3. Work on #123 (due today)
4. Mark all todos as done

What would you like to do?
```

---

## Workflow: Pending Reviews

**Phase 1: Get MRs Where You're Reviewer**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/merge_requests?reviewer_username=[username]&state=opened&scope=all" | \
  jq '.[] | {
    iid,
    title,
    project: .references.full,
    author: .author.username,
    created_at,
    pipeline: .head_pipeline.status,
    web_url
  }'
```

**Phase 2: Present Reviews**

```
🔍 Pending Reviews (3)

!45  Fix login bug on Safari
     project-a • @jane • 2 hours ago
     Pipeline: ✅ passed
     Changes: +45 -12 (3 files)
     → Review now

!42  Add OAuth support
     project-a • @bob • 1 day ago
     Pipeline: ⏳ running
     Changes: +234 -56 (12 files)
     → Wait for pipeline

!38  Update dependencies
     project-b • @alice • 3 days ago
     Pipeline: ❌ failed
     Changes: +89 -23 (5 files)
     → Check pipeline first

Actions:
1. Start review on !45
2. View all changes
3. Filter by project

Which MR to review?
```

---

## Workflow: Pending Approvals

**Phase 1: Find MRs Needing Your Approval**

```bash
# Get all open MRs, then check approval status for each
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?state=opened" | \
  jq '.[] | {iid, title, author: .author.username}'

# For each MR, check if user hasn't approved yet
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/approvals" | \
  jq '{
    approved_by: [.approved_by[].user.username],
    approvals_left,
    user_can_approve: .user_can_approve
  }'
```

**Phase 2: Present Approvals Needed**

```
✅ Approvals Pending (2)

!44  Dark mode feature
     @jane • 4 hours ago
     Status: 0/2 approvals needed
     Pipeline: ✅ passed
     → Ready to approve

!41  API refactoring
     @bob • 2 days ago
     Status: 1/2 approvals (needs yours)
     Pipeline: ✅ passed
     Approved by: @alice
     → Ready to approve

Quick approve:
1. Approve !44
2. Approve !41
3. Approve all

Which MR to approve?
```

---

## Workflow: Assigned Items

**Phase 1: Get Assigned Issues and MRs**

```bash
# Assigned issues
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/issues?assignee_username=[username]&state=opened&scope=all" | \
  jq '.[] | {
    iid,
    title,
    project: .references.full,
    labels,
    due_date,
    weight,
    time_stats: {estimate: .time_stats.human_time_estimate, spent: .time_stats.human_total_time_spent}
  }'

# Assigned MRs (your own MRs)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/merge_requests?assignee_username=[username]&state=opened&scope=all" | \
  jq '.[] | {
    iid,
    title,
    project: .references.full,
    merge_status,
    pipeline: .head_pipeline.status,
    approvals: .approvals_before_merge
  }'
```

**Phase 2: Present Assigned Items**

```
📌 Assigned to You

ISSUES (3):
┌──────┬─────────────────────────┬─────────────────┬────────────┐
│ ID   │ Title                   │ Priority        │ Due Date   │
├──────┼─────────────────────────┼─────────────────┼────────────┤
│ #123 │ Login fails on Safari   │ 🔴 critical     │ Today ⚠️   │
│ #118 │ Add dark mode toggle    │ 🟡 medium       │ Dec 25     │
│ #115 │ Update documentation    │ 🟢 low          │ -          │
└──────┴─────────────────────────┴─────────────────┴────────────┘

YOUR MRs (2):
┌──────┬─────────────────────────┬─────────────────┬────────────┐
│ ID   │ Title                   │ Pipeline        │ Status     │
├──────┼─────────────────────────┼─────────────────┼────────────┤
│ !40  │ Fix auth flow           │ ✅ passed       │ ⏳ Review  │
│ !39  │ Add tests               │ ✅ passed       │ ✅ Merge!  │
└──────┴─────────────────────────┴─────────────────┴────────────┘

Actions:
1. Work on #123 (due today!)
2. Merge !39 (ready)
3. Check !40 review status

What would you like to do?
```

---

## Workflow: GitLab Todos

**Phase 1: Get Pending Todos**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/todos?state=pending" | \
  jq '.[] | {
    id,
    action_name,
    target_type,
    target: .target.iid,
    title: .body,
    author: .author.username,
    created_at,
    project: .project.name
  }'
```

**Phase 2: Present Todos**

```
🔔 GitLab Todos (4 pending)

1. 💬 @jane mentioned you
   !45: "Can you check the Safari fix?"
   2 hours ago • project-a

2. 👀 Review requested
   !42: Add OAuth support
   1 day ago • project-a

3. 📌 Assigned to you
   #123: Login fails on Safari
   2 days ago • project-a

4. ❌ Pipeline failed
   !40: Fix auth flow
   3 days ago • project-a

Actions:
1. View and respond to mention
2. Mark todo as done
3. Mark all as done

Which todo to handle?
```

**Phase 3: Mark Todo as Done**

```bash
# Mark single todo as done
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/todos/[todo_id]/mark_as_done"

# Mark all todos as done
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/todos/mark_as_done"
```

---

## Smart Features

1. **Urgency sorting**: Overdue items first, then by due date
2. **Cross-project view**: See items from all projects at once
3. **Quick actions**: Jump directly to review, approve, or work on items
4. **Pipeline status**: Know if MR is ready for review/merge
5. **Time tracking**: Show spent/estimate for assigned issues

---

## Error Handling

- **No pending items**: Celebrate! "🎉 Inbox zero! Nothing needs your attention."
- **API rate limit**: Wait and retry, show cached data if available
- **Permission denied**: Show items you have access to, skip others
