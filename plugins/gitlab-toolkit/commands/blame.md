---
description: View line-by-line commit history for files
argument-hint: "file:line | file"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Blame

You are helping a developer trace the history of specific code lines.

## Core Principles

- **Find the author**: Who wrote this code?
- **Understand context**: Why was it written?
- **Track changes**: When did it change?

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported formats**:
- `file:line` - Blame specific line
- `file` - Blame entire file
- `file:start-end` - Blame line range

---

## Workflow: Blame File

**Phase 1: Get Blame Data**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/[encoded_path]/blame?ref=main" | \
  jq '.[] | {
    commit: .commit.short_id,
    author: .commit.author_name,
    date: .commit.authored_date,
    lines
  }'
```

**Phase 2: Present Blame**

```
🔍 Blame: src/auth/login.js

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
abc1234 │ @jane  │ 3h ago  │  1 │ import { validateInput } from './validation';
abc1234 │ @jane  │ 3h ago  │  2 │ import { authenticate } from './api';
abc1234 │ @jane  │ 3h ago  │  3 │
def5678 │ @bob   │ 2d ago  │  4 │ export async function handleLogin(username, password) {
def5678 │ @bob   │ 2d ago  │  5 │   if (!validateInput(username, password)) {
ghi9012 │ @alice │ 1w ago  │  6 │     throw new Error('Invalid credentials');
ghi9012 │ @alice │ 1w ago  │  7 │   }
def5678 │ @bob   │ 2d ago  │  8 │
def5678 │ @bob   │ 2d ago  │  9 │   const result = await authenticate(username, password);
def5678 │ @bob   │ 2d ago  │ 10 │   return result;
jkl3456 │ @jane  │ 2w ago  │ 11 │ }
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
- 4 commits touched this file
- 3 authors: @jane (5 lines), @bob (4 lines), @alice (2 lines)
- Last change: 3 hours ago

Actions:
1. View commit abc1234 details
2. View changes by @bob
3. Show blame for specific line

What would you like to do?
```

---

## Workflow: Blame Specific Line

**Phase 1: Get Line History**

```bash
# Get blame for the file
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/[encoded_path]/blame?ref=main"
```

**Phase 2: Find Line in Blame**

```
🔍 Blame: src/auth/login.js:45

Line 45:
  throw new Error('Invalid credentials');

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Last modified by: @alice
Commit: ghi9012
Date: 1 week ago
Message: "fix: improve error messages"

Full commit:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ghi9012 fix: improve error messages

Changed 'Login failed' to 'Invalid credentials'
for better user experience.

Files changed: 3
- src/auth/login.js (+1 -1)
- src/auth/register.js (+1 -1)
- src/auth/reset.js (+1 -1)

Related: Closes #89

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Previous versions of this line:
1. ghi9012 (current): throw new Error('Invalid credentials');
2. def5678 (2d ago):  throw new Error('Login failed');
3. jkl3456 (2w ago):  return false;

Actions:
1. View full commit ghi9012
2. View previous version
3. View related MR

What would you like to do?
```

---

## Workflow: Blame Line Range

```
🔍 Blame: src/auth/login.js:45-52

Lines 45-52:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ghi9012 │ @alice │ 1w │ 45 │   throw new Error('Invalid credentials');
ghi9012 │ @alice │ 1w │ 46 │ }
def5678 │ @bob   │ 2d │ 47 │
def5678 │ @bob   │ 2d │ 48 │ async function refreshToken() {
def5678 │ @bob   │ 2d │ 49 │   const token = getStoredToken();
def5678 │ @bob   │ 2d │ 50 │   if (!token) return null;
abc1234 │ @jane  │ 3h │ 51 │   return await validateToken(token);
def5678 │ @bob   │ 2d │ 52 │ }
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Commits in this range:
- abc1234 @jane 3h ago - "fix: token validation"
- def5678 @bob  2d ago - "feat: add token refresh"
- ghi9012 @alice 1w ago - "fix: error messages"
```

---

## Workflow: Trace Line Through History

```
📜 Line History: src/auth/login.js:45

Current:
  throw new Error('Invalid credentials');

History:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ghi9012 │ 1w ago  │ throw new Error('Invalid credentials');
        │ @alice  │ "fix: improve error messages"
        │         │
def5678 │ 2d ago  │ throw new Error('Login failed');
        │ @bob    │ "refactor: auth error handling"
        │         │
jkl3456 │ 2w ago  │ return false;
        │ @jane   │ "feat: add login function"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This line has been modified 3 times.
Original author: @jane
Last modifier: @alice
```

---

## Smart Features

1. **Context lines**: Show surrounding code for context
2. **Author summary**: Group by author contribution
3. **Age coloring**: Highlight old vs new code
4. **Link to MR**: Show which MR introduced the change

---

## Error Handling

- **File not found**: Suggest similar files
- **Line out of range**: Show file length
- **Binary file**: Cannot blame binary files
- **Deleted file**: Show last known blame
