---
description: View project statistics - issues, MRs, contributors, and velocity
argument-hint: "[--period week|month|quarter] [--team]"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Project Statistics

You are helping a developer understand project metrics and team velocity.

## Core Principles

- **Actionable insights**: Focus on metrics that drive decisions
- **Trend awareness**: Show how metrics change over time
- **Team visibility**: Highlight contributions and bottlenecks

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported options**:
- `--period week` - Last 7 days
- `--period month` - Last 30 days (default)
- `--period quarter` - Last 90 days
- `--team` - Show per-member breakdown
- (empty) - Show overview for last 30 days

---

## Workflow: Project Overview

**Phase 1: Gather Statistics**

```bash
# Project info
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" | \
  jq '{
    star_count,
    forks_count,
    open_issues_count
  }'

# Issue statistics
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues_statistics" | \
  jq '.statistics.counts'

# MR statistics
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?state=opened" | \
  jq 'length'

# Commit count (last 30 days)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/commits?since=[30_days_ago]&per_page=100" | \
  jq 'length'

# Contributors
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/contributors" | \
  jq '.[0:10] | .[] | {name, commits, additions, deletions}'
```

**Phase 2: Calculate Metrics**

```bash
# Average time to merge MRs
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?state=merged&per_page=20" | \
  jq '[.[] | (.merged_at | fromdateiso8601) - (.created_at | fromdateiso8601)] | add / length / 3600'

# Issues opened vs closed
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues?created_after=[period_start]" | \
  jq 'length'
```

**Phase 3: Present Statistics**

```
📊 Project Statistics - Last 30 Days

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 OVERVIEW

Commits:          87 (+12% vs last month)
Active branches:  8
Contributors:     5

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 ISSUES

Open:       23
Opened:     15 this month
Closed:     18 this month
Net:        -3 (good! closing more than opening)

By Priority:
🔴 Critical:  2
🟠 High:      5
🟡 Medium:    10
🟢 Low:       6

Average time to close: 4.2 days

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔀 MERGE REQUESTS

Open:       5
Opened:     12 this month
Merged:     14 this month
Closed:     1 (without merge)

Average time to merge: 2.1 days
Average review time:   8.3 hours

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 TOP CONTRIBUTORS

1. @jane     32 commits   +2,345 / -567
2. @bob      28 commits   +1,234 / -890
3. @alice    15 commits   +567 / -123
4. @john     8 commits    +234 / -45
5. @mike     4 commits    +89 / -12

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔥 VELOCITY TREND

Week 1:  ████████░░  22 commits
Week 2:  ██████████  28 commits
Week 3:  ███████░░░  19 commits
Week 4:  █████████░  25 commits

Trend: Stable (+5% overall)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  ATTENTION AREAS

- 2 MRs open > 7 days (need review)
- 2 critical issues unassigned
- Pipeline success rate: 85% (target: 95%)

Actions:
1. View detailed team breakdown
2. View issue age analysis
3. View pipeline statistics
```

---

## Workflow: Team Breakdown

```
👥 Team Statistics - Last 30 Days

@jane (Lead Developer)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Commits: 32
MRs opened: 8
MRs reviewed: 12
Issues closed: 6
Avg review time: 4.2h

@bob (Backend)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Commits: 28
MRs opened: 6
MRs reviewed: 8
Issues closed: 4
Avg review time: 6.8h

@alice (Frontend)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Commits: 15
MRs opened: 4
MRs reviewed: 3
Issues closed: 5
Avg review time: 12.1h ⚠️ (high)
```

---

## Workflow: Issue Age Analysis

```
📋 Issue Age Analysis

Open Issues by Age:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
< 1 week:    8 ████████
1-2 weeks:   6 ██████
2-4 weeks:   5 █████
1-2 months:  3 ███
> 2 months:  1 █ ⚠️

Stale Issues (> 30 days, no activity):
#89  API rate limiting          45 days  @unassigned
#67  Mobile responsive issues   62 days  @john

Recommendation: Review and close or update stale issues
```

---

## Workflow: Pipeline Statistics

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?per_page=100" | \
  jq 'group_by(.status) | map({status: .[0].status, count: length})'
```

Present as:
```
🔧 Pipeline Statistics - Last 30 Days

Total runs: 156
Success rate: 85%

By Status:
✅ Success:   132 (85%)
❌ Failed:    18 (11%)
⏹️ Canceled:  6 (4%)

Most common failures:
1. test:unit (8 failures)
2. build:docker (5 failures)
3. deploy:staging (3 failures)

Average duration: 12m 34s
```

---

## Smart Features

1. **Trend comparison**: Compare to previous period
2. **Anomaly detection**: Highlight unusual patterns
3. **Recommendations**: Suggest improvements
4. **Export friendly**: Format for reports

---

## Error Handling

- **No data**: New project, show available metrics only
- **Partial data**: Show what's available, note missing
- **Rate limited**: Cache and show cached data
