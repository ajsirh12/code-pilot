---
description: Compare branches - see commits, diffs, and conflict potential
argument-hint: "main...feature/login | from..to"
allowed-tools: Bash(curl:*), Bash(git:*), AskUserQuestion, TodoWrite
---

# GitLab Branch Compare

You are helping a developer compare branches to understand differences before merging.

## Core Principles

- **Show the delta**: What changed between branches
- **Predict conflicts**: Warn about potential merge issues
- **Actionable insights**: Suggest next steps based on comparison

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported formats**:
- `main...feature/login` - Compare feature against main
- `from..to` - Compare two branches
- (empty) - Compare current branch against default branch

---

## Workflow: Compare Branches

**Phase 1: Get Branch Info**

```bash
# Get current branch
git branch --show-current

# Get default branch
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
```

**Phase 2: Get Compare Data**

```bash
# Compare branches via API
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/compare?from=[base]&to=[head]" | \
  jq '{
    commits: [.commits[] | {short_id, title, author_name}],
    diffs: [.diffs[] | {old_path, new_path, new_file, deleted_file}],
    compare_timeout: .compare_timeout,
    compare_same_ref: .compare_same_ref
  }'
```

**Phase 3: Check for Conflicts**

```bash
# Try merge locally (dry run)
git fetch origin
git merge-tree $(git merge-base origin/[base] origin/[head]) origin/[base] origin/[head]
```

**Phase 4: Present Comparison**

```
🔀 Branch Comparison

main ← feature/login

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 SUMMARY

Commits ahead: 5
Commits behind: 2 (main has new commits)
Files changed: 12
Lines: +234 / -56

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 COMMITS (5)

abc1234  feat: add login form          @jane   2h ago
def5678  feat: add validation          @jane   1d ago
ghi9012  fix: button styling           @jane   1d ago
jkl3456  refactor: auth service        @jane   2d ago
mno7890  chore: add dependencies       @jane   3d ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 FILES CHANGED (12)

Modified:
  src/auth/login.js           +45 -12
  src/auth/validation.js      +89 -0 (new)
  src/components/Login.vue    +34 -8
  src/styles/auth.css         +23 -5

Added:
  src/auth/oauth.js           +67 lines
  tests/login.test.js         +120 lines

Deleted:
  src/old-login.js            -45 lines

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  POTENTIAL CONFLICTS

main has 2 commits not in feature/login:
  xyz1234  fix: auth bug              @bob    1d ago
  uvw5678  update: dependencies       @bob    2d ago

Files modified in both branches:
  ⚠️  src/auth/login.js (likely conflict)
  ✅ src/styles/auth.css (no overlap)

Recommendation: Merge main into feature/login first

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
1. Create MR from feature/login to main
2. Merge main into feature/login (rebase)
3. View specific file diff
4. View commit details

What would you like to do?
```

---

## Workflow: Detailed File Diff

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/compare?from=[base]&to=[head]" | \
  jq '.diffs[] | select(.new_path == "[filename]") | .diff'
```

Present as:
```
📄 Diff: src/auth/login.js

@@ -12,7 +12,15 @@ function handleLogin() {
   const username = getUsername();
   const password = getPassword();
-  return authenticate(username, password);
+
+  // Validate input first
+  if (!validateInput(username, password)) {
+    showError("Invalid credentials");
+    return false;
+  }
+
+  return authenticate(username, password);
 }
```

---

## Workflow: Behind/Ahead Count

```bash
# Commits behind (in base but not in head)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/compare?from=[head]&to=[base]" | \
  jq '.commits | length'

# Commits ahead (in head but not in base)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/compare?from=[base]&to=[head]" | \
  jq '.commits | length'
```

---

## Smart Features

1. **Conflict prediction**: Analyze both diffs for overlapping changes
2. **Merge advice**: Suggest rebase vs merge based on history
3. **Size warning**: Warn if diff is very large (>1000 lines)
4. **Stale detection**: Warn if branch is far behind

---

## Error Handling

- **Branch not found**: List available branches
- **Same branch**: Inform no differences
- **Large diff**: Offer to show summary only
- **Timeout**: Diff too large, suggest smaller comparison
