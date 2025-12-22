---
description: Cherry-pick commits to other branches
argument-hint: "SHA --to branch | SHA --to !id"
allowed-tools: Bash(curl:*), Bash(git:*), AskUserQuestion, TodoWrite
---

# GitLab Cherry-Pick

You are helping a developer cherry-pick specific commits to other branches.

## Core Principles

- **Verify commit**: Show exactly what will be cherry-picked
- **Target safely**: Create MR for protected branches
- **Track origin**: Note source commit in new commit message

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `SHA --to branch` - Cherry-pick to specific branch
- `SHA --to !id` - Cherry-pick to MR's source branch
- `SHA` - Cherry-pick to main branch
- (empty) - Show recent commits for cherry-picking

---

## Workflow: Cherry-Pick to Branch

**Phase 1: Get Commit Details**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/commits/[sha]" | \
  jq '{
    short_id,
    title,
    message,
    author_name,
    created_at,
    stats: {additions, deletions}
  }'
```

**Phase 2: Verify Target Branch**

```bash
# Check if branch exists
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/branches/[branch]" | \
  jq '{name, protected}'
```

**Phase 3: Confirm Cherry-Pick**

```
🍒 Cherry-Pick Commit

Commit: abc1234
Title: fix: critical login bug
Author: @jane
From: feature/login

Changes:
- src/auth/login.js (+12 -3)
- tests/login.test.js (+8 -2)

Target branch: release/1.0 (protected)

This will:
1. Create new branch: cherry-pick-abc1234
2. Apply the commit
3. Open MR to release/1.0

Proceed?
```

**Phase 4: Execute Cherry-Pick**

```bash
# Cherry-pick via API
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"branch": "[target_branch]"}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/commits/[sha]/cherry_pick"
```

**Phase 5: Report Result**

```
✅ Cherry-pick successful!

Original: abc1234 (feature/login)
New:      xyz7890 (release/1.0)

Commit message:
"fix: critical login bug
(cherry picked from commit abc1234)"

The fix is now on release/1.0.
```

---

## Workflow: Cherry-Pick to Protected Branch

For protected branches, create MR:

```
🍒 Cherry-Pick to Protected Branch

Target: main (protected)

Cannot cherry-pick directly. Creating MR instead:

1. Creating branch: cherry-pick-abc1234-to-main
2. Applying commit...
3. Creating MR...

✅ MR Created!

!49: Cherry-pick "fix: critical login bug"
URL: https://gitlab.tepseg.com/.../merge_requests/49

Review and merge to apply the fix to main.
```

---

## Workflow: Cherry-Pick Multiple Commits

```
🍒 Cherry-Pick Multiple Commits

Commits to cherry-pick (in order):
1. abc1234 "fix: login validation"
2. def5678 "fix: error handling"
3. ghi9012 "test: add login tests"

Target: release/1.0

Apply all 3 commits in order?
```

Execute:
```bash
# Apply each commit in sequence
for sha in abc1234 def5678 ghi9012; do
  curl --request POST \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{\"branch\": \"release/1.0\"}" \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/commits/$sha/cherry_pick"
done
```

---

## Workflow: Show Commits for Cherry-Pick

```
🍒 Recent Commits Available for Cherry-Pick

FROM: feature/login
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
abc1234  fix: login validation      @jane   2h ago
def5678  fix: error handling        @jane   3h ago
ghi9012  feat: add OAuth            @bob    1d ago

FROM: feature/auth
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
jkl3456  fix: token refresh         @alice  4h ago
mno7890  security: fix XSS          @alice  5h ago  ⚠️ important

Which commit to cherry-pick?
```

---

## Common Use Cases

1. **Hotfix to release branch**
   ```
   /gl-cherry-pick abc1234 --to release/1.0
   ```

2. **Backport to older version**
   ```
   /gl-cherry-pick abc1234 --to release/0.9
   ```

3. **Apply fix to multiple branches**
   ```
   /gl-cherry-pick abc1234 --to release/1.0,release/0.9
   ```

---

## Smart Features

1. **Conflict detection**: Warn if cherry-pick may conflict
2. **Dependency check**: Note if commit depends on others
3. **Batch support**: Cherry-pick range of commits
4. **Backport helper**: Suggest relevant branches

---

## Error Handling

- **Commit not found**: Show recent commits to choose from
- **Branch not found**: List available branches
- **Conflicts**: Cannot auto-pick, suggest manual resolution
- **Already applied**: Commit already exists on target branch
- **Empty cherry-pick**: Changes already exist on target
