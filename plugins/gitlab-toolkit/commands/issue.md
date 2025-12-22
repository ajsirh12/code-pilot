---
description: Create and manage GitLab issues with intelligent workflow
argument-hint: "create | assign #id @user | link #id | confidential #id | comments #id"
allowed-tools: Bash(curl:*), Bash(git:*), AskUserQuestion, TodoWrite
---

# GitLab Issue Management

You are helping a developer manage GitLab issues. Follow a systematic approach based on the requested action.

## Core Principles

- **Verify environment first**: Check GITLAB_URL, GITLAB_TOKEN, GITLAB_PROJECT_ID
- **Understand context**: Get current branch, recent commits for context
- **Confirm before creating**: Show user what will be created
- **Report results clearly**: Show issue URL and details after action

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `create "title"` - Create a new issue
- `close #id` - Close an issue
- `estimate #id Xh` - Set time estimate
- `spend #id Xh` - Log time spent
- `assign #id @user` - Assign issue to user
- `link #id` - Manage linked issues (related, blocking, blocked by)
- `confidential #id` - Toggle confidentiality
- `comments #id` - View and add comments
- `list` - List open issues
- (empty) - Ask user what they want to do

---

## Workflow: Create Issue (Interactive)

**Phase 1: Fetch Available Options**

Fetch labels, milestones, and members in parallel for dynamic selection:

```bash
# Labels
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels?per_page=100" | \
  jq '[.[] | {name, color, description}]'

# Milestones (active only)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/milestones?state=active" | \
  jq '[.[] | {id, title, due_date}]'

# Members (for assignee)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/all?per_page=100" | \
  jq '[.[] | {id, username, name}]'
```

**Phase 2: Interactive Title & Description**

```
📝 이슈 생성

제목을 입력하세요:
> [user types title]

설명을 입력하세요 (선택사항, 엔터로 건너뛰기):
> [user types description or skips]
```

**Phase 3: Interactive Label Selection**

Display labels as numbered list:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏷️ 라벨 선택 (다중 선택 가능)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Label              Description
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   🔴 bug             버그 수정
 2   🟢 feature         새 기능
 3   🔵 enhancement     기능 개선
 4   📝 docs            문서화
 5   🧹 chore           유지보수
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Priority]
 6   🔴 priority::critical
 7   🟠 priority::high
 8   🟡 priority::medium
 9   🟢 priority::low
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

번호 선택 (예: 1,7):
```

**Phase 4: Interactive Milestone Selection**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 마일스톤 선택 (단일)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Milestone         Due Date
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 0   (없음)
 1   Phase 1           2025-01-31
 2   Phase 2           2025-02-28
 3   v1.0.0            2025-03-15
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

번호 선택:
```

**Phase 5: Interactive Assignee Selection**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 담당자 선택 (선택사항)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 0   (없음)
 1   @john.doe         John Doe
 2   @jane.smith       Jane Smith
 3   @bob.kim          Bob Kim
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

번호 선택 (다중: 1,2):
```

**Phase 6: Confirm & Create**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 이슈 미리보기
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
제목:      로그인 버그 수정
설명:      Safari에서 로그인 실패
라벨:      bug, priority::high
마일스톤:  Phase 1
담당자:    @jane.smith
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

생성하시겠습니까? (Y/n)
```

**Phase 7: Create & Report**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "[title]",
    "description": "[description]",
    "labels": "bug,priority::high",
    "milestone_id": [milestone_id],
    "assignee_ids": [user_ids]
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues"
```

Result:
```
✅ 이슈가 생성되었습니다!

#123: 로그인 버그 수정
URL: https://gitlab.tepseg.com/group/project/-/issues/123

라벨:      bug, priority::high
마일스톤:  Phase 1
담당자:    @jane.smith

📧 담당자에게 알림이 발송됩니다.
```

---

## Workflow: Time Tracking

**For estimate or spend commands:**

1. Parse issue IID and duration from arguments

2. Validate issue exists:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]" | jq '{title, state}'
   ```

3. Apply time tracking:
   ```bash
   # For estimate
   curl --request POST \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --data "duration=[duration]" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/time_estimate"

   # For spend
   curl --request POST \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --data "duration=[duration]" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/add_spent_time"
   ```

