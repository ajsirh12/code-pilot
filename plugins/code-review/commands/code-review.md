---
allowed-tools: Bash(git:*), Bash(gh:*), Bash(curl:*), Task, AskUserQuestion, TodoWrite
description: Code review a pull request (supports GitHub and GitLab)
---

# Code Review for PR/MR

## Phase 1: Detect Platform

```bash
git remote get-url origin
```

**Platform Detection:**
- Contains `github.com` → GitHub (use `gh` CLI)
- Contains `gitlab` → GitLab (use GitLab API)
- Otherwise → Ask user

## Phase 2: Confirm Platform (if needed)

If platform cannot be auto-detected:

```
Which platform is this repository hosted on?

1. GitHub (will use `gh` CLI)
2. GitLab (will use GitLab API)
```

## Phase 3: Get PR/MR Information

### GitHub:
```bash
gh pr view --json number,title,body,isDraft,state,files
gh pr diff
```

### GitLab:
```bash
# Get MR details
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?state=opened&source_branch=$(git branch --show-current)" | \
  jq '.[0] | {iid, title, description, draft, state}'

# Get MR diff
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/changes"
```

## Phase 4: Pre-Review Checks

Launch a haiku agent to check if any of the following are true:
- The PR/MR is closed
- The PR/MR is a draft
- The PR/MR does not need code review (e.g. automated, trivial change)
- You have already submitted a code review

If any condition is true, stop and do not proceed.

Note: Still review Claude generated PR/MRs.

## Phase 5: Gather Context

Launch a haiku agent to return a list of file paths for all relevant CLAUDE.md files:
- The root CLAUDE.md file, if it exists
- Any CLAUDE.md files in directories containing modified files

## Phase 6: Summarize Changes

Launch a sonnet agent to view the PR/MR and return a summary of the changes.

## Phase 7: Parallel Review Agents

Launch 4 agents in parallel to independently review:

**Agents 1 + 2: CLAUDE.md compliance (sonnet)**
- Audit changes for CLAUDE.md compliance
- Consider only CLAUDE.md files that share path with the file

**Agent 3: Bug detection (opus)**
- Scan for obvious bugs in the diff
- Flag only significant bugs; ignore nitpicks

**Agent 4: Code quality (opus)**
- Look for security issues, incorrect logic
- Only issues within the changed code

**CRITICAL: HIGH SIGNAL issues only:**
- Objective bugs causing incorrect runtime behavior
- Clear, unambiguous CLAUDE.md violations with exact quotes

**DO NOT flag:**
- Subjective concerns or "suggestions"
- Style preferences not in CLAUDE.md
- Potential issues that "might" be problems

## Phase 8: Validate Issues

For each issue found, launch parallel subagents to validate:
- Opus for bugs and logic issues
- Sonnet for CLAUDE.md violations

## Phase 9: Output Review

### GitHub (with --comment):
```bash
gh pr comment --body "## Code Review

Found X issues:
..."
```

### GitLab (with --comment):
```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"body": "## Code Review\n\nFound X issues:\n..."}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]/notes"
```

### Local output (default):
Output the review directly to terminal.

## Review Format

```markdown
## Code review

Found X issues:

1. <brief description> (CLAUDE.md says: "<exact quote>")
   <link to file and line>

2. <brief description> (bug due to <code snippet>)
   <link to file and line>
```

Or if no issues:

```markdown
## Auto code review

No issues found. Checked for bugs and CLAUDE.md compliance.
```

## False Positives to Avoid

- Pre-existing issues
- Correct code that appears buggy
- Pedantic nitpicks
- Issues a linter will catch
- General code quality not in CLAUDE.md
- Explicitly silenced issues (lint ignore comments)

## Notes

- Create a todo list before starting
- Cite and link each issue
- Use full git SHA in links
- For GitLab, ensure environment variables are set
