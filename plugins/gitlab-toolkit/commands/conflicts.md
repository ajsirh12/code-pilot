---
description: Detect and help resolve merge conflicts
argument-hint: "!id | check | resolve !id"
allowed-tools: Bash(curl:*), Bash(git:*), Read, AskUserQuestion, TodoWrite
---

# GitLab Conflict Resolution

You are helping a developer detect and resolve merge conflicts in MRs.

## Core Principles

- **Detect early**: Check for conflicts before they block merges
- **Explain clearly**: Show exactly what conflicts exist
- **Guide resolution**: Provide step-by-step fix instructions

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `!id` - Check MR for conflicts
- `check` - Check current branch for conflicts with target
- `resolve !id` - Interactive conflict resolution guide
- (empty) - Check current branch MR for conflicts

---

## Workflow: Check MR Conflicts

**Phase 1: Get MR Status**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
  jq '{
    title,
    has_conflicts,
    merge_status,
    source_branch,
    target_branch,
    diff_refs: .diff_refs
  }'
```

**Phase 2: If Has Conflicts, Get Details**

```bash
# Get conflicting files from changes
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/changes" | \
  jq '.changes[] | select(.diff | contains("<<<<<<<")) | {old_path, new_path}'
```

**Phase 3: Present Conflict Status**

```
⚠️  Merge Conflicts Detected in !45

MR: Fix login bug on Safari
Branches: feature/login → main

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Conflicting Files (2):

1. src/auth/login.js
   Both branches modified lines 45-52
   - main: Added error handling
   - feature/login: Changed validation logic

2. package.json
   Both branches modified dependencies
   - main: Updated lodash to 4.17.21
   - feature/login: Added new-package

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Resolution Options:

1. Resolve locally (recommended)
   git fetch origin
   git checkout feature/login
   git merge origin/main
   # Fix conflicts, then push

2. Resolve via GitLab Web IDE
   URL: https://gitlab.tepseg.com/.../merge_requests/45/conflicts

3. Start interactive resolution guide

Which option would you like?
```

---

## Workflow: Interactive Resolution

**Phase 1: Prepare Local Environment**

```
🔧 Conflict Resolution Guide for !45

Step 1: Fetch latest changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run these commands:

git fetch origin
git checkout feature/login
git merge origin/main

This will show conflict markers.
Ready to continue?
```

**Phase 2: Show Each Conflict**

```
Conflict 1 of 2: src/auth/login.js

<<<<<<< HEAD (your changes - feature/login)
function validateLogin(username, password) {
  if (!username || !password) {
    return { valid: false, error: 'Missing credentials' };
  }
  return { valid: true };
}
=======
function validateLogin(username, password) {
  try {
    if (!username) throw new Error('Username required');
    if (!password) throw new Error('Password required');
    return { valid: true };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}
>>>>>>> origin/main (their changes)

Options:
1. Keep your version (feature/login)
2. Keep their version (main)
3. Keep both (merge manually)
4. Show me how to merge both

Which option?
```

**Phase 3: Suggest Merged Version**

```
Suggested merged version:

function validateLogin(username, password) {
  try {
    if (!username || !password) {
      return { valid: false, error: 'Missing credentials' };
    }
    return { valid: true };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

This combines:
- Your validation logic (concise check)
- Their error handling pattern (try/catch)

Apply this resolution?
```

**Phase 4: Complete Resolution**

```
✅ All conflicts resolved!

Files resolved:
- src/auth/login.js ✅
- package.json ✅

Next steps:
1. Review changes: git diff
2. Test locally: npm test
3. Commit: git add . && git commit -m "Resolve merge conflicts"
4. Push: git push origin feature/login

After pushing, the MR will be ready to merge.
```

---

## Workflow: Check Current Branch

**Phase 1: Detect Target Branch**

```bash
# Get current branch
git branch --show-current

# Get default branch
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'

# Check for conflicts
git fetch origin
git merge-tree $(git merge-base HEAD origin/main) HEAD origin/main
```

**Phase 2: Report Status**

```
✅ No conflicts detected!

Branch: feature/login
Target: main

Your branch can be merged cleanly.
Create MR: /gl-mr create

---

OR if conflicts:

⚠️  Potential conflicts detected

Branch: feature/login
Target: main

Files that may conflict:
- src/auth/login.js
- package.json

main has 3 new commits. Consider merging main first:
git merge origin/main
```

---

## Conflict Patterns

Common conflict types:
1. **Same line changes**: Both modified same lines
2. **Adjacent changes**: Changes near each other
3. **File moves**: One renamed, other modified
4. **Deleted files**: One deleted, other modified

---

## Smart Features

1. **Auto-detect strategy**: Suggest best resolution approach
2. **Test reminder**: Remind to run tests after resolution
3. **History context**: Show why each change was made (commit messages)
4. **Undo support**: Provide commands to abort if needed

---

## Error Handling

- **No conflicts**: Celebrate! "Your branch is clean"
- **Complex conflicts**: Suggest manual resolution with Web IDE
- **Binary files**: Cannot auto-resolve, explain manual steps
- **Merge in progress**: Detect and offer to continue or abort
