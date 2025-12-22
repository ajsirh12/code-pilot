---
description: Browse, view, and edit repository files
argument-hint: "browse [path] | view file | edit file | create file"
allowed-tools: Bash(curl:*), Read, Write, AskUserQuestion, TodoWrite
---

# GitLab File Operations

You are helping a developer browse and edit repository files via GitLab API.

## Core Principles

- **Browse safely**: View without modifying
- **Edit with commits**: All changes create commits
- **Respect branches**: Work on correct branch

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `browse [path]` - List directory contents
- `view file` - View file contents
- `edit file` - Edit existing file
- `create file` - Create new file
- `delete file` - Delete file
- `history file` - View file history
- (empty) - Browse root directory

---

## Workflow: Browse Directory

**Phase 1: Get Directory Contents**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/tree?path=[path]&ref=main" | \
  jq '.[] | {name, type, path}'
```

**Phase 2: Present Contents**

```
📁 Repository Browser

Path: src/auth/
Branch: main

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Directories:
   tests/
   utils/

📄 Files:
   index.js          2.3 KB    Modified 2d ago
   login.js          4.5 KB    Modified 3h ago
   validation.js     1.8 KB    Modified 1w ago
   oauth.js          3.2 KB    Modified 5d ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
1. View file
2. Edit file
3. Browse subdirectory
4. Go up (../)

What would you like to do?
```

---

## Workflow: View File

**Phase 1: Get File Content**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/[encoded_path]?ref=main" | \
  jq -r '.content' | base64 -d
```

**Phase 2: Present File**

```
📄 File: src/auth/login.js

Branch: main
Size: 4.5 KB
Last modified: 3 hours ago by @jane

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 1 | import { validateInput } from './validation';
 2 | import { authenticate } from './api';
 3 |
 4 | export async function handleLogin(username, password) {
 5 |   if (!validateInput(username, password)) {
 6 |     throw new Error('Invalid credentials');
 7 |   }
 8 |
 9 |   const result = await authenticate(username, password);
10 |   return result;
11 | }
...

(showing first 50 lines, 120 total)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
1. View full file
2. Edit this file
3. View history
4. View blame

What would you like to do?
```

---

## Workflow: Edit File

**Phase 1: Get Current Content**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/[encoded_path]?ref=main"
```

**Phase 2: Confirm Edit**

```
✏️  Edit File: src/auth/login.js

Current branch: main (protected)

For protected branches, edits will:
1. Create new branch: edit/login-js-[timestamp]
2. Commit changes
3. Open MR to main

What changes would you like to make?
(Describe the changes or provide new content)
```

**Phase 3: Apply Changes**

```bash
# Create/Update file
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "branch": "main",
    "content": "[new_content_base64]",
    "commit_message": "Update login.js",
    "encoding": "base64"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/[encoded_path]"

# For protected branches, use start_branch
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "branch": "edit/login-js",
    "start_branch": "main",
    "content": "[new_content_base64]",
    "commit_message": "Update login.js"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/[encoded_path]"
```

**Phase 4: Report Result**

```
✅ File updated!

File: src/auth/login.js
Commit: abc1234 "Update login.js"
Branch: edit/login-js

MR created: !50
URL: https://gitlab.tepseg.com/.../merge_requests/50

Review and merge to apply changes to main.
```

---

## Workflow: Create File

**Phase 1: Get Details**

```
📝 Create New File

Path: src/auth/
Filename: oauth-config.js

Enter file content:
(or describe what the file should contain)
```

**Phase 2: Create File**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "branch": "main",
    "content": "[content_base64]",
    "commit_message": "Add oauth-config.js",
    "encoding": "base64"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/[encoded_path]"
```

**Phase 3: Report Result**

```
✅ File created!

File: src/auth/oauth-config.js
Commit: xyz7890 "Add oauth-config.js"
Branch: main

The file is now available in the repository.
```

---

## Workflow: Delete File

```
🗑️  Delete File

File: src/old-login.js

⚠️  This will permanently delete the file.
A commit will be created to record the deletion.

Proceed?
```

```bash
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "branch": "main",
    "commit_message": "Remove old-login.js"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/[encoded_path]"
```

---

## Workflow: File History

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/[encoded_path]/blame?ref=main"
```

Present as:
```
📜 File History: src/auth/login.js

Commits:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
abc1234  fix: login validation    @jane   3h ago
def5678  refactor: auth flow      @bob    2d ago
ghi9012  feat: add login          @alice  1w ago
jkl3456  initial commit           @jane   2w ago

4 commits, 3 contributors
```

---

## Smart Features

1. **Syntax highlighting**: Detect file type for display
2. **Large file warning**: Warn for files > 1MB
3. **Binary detection**: Handle binary files appropriately
4. **Diff preview**: Show diff before committing

---

## Error Handling

- **File not found**: Suggest similar files
- **Protected branch**: Create MR workflow
- **Binary file**: Cannot view/edit, offer download
- **File too large**: Show truncated version
- **Encoding issues**: Handle UTF-8 properly
