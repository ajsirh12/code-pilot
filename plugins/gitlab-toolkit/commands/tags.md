---
description: Manage git tags - create, list, delete
argument-hint: "list | create v1.0.0 | delete v1.0.0 | protect v*"
allowed-tools: Bash(curl:*), Bash(git:*), AskUserQuestion, TodoWrite
---

# GitLab Tags Management

You are helping a developer manage git tags for versioning and releases.

## Core Principles

- **Semantic versioning**: Follow semver conventions
- **Protect important tags**: Prevent accidental deletion
- **Link to releases**: Tags can trigger releases

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `list` - List all tags
- `create v1.0.0` - Create new tag
- `create v1.0.0 --from branch` - Tag specific ref
- `delete v1.0.0` - Delete tag
- `protect pattern` - Protect tags matching pattern
- (empty) - List recent tags

---

## Workflow: List Tags

**Phase 1: Get Tags**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/tags?order_by=updated&sort=desc&per_page=20" | \
  jq '.[] | {
    name,
    message,
    target: .commit.short_id,
    created: .commit.created_at,
    protected
  }'
```

**Phase 2: Present Tags**

```
🏷️  Repository Tags

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RECENT TAGS:

v1.2.0    🔒  abc1234  2d ago   "Release 1.2.0 - OAuth support"
v1.1.2        def5678  1w ago   "Hotfix for login bug"
v1.1.1    🔒  ghi9012  2w ago   "Security patch"
v1.1.0    🔒  jkl3456  1m ago   "Feature release"
v1.0.0    🔒  mno7890  3m ago   "Initial release"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
- Total tags: 12
- Protected: 5 (v1.*)
- Latest: v1.2.0

Actions:
1. Create new tag
2. View tag details
3. Delete tag
4. Manage protection

What would you like to do?
```

---

## Workflow: Create Tag

**Phase 1: Gather Information**

```
🏷️  Create New Tag

Current latest: v1.2.0

Suggested next versions:
1. v1.2.1 (patch - bug fixes)
2. v1.3.0 (minor - new features)
3. v2.0.0 (major - breaking changes)
4. Custom version

Which version?
```

**Phase 2: Confirm Tag Details**

```
Creating tag: v1.2.1

Source: main (abc1234)
Message: "Patch release - bug fixes"

Recent commits since v1.2.0:
- abc1234 fix: login validation
- def5678 fix: button styling
- ghi9012 docs: update README

Create this tag?
```

**Phase 3: Create Tag**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "tag_name": "v1.2.1",
    "ref": "main",
    "message": "Patch release - bug fixes"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/tags"
```

**Phase 4: Report Result**

```
✅ Tag created!

Tag: v1.2.1
Commit: abc1234
Message: "Patch release - bug fixes"

Next steps:
- Create release: /gl-release v1.2.1
- Protect tag: /gl-tags protect v1.*
- Push to registry: (CI/CD will trigger)

Tag URL: https://gitlab.tepseg.com/.../tags/v1.2.1
```

---

## Workflow: Create Tag from Branch/Commit

```bash
# Tag specific commit
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "tag_name": "v1.2.1",
    "ref": "abc1234567890",
    "message": "Hotfix release"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/tags"

# Tag branch head
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "tag_name": "v1.2.1",
    "ref": "release/1.2",
    "message": "Release from branch"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/tags"
```

---

## Workflow: Delete Tag

**Phase 1: Confirm Deletion**

```
🗑️  Delete Tag

Tag: v1.2.0-beta
Commit: xyz7890
Created: 2 weeks ago
Protected: No

⚠️  This will permanently delete the tag.
If a release is linked, it will be orphaned.

Delete this tag?
```

**Phase 2: Delete Tag**

```bash
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/tags/v1.2.0-beta"
```

**Phase 3: Report Result**

```
✅ Tag deleted!

Tag: v1.2.0-beta

Note: The commit (xyz7890) still exists.
Only the tag reference was removed.
```

---

## Workflow: Protect Tags

**Phase 1: Get Current Protection**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_tags" | \
  jq '.[] | {name, create_access_levels}'
```

**Phase 2: Present Protection**

```
🔒 Protected Tags

Current protection rules:

Pattern: v*
  - Create: Maintainers only
  - Matching: v1.0.0, v1.1.0, v1.2.0...

Pattern: release-*
  - Create: Developers+
  - Matching: release-2024-01, release-2024-02...

Actions:
1. Add protection rule
2. Remove protection rule
3. Modify access level

What would you like to do?
```

**Phase 3: Add Protection**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "v*",
    "create_access_level": 40
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_tags"
```

**Phase 4: Report Result**

```
✅ Tag protection added!

Pattern: v*
Access: Maintainers only (level 40)

Protected tags cannot be deleted by Developers.
Only Maintainers can create matching tags.
```

---

## Access Levels

- `0` - No access
- `30` - Developers + Maintainers
- `40` - Maintainers only

---

## Smart Features

1. **Version suggestion**: Suggest next semver version
2. **Changelog preview**: Show commits since last tag
3. **Release linking**: Option to create release from tag
4. **CI/CD trigger**: Note if tag triggers pipeline

---

## Error Handling

- **Tag exists**: Cannot create duplicate, suggest different name
- **Protected**: Cannot delete protected tag
- **Invalid name**: Must follow tag naming conventions
- **Ref not found**: Commit/branch doesn't exist
