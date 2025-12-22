---
description: Create a git commit with auto-generated message
allowed-tools: Bash(git:*)
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your Task

Based on the above changes, create a single git commit.

### Workflow

1. **Stage changes**: `git add .` (or specific files)
2. **Create commit**: Generate appropriate commit message based on changes
3. **Report result**: Show commit hash and summary

### Commit Message Guidelines

- Use conventional commits format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`
- Keep first line under 72 characters
- Add body if needed for complex changes

### Example

```bash
git add .
git commit -m "feat(auth): add JWT token validation

- Add token expiration check
- Implement refresh token logic"
```

Execute stage and commit in a single response.
