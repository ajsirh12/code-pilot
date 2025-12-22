---
allowed-tools: Bash(git:*), Bash(gh:*), Bash(curl:*), AskUserQuestion
description: Commit, push, and open a PR (supports GitHub and GitLab)
---

# Commit, Push, and Create PR/MR

## Phase 1: Detect Platform

First, detect the git remote to determine the platform:

```bash
git remote get-url origin
```

**Platform Detection:**
- Contains `github.com` → GitHub (use `gh pr create`)
- Contains `gitlab` → GitLab (use GitLab API)
- Otherwise → Ask user

## Phase 2: Gather Context

```bash
git status
git diff HEAD
git branch --show-current
```

## Phase 3: Confirm Platform (if ambiguous)

If platform cannot be auto-detected, ask the user:

```
Which platform is this repository hosted on?

1. GitHub (will use `gh pr create`)
2. GitLab (will use GitLab API to create MR)
```

## Phase 4: Execute Workflow

### Common Steps (both platforms):
1. Create a new branch if on main/master
2. Stage changes: `git add .`
3. Create commit with appropriate message
4. Push branch to origin: `git push -u origin <branch>`

### GitHub-specific:
5. Create PR: `gh pr create --fill`

### GitLab-specific:
5. Create MR using GitLab API:
```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "source_branch": "<branch>",
    "target_branch": "main",
    "title": "<commit message>",
    "remove_source_branch": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests"
```

## Phase 5: Report Result

**GitHub:**
```
✅ PR created successfully!
URL: https://github.com/owner/repo/pull/123
```

**GitLab:**
```
✅ MR created successfully!
URL: https://gitlab.example.com/group/project/-/merge_requests/45
```

## Notes

- For GitLab, ensure `GITLAB_URL`, `GITLAB_TOKEN`, and `GITLAB_PROJECT_ID` are set
- For GitHub, ensure `gh` CLI is authenticated
- Execute all steps in a single response when possible
