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

## Workflow: Create MR (Interactive)

**Phase 1: Pre-flight Checks**

```bash
# Check uncommitted changes
git status --short

# Check if pushed
git log --oneline @{u}..HEAD 2>/dev/null

# Check existing MR
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?source_branch=$(git branch --show-current)&state=opened"
```

Handle issues:
- Uncommitted changes → "커밋하시겠습니까?"
- Not pushed → "푸시하시겠습니까?"
- MR exists → Show link and offer to open

**Phase 2: Fetch Options in Parallel**

```bash
# Open issues (for linking)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues?state=opened&per_page=20" | \
  jq '[.[] | {iid, title, labels}]'

# Labels
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels?per_page=100" | \
  jq '[.[] | {name, color}]'

# Members (for reviewers)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/all?per_page=100" | \
  jq '[.[] | {id, username, name}]'

# Commits for title suggestion
git log --oneline $(git merge-base HEAD origin/main)..HEAD
```

**Phase 3: Interactive Title & Description**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔀 MR 생성
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Branch: feature/login-fix → main
Commits: 3

제목을 입력하세요:
(추천: feat: fix login bug on Safari)
>
```

**Phase 4: Interactive Issue Linking**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 이슈 연결 (선택사항)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Issue                              Labels
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 0   (연결 안함)
 1   #123 Login fails on Safari         bug, priority::high
 2   #120 Improve auth performance       enhancement
 3   #118 Update documentation          docs
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

연결할 이슈 번호 (Closes #):
```

**Phase 5: Interactive Label Selection**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏷️ 라벨 선택 (다중 가능)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   🔴 bug
 2   🟢 feature
 3   🔵 enhancement
 4   📝 docs
 5   🟠 priority::high
 6   🟡 priority::medium
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

번호 선택 (예: 1,5):
```

**Phase 6: Interactive Reviewer Selection**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👥 리뷰어 선택 (다중 가능)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 0   (나중에 지정)
 1   @jane.smith     Jane Smith
 2   @bob.kim        Bob Kim
 3   @alice.lee      Alice Lee
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

번호 선택 (예: 1,2):
```

**Phase 7: Confirm & Create**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 MR 미리보기
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
제목:      feat: fix login bug on Safari
브랜치:    feature/login-fix → main
커밋:      3개

설명:
  ## Summary
  - Fixed Safari-specific login issue

  Closes #123

라벨:      bug, priority::high
리뷰어:    @jane.smith, @bob.kim

옵션:
  ✓ 머지 후 브랜치 삭제
  ✓ 커밋 스쿼시
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

생성하시겠습니까? (Y/n)
```

**Phase 8: Create & Report**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "source_branch": "[current-branch]",
    "target_branch": "main",
    "title": "[title]",
    "description": "## Summary\n\n[description]\n\nCloses #123",
    "labels": "bug,priority::high",
    "reviewer_ids": [reviewer_ids],
    "remove_source_branch": true,
    "squash": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests"
```

Result:
```
✅ MR이 생성되었습니다!

!45: feat: fix login bug on Safari
URL: https://gitlab.tepseg.com/group/project/-/merge_requests/45

상태:      Open
파이프라인: Running ⏳
연결이슈:  Closes #123
라벨:      bug, priority::high
리뷰어:    @jane.smith, @bob.kim

다음 단계:
  1. 파이프라인 완료 대기
  2. 리뷰어 승인 대기
  3. 머지

📧 리뷰어에게 알림이 발송됩니다.
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

## Workflow: Manage Reviewers (Interactive)

**Phase 1: Fetch Data in Parallel**

```bash
# Get MR details with current reviewers
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
  jq '{
    title,
    author: .author.username,
    reviewers: [.reviewers[] | {id, username}]
  }'

# Get project members (exclude author)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/all?per_page=100" | \
  jq '[.[] | {id, username, name, access_level}]'
```

**Phase 2: Display Interactive Member List**

```
MR !45: Fix login bug on Safari
Author: @john.doe

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👥 리뷰어 선택
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Username        Name              Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   @jane.smith     Jane Smith        ✓ 리뷰어
 2   @bob.kim        Bob Kim           ✓ 리뷰어
 3   @alice.lee      Alice Lee
 4   @charlie.park   Charlie Park
 5   @david.choi     David Choi
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

선택 방법:
• 토글: 번호 입력 시 추가/제거 전환
• 다중: 3,4 (추가)
• 범위: 3-5 (추가)
• 전체 해제: none
```

**Phase 3: Process Selection**

Use AskUserQuestion for action confirmation:

```
현재 리뷰어: @jane.smith, @bob.kim

Actions:
1. 추가할 리뷰어 선택
2. 제거할 리뷰어 선택
3. 전체 교체

선택:
```

Then process number input:
```
리뷰어로 추가할 번호를 입력하세요 (예: 3,4):
> 3,4

선택됨: @alice.lee, @charlie.park
```

**Phase 4: Update Reviewers**

```bash
# Combine existing + new reviewer IDs
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"reviewer_ids": [jane_id, bob_id, alice_id, charlie_id]}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]"
```

**Phase 5: Report Result**

```
✅ 리뷰어가 업데이트되었습니다!

MR !45: Fix login bug on Safari

변경사항:
  + @alice.lee (추가)
  + @charlie.park (추가)

현재 리뷰어:
  • @jane.smith
  • @bob.kim
  • @alice.lee
  • @charlie.park

📧 새 리뷰어에게 알림이 발송됩니다.
```

**Selection Parser Logic:**

```
Input: "3,4"     → Add IDs: [alice_id, charlie_id]
Input: "3-5"     → Add IDs: [alice_id, charlie_id, david_id]
Input: "1"       → Toggle: Remove jane (already reviewer)
Input: "none"    → Remove all reviewers
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
