---
description: View test coverage reports and changes
argument-hint: "!id | report | diff !id"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Test Coverage

You are helping a developer track and analyze test coverage.

## Core Principles

- **Show the delta**: How MR affects coverage
- **Highlight gaps**: Files with low/no coverage
- **Track trends**: Coverage over time

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `!id` - Show coverage for specific MR
- `report` - Show project coverage report
- `diff !id` - Show coverage diff for MR
- (empty) - Show current project coverage

---

## Workflow: Project Coverage

**Phase 1: Get Coverage Data**

```bash
# Get latest pipeline with coverage
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?status=success&per_page=1" | \
  jq '.[0] | {id, coverage, ref}'

# Get coverage from jobs
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/jobs?per_page=50" | \
  jq '.[] | select(.coverage != null) | {name, coverage, ref}'
```

**Phase 2: Present Coverage**

```
📊 Test Coverage Report

Project: my-project
Branch: main
Last updated: 2 hours ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 OVERALL COVERAGE: 78.5%

████████████████░░░░  78.5%

Target: 80%
Status: ⚠️ Below target (-1.5%)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 COVERAGE BY DIRECTORY

src/auth/         ██████████████████░░  89%
src/components/   ████████████████░░░░  82%
src/utils/        ████████████████████  95%
src/api/          ██████████░░░░░░░░░░  52% ⚠️
src/services/     ████████████████░░░░  78%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  LOW COVERAGE FILES

src/api/external.js        12%  (needs tests!)
src/api/webhook.js         34%
src/services/legacy.js     45%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 TREND (Last 5 builds)

#156  78.5%  ▲ +0.5%
#155  78.0%  ▼ -1.2%
#154  79.2%  ▲ +0.8%
#153  78.4%  ▲ +0.3%
#152  78.1%  ━ stable

Actions:
1. View low coverage files
2. View MR coverage impact
3. Set coverage target
```

---

## Workflow: MR Coverage Diff

**Phase 1: Get MR Pipeline Coverage**

```bash
# Get MR details with pipeline
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/[iid]" | \
  jq '{
    title,
    source_branch,
    target_branch,
    head_pipeline: .head_pipeline.id
  }'

# Get coverage from MR pipeline
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/[pipeline_id]" | \
  jq '{coverage}'

# Get target branch coverage
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?ref=main&status=success&per_page=1" | \
  jq '.[0].coverage'
```

**Phase 2: Present Coverage Diff**

```
📊 Coverage Impact for !45

MR: Fix login bug on Safari
Branches: feature/login → main

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 COVERAGE CHANGE

Before (main):  78.5%
After (MR):     79.2%
Change:         +0.7% ✅

████████████████░░░░  78.5% → 79.2%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 CHANGED FILES COVERAGE

src/auth/login.js
  Before: 85%
  After:  92%
  Change: +7% ✅

src/auth/validation.js (new file)
  Coverage: 100% ✅

tests/login.test.js
  Coverage: 100% ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  UNCOVERED NEW CODE

src/auth/login.js:67-72
  Error handling not covered by tests

Suggestion: Add test for error case

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Coverage Check: PASSED
   Meets minimum requirement (75%)
```

---

## Workflow: Coverage Badge

```bash
# Get coverage badge URL
echo "Coverage badge URL:"
echo "$GITLAB_URL/$PROJECT_PATH/badges/main/coverage.svg"
```

Present as:
```
📛 Coverage Badge for README

Markdown:
![Coverage](https://gitlab.tepseg.com/group/project/badges/main/coverage.svg)

HTML:
<img src="https://gitlab.tepseg.com/group/project/badges/main/coverage.svg" alt="Coverage">
```

---

## Workflow: Coverage History

```bash
# Get recent pipelines with coverage
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?ref=main&status=success&per_page=20" | \
  jq '.[] | {id, coverage, created_at}'
```

Present as:
```
📈 Coverage History (main branch)

Date        Pipeline  Coverage  Change
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Dec 20      #156      78.5%     +0.5%
Dec 19      #155      78.0%     -1.2%
Dec 18      #154      79.2%     +0.8%
Dec 17      #153      78.4%     +0.3%
Dec 16      #152      78.1%     stable

30-day trend: +2.3%
```

---

## Smart Features

1. **Threshold alerts**: Warn when coverage drops below target
2. **New code coverage**: Track coverage of changed lines only
3. **Untested detection**: Find completely untested files
4. **Trend analysis**: Predict coverage trajectory

---

## Error Handling

- **No coverage data**: Coverage not configured, show setup guide
- **Pipeline running**: Show last known coverage
- **Job failed**: Coverage not generated, show error