4. **Show updated time stats**:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/time_stats" | jq '.'
   ```

5. **Report result**:
   ```
   ✅ Time updated for #123

   Estimate: 8h
   Spent: 4h (50%)
   Remaining: 4h
   ```

---

## Workflow: Close Issue

1. Validate issue exists and is open

2. **Ask for confirmation**:
   ```
   Close issue #123: "[title]"?

   This issue has:
   - 3 comments
   - Linked to MR !45

   Proceed?
   ```

3. Close the issue:
   ```bash
   curl --request PUT \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --data "state_event=close" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]"
   ```

4. **Report result**:
   ```
   ✅ Issue #123 closed

   Title: [title]
   Time spent: 6h
   Closed by: @username
   ```

---

## Workflow: List Issues

1. Get open issues:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues?state=opened&per_page=20" | \
     jq '.[] | {iid, title, labels, assignee: .assignee.username}'
   ```

2. **Present as table**:
   ```
   Open Issues (20):

   #123  [bug] Login fails on Safari          @john    priority::high
   #124  [feature] Add dark mode              @jane    priority::medium
   #125  [docs] Update API documentation      -        priority::low
   ```

3. **Ask what user wants to do next**

---

## Error Handling

- **Issue not found**: Show helpful message with list of recent issues
- **Already closed**: Inform user, ask if they want to reopen
- **Permission denied**: Check user's project role

---

## Context Integration

When creating issues, offer to:
- Link to current branch
- Reference recent commits
- Connect to related MRs

---

## Workflow: Assign Issue (Interactive)

**Phase 1: Fetch Data in Parallel**

```bash
# Get issue details and project members simultaneously
# Issue details
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]" | \
  jq '{title, assignees: [.assignees[] | {id, username}]}'

# Project members (cache for session)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/all?per_page=100" | \
  jq '[.[] | {id, username, name, access_level}]'
```

**Phase 2: Display Numbered Member List**

Present members as a numbered list for easy selection:

```
Issue #123: Login fails on Safari

Current assignees: @john

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 프로젝트 멤버 목록
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Username        Name              Role
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   @john.doe       John Doe          Maintainer ✓ (현재)
 2   @jane.smith     Jane Smith        Developer
 3   @bob.kim        Bob Kim           Developer
 4   @alice.lee      Alice Lee         Reporter
 5   @charlie.park   Charlie Park      Developer
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

선택 방법:
• 단일: 2
• 다중: 1,3,5
• 범위: 2-4
• 전체: all
• 해제: none
```

**Phase 3: Get User Selection**

Use AskUserQuestion to confirm action type, then process number input:

```
Actions:
1. 추가 (기존 유지 + 추가)
2. 교체 (전체 교체)
3. 제거 (선택한 사람 제거)

번호를 입력하세요:
```

**Phase 4: Parse Selection & Update**

```bash
# Parse user input (e.g., "2,3" or "2-4" or "all")
# Convert to user IDs from the numbered list

# Update assignees
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"assignee_ids": [parsed_user_ids]}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]"
```

**Phase 5: Report Result**

```
✅ Assignees updated for #123

변경사항:
  + @jane.smith (추가)
  + @bob.kim (추가)
  - @john.doe (제거)

현재 담당자:
  • @jane.smith
  • @bob.kim

📧 이메일 알림이 발송됩니다.
```

**Selection Parser Logic:**

```
Input: "2,3"     → IDs: [jane_id, bob_id]
Input: "2-4"     → IDs: [jane_id, bob_id, alice_id]
Input: "1,3-5"   → IDs: [john_id, bob_id, alice_id, charlie_id]
Input: "all"     → All member IDs
Input: "none"    → Empty array (unassign all)
```

---

## Workflow: Linked Issues

**Phase 1: Get Current Links**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/links" | \
  jq '.[] | {
    iid,
    title,
    state,
    link_type
  }'
```

**Phase 2: Present Links**

```
Issue #123: Login fails on Safari

Linked Issues:

🔗 Related:
   #120  Authentication refactoring    closed

🚫 Blocked by:
   #115  Update auth library           open ⚠️

⛔ Blocking:
   #130  Safari mobile support         open

Actions:
1. Add related issue
2. Add "blocked by" link
3. Add "blocking" link
4. Remove link

What would you like to do?
```

**Phase 3: Create Link**

```bash
# Link types: relates_to, blocks, is_blocked_by
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"target_project_id": [project_id], "target_issue_iid": [iid], "link_type": "is_blocked_by"}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/links"
```

**Phase 4: Report Result**

```
✅ Link created

#123 is now blocked by #115

Linked issues for #123:
- Related: #120
- Blocked by: #115 ⚠️
- Blocking: #130

Note: #123 cannot be closed until #115 is resolved.
```

---

## Workflow: Remove Link

```bash
# Get link ID first
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/links" | \
  jq '.[] | {link_id: .issue_link_id, target_iid: .iid}'

