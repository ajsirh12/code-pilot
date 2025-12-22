---
description: "Code quality review using specialized agents (analyzes local git diff)"
argument-hint: "[review-aspects: comments|tests|errors|types|code|simplify|all]"
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Task", "AskUserQuestion"]
---

# Code Quality Review

Analyze local code changes using specialized agents, each focusing on a different aspect of code quality.

**Review Aspects (optional):** "$ARGUMENTS"

## Review Workflow

### 1. Identify Changed Files

```bash
# Staged and unstaged changes
git diff --name-only HEAD

# Current branch info
git branch --show-current
```

### 2. Available Review Aspects

- **comments** - Analyze code comment accuracy and maintainability
- **tests** - Review test coverage quality and completeness
- **errors** - Check error handling for silent failures
- **types** - Analyze type design and invariants (if new types added)
- **code** - General code review for project guidelines (CLAUDE.md)
- **simplify** - Simplify code for clarity and maintainability
- **all** - Run all applicable reviews (default)

### 3. Determine Applicable Reviews

Based on changes:
- **Always applicable**: code-reviewer (general quality)
- **If test files changed**: test-analyzer
- **If comments/docs added**: comment-analyzer
- **If error handling changed**: silent-failure-hunter
- **If types added/modified**: type-design-analyzer
- **After passing review**: code-simplifier (polish and refine)

### 4. Launch Review Agents

**Sequential approach** (default):
- Easier to understand and act on
- Each report is complete before next

**Parallel approach** (user can request with `parallel`):
- Launch all agents simultaneously
- Faster for comprehensive review

### 5. Aggregate Results

After agents complete, summarize:
- **Critical Issues** (must fix)
- **Important Issues** (should fix)
- **Suggestions** (nice to have)
- **Positive Observations** (what's good)

### 6. Output Format

```markdown
# Code Review Summary

## Critical Issues (X found)
- [agent-name]: Issue description [file:line]

## Important Issues (X found)
- [agent-name]: Issue description [file:line]

## Suggestions (X found)
- [agent-name]: Suggestion [file:line]

## Strengths
- What's well-done in this code

## Recommended Action
1. Fix critical issues first
2. Address important issues
3. Consider suggestions
```

---

## Usage Examples

```bash
# Full review (default)
/code-quality:review

# Specific aspects
/code-quality:review tests errors
/code-quality:review comments
/code-quality:review simplify

# Parallel review
/code-quality:review all parallel
```

---

## Agent Descriptions

| Agent | Focus |
|-------|-------|
| **comment-analyzer** | Comment accuracy, comment rot, documentation |
| **test-analyzer** | Test coverage, critical gaps, test quality |
| **silent-failure-hunter** | Silent failures, catch blocks, error logging |
| **type-design-analyzer** | Type encapsulation, invariants, type design |
| **code-reviewer** | CLAUDE.md compliance, bugs, code quality |
| **code-simplifier** | Simplify complex code, improve clarity |

---

## Workflow Integration

**Before committing:**
```
1. Write code
2. Run: /code-quality:review code errors
3. Fix any critical issues
4. Commit with /commit-commands:commit
```

**Before creating MR/PR:**
```
1. Stage all changes
2. Run: /code-quality:review all
3. Fix all critical and important issues
4. Create MR/PR with /commit-commands:commit-push-pr
```

---

## Notes

- Analyzes `git diff` (local changes only)
- Does NOT interact with remote MR/PR
- Use `gitlab-toolkit` for MR management
- Use `commit-commands` for PR/MR creation
