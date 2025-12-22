---
description: Manage issue and MR templates
argument-hint: "list | issue [name] | mr [name] | create"
allowed-tools: Bash(curl:*), Read, Write, AskUserQuestion, TodoWrite
---

# GitLab Templates Management

You are helping a developer manage issue and MR description templates.

## Core Principles

- **Consistency**: Templates ensure consistent reporting
- **Efficiency**: Pre-filled sections speed up creation
- **Best practices**: Guide users to include important info

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `list` - List available templates
- `issue [name]` - View/apply issue template
- `mr [name]` - View/apply MR template
- `create issue` - Create new issue template
- `create mr` - Create new MR template
- (empty) - List all templates

---

## Workflow: List Templates

**Phase 1: Get Templates**

```bash
# Issue templates in .gitlab/issue_templates/
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/tree?path=.gitlab/issue_templates&ref=main" | \
  jq '.[] | select(.type == "blob") | .name'

# MR templates in .gitlab/merge_request_templates/
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/tree?path=.gitlab/merge_request_templates&ref=main" | \
  jq '.[] | select(.type == "blob") | .name'
```

**Phase 2: Present Templates**

```
📝 Project Templates

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 ISSUE TEMPLATES:

1. Bug Report
   For reporting bugs and issues

2. Feature Request
   For proposing new features

3. Documentation
   For documentation improvements

4. Security Issue
   For security vulnerabilities (confidential)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔀 MR TEMPLATES:

1. Default
   Standard MR template

2. Hotfix
   For urgent fixes

3. Feature
   For new feature implementations

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
1. View template content
2. Create new template
3. Edit existing template

What would you like to do?
```

---

## Workflow: View Template

**Phase 1: Get Template Content**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/.gitlab%2Fissue_templates%2FBug%20Report.md?ref=main" | \
  jq -r '.content' | base64 -d
```

**Phase 2: Display Template**

```
📋 Issue Template: Bug Report

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Summary
<!-- Brief description of the bug -->

## Steps to Reproduce
1.
2.
3.

## Expected Behavior
<!-- What should happen -->

## Actual Behavior
<!-- What actually happens -->

## Environment
- Browser:
- OS:
- Version:

## Screenshots
<!-- If applicable -->

## Logs
<!-- Any relevant error logs -->

/label ~bug ~needs-triage

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
1. Edit this template
2. Use this template (create issue)
3. Copy template content

What would you like to do?
```

---

## Workflow: Create Issue Template

**Phase 1: Choose Template Type**

```
📝 Create Issue Template

Choose a starting point:
1. Bug Report (recommended for most projects)
2. Feature Request
3. Documentation
4. Security Issue
5. Custom (blank)

Which type?
```

**Phase 2: Get Template Details**

```
Template name: [e.g., Bug Report]
Filename: bug_report.md

Quick Actions (auto-applied):
1. Labels? (e.g., ~bug ~needs-triage)
2. Assignee? (e.g., /assign @security-team)
3. Confidential? (e.g., /confidential)

What sections should this template have?
```

**Phase 3: Generate Template**

```
📝 Preview: Bug Report Template

## Summary
<!-- Brief description of the bug -->

## Steps to Reproduce
1.
2.
3.

## Expected Behavior
<!-- What should happen -->

## Actual Behavior
<!-- What actually happens -->

## Environment
- Browser:
- OS:
- Version:

## Additional Context
<!-- Any other relevant information -->

/label ~bug ~needs-triage

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Create this template?
```

**Phase 4: Save Template**

```bash
# Create template file
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "branch": "main",
    "content": "[template_content_base64]",
    "commit_message": "Add bug report issue template",
    "encoding": "base64"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/files/.gitlab%2Fissue_templates%2Fbug_report.md"
```

**Phase 5: Report Result**

```
✅ Template created!

File: .gitlab/issue_templates/bug_report.md
Commit: abc1234 "Add bug report issue template"

The template is now available when creating issues.
Users will see "Bug Report" in the template dropdown.
```

---

## Workflow: Create MR Template

```
📝 Create MR Template: Feature

## Summary
<!-- What does this MR do? -->

## Related Issues
<!-- Closes #XX -->

## Changes
- [ ] Change 1
- [ ] Change 2

## Testing
<!-- How was this tested? -->

## Screenshots
<!-- If applicable -->

## Checklist
- [ ] Tests added
- [ ] Documentation updated
- [ ] Changelog updated

/assign @reviewer
/label ~feature
```

---

## Standard Templates

**Bug Report:**
```markdown
## Summary
## Steps to Reproduce
## Expected Behavior
## Actual Behavior
## Environment
## Screenshots
## Logs
/label ~bug
```

**Feature Request:**
```markdown
## Problem Statement
## Proposed Solution
## Alternatives Considered
## Additional Context
/label ~feature ~needs-discussion
```

**MR Default:**
```markdown
## Summary
## Related Issues
## Changes
## Testing
## Checklist
```

**Hotfix MR:**
```markdown
## Problem
## Root Cause
## Fix
## Testing
## Rollback Plan
/label ~hotfix ~urgent
```

---

## Quick Actions in Templates

- `/label ~bug` - Add labels
- `/assign @user` - Assign user
- `/milestone %"v1.0"` - Set milestone
- `/due tomorrow` - Set due date
- `/confidential` - Make confidential
- `/weight 3` - Set weight

---

## Smart Features

1. **Template suggestions**: Recommend templates based on project type
2. **Quick action validation**: Verify labels/users exist
3. **Template inheritance**: Extend from base templates
4. **Usage analytics**: Show which templates are most used

---

## Error Handling

- **Template exists**: Offer to update or rename
- **Invalid path**: Create .gitlab directory first
- **Protected branch**: Create via MR
- **Invalid quick actions**: Warn about non-existent labels/users