# Remove link
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/links/[link_id]"
```

---

## Workflow: Confidentiality

**Phase 1: Check Current Status**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]" | \
  jq '{title, confidential}'
```

**Phase 2: Explain Implications**

```
Issue #123: Login fails on Safari

Current: 🔓 Public (visible to all project members)

Confidential issues:
- Only visible to project members with Reporter+ access
- Hidden from public issue lists
- Comments also hidden
- Useful for security vulnerabilities, HR issues

Actions:
1. Make confidential 🔒
2. Keep public 🔓

What would you like to do?
```

**Phase 3: Toggle Confidentiality**

```bash
# Make confidential
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "confidential=true" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]"

# Make public
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "confidential=false" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]"
```

**Phase 4: Report Result**

```
✅ Issue #123 is now confidential 🔒

Visibility: Reporter+ only
- @john (Maintainer) ✅
- @jane (Developer) ✅
- @guest (Guest) ❌

Warning: Existing subscribers who don't have access
will no longer see this issue.
```

---

## Workflow: Issue Comments

**Phase 1: Get Comments**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/notes?sort=asc" | \
  jq '.[] | {
    id,
    author: .author.username,
    body,
    created_at,
    system
  }'
```

**Phase 2: Present Comments**

```
Issue #123: Login fails on Safari

Comments (5):

1. @jane (2d ago):
   "I can reproduce this on Safari 17. Seems related to the new
   cookie handling."

2. 🤖 System (2d ago):
   "Added label: bug"

3. @john (1d ago):
   "Looking into this. The SameSite cookie attribute might be
   the issue."

4. @jane (1d ago):
   "@john Can you check if it affects Safari 16 too?"

5. @john (3h ago):
   "Fixed in commit abc1234. Safari 16 is not affected."

Actions:
1. Add comment
2. Reply to specific comment
3. Add emoji reaction

What would you like to do?
```

**Phase 3: Add Comment**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"body": "Testing the fix now. Will update soon."}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/notes"
```

**Phase 4: Add Emoji Reaction**

```bash
# Add reaction to a note
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "name=thumbsup" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]/notes/[note_id]/award_emoji"
```

**Phase 5: Report Result**

```
✅ Comment added to #123

Your comment:
"Testing the fix now. Will update soon."

@jane and @john will be notified.

Total comments: 6
```

---

## Workflow: Create Issue (Extended)

When creating issues, also ask about:

**Assignee:**
```
Who should work on this issue?
1. Assign to me (@john)
2. Assign to someone else
3. Leave unassigned
```

**Confidentiality:**
```
Should this issue be confidential?
1. No, keep public (default)
2. Yes, make confidential (security issues, etc.)
```

**Due Date:**
```
Set a due date?
1. No due date
2. This week
3. Next week
4. Custom date
```

**Weight (for planning):**
```
Estimate complexity (1-10)?
1. Small (1-2)
2. Medium (3-5)
3. Large (6-10)
4. Skip
```

---

## Workflow: Issue Details View

When viewing a single issue, show comprehensive info:

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/[iid]" | \
  jq '{
    iid, title, state, confidential,
    author: .author.username,
    assignees: [.assignees[].username],
    labels,
    milestone: .milestone.title,
    due_date, weight,
    time_estimate: .time_stats.human_time_estimate,
    time_spent: .time_stats.human_total_time_spent,
    upvotes, downvotes,
    merge_requests_count,
    user_notes_count,
    web_url
  }'
```

**Present as:**
```
#123: Login fails on Safari

Status: 🟢 Open
Type: 🐛 Bug
Priority: 🔴 Critical
Confidential: 🔓 No

Assignees: @john, @jane
Milestone: Phase 1

Time Tracking:
- Estimate: 8h
- Spent: 4h (50%)
- Remaining: 4h

Due: Dec 20, 2024 (in 2 days)
Weight: 5

Linked Items:
- Blocked by: #115 (open) ⚠️
- Related: #120 (closed)
- Blocking: #130 (open)

Activity:
- 5 comments
- 2 MRs linked
- 👍 3 upvotes

URL: https://gitlab.tepseg.com/.../issues/123

Actions:
1. Add comment
2. Update assignees
3. Add linked issue
4. View comments
```

---

## Error Handling

- **Issue not found**: Show helpful message with list of recent issues
- **Already closed**: Inform user, ask if they want to reopen
- **Permission denied**: Check user's project role
- **User not found**: Show list of valid project members
- **Cannot link to self**: Explain the issue
- **Circular dependency**: Warn about blocking loops
