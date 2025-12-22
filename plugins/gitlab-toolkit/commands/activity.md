---
description: View project activity feed - commits, MRs, issues, and more
argument-hint: "[--since today|yesterday|week] [--author @user]"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Activity Feed

You are helping a developer track project activity. Great for standups and keeping up with team progress.

## Core Principles

- **Show recent first**: Most recent activity on top
- **Group by type**: Organize by activity category
- **Filter flexibly**: By time, author, or type

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported filters**:
- `--since today` - Today's activity
- `--since yesterday` - Since yesterday
- `--since week` - Last 7 days
- `--author @user` - Filter by user
- (empty) - Last 24 hours activity

---

## Workflow: Activity Feed

**Phase 1: Gather Activity Data**

```bash
# Get project events
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/events?per_page=50" | \
  jq '.[] | {
    action: .action_name,
    target_type,
    target_title: .target_title,
    author: .author.username,
    created_at
  }'

# Get recent commits
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/commits?per_page=20" | \
  jq '.[] | {
    short_id,
    title,
    author_name,
    created_at
  }'

# Get recent MR activity
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests?state=all&order_by=updated_at&per_page=10" | \
  jq '.[] | {iid, title, state, author: .author.username, updated_at}'

# Get recent issue activity
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues?state=all&order_by=updated_at&per_page=10" | \
  jq '.[] | {iid, title, state, author: .author.username, updated_at}'
```

**Phase 2: Present Activity**

```
📊 Project Activity - Last 24 Hours

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🕐 TODAY

14:32  @jane pushed 2 commits to feature/login
       abc1234 feat: add login validation
       def5678 fix: button styling

13:15  @bob merged !42 into main
       "Add OAuth support"

12:45  @jane opened !45
       "Fix login bug on Safari"

11:30  @alice commented on #123
       "I can reproduce this issue"

10:00  @john closed #118
       "Add dark mode toggle"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🕐 YESTERDAY

18:00  @bob opened !42
       "Add OAuth support"

16:30  Pipeline failed on !41
       Job: test:unit

15:00  @jane created #123
       "Login fails on Safari"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 SUMMARY

Commits: 8
MRs opened: 2
MRs merged: 1
Issues opened: 3
Issues closed: 2

Most active: @jane (5 actions)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Actions:
1. View more activity
2. Filter by author
3. View specific item

What would you like to do?
```

---

## Workflow: Standup Summary

**For daily standups:**

```
📅 Standup Summary - Yesterday

@jane:
- Pushed 3 commits to feature/login
- Opened !45: Fix login bug
- Commented on #123

@bob:
- Merged !42: OAuth support
- Fixed pipeline on !41
- Reviewed !45

@alice:
- Closed #118, #119
- Created #124: New bug report

Today's focus:
- !45 needs review (1 day old)
- #123 priority::high unassigned
- Pipeline failing on !41
```

---

## Workflow: Filter by Author

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/events?per_page=50" | \
  jq '.[] | select(.author.username == "[username]")'
```

---

## Workflow: Filter by Time

```bash
# Get events after specific date
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/events?after=[date]&per_page=50"
```

---

## Activity Types

- **pushed** - Commits pushed
- **opened** - MR/Issue opened
- **closed** - MR/Issue closed
- **merged** - MR merged
- **commented** - Comment added
- **approved** - MR approved
- **joined** - Member joined project

---

## Smart Features

1. **Standup mode**: Summarize by team member
2. **Highlight important**: Show merges and closes prominently
3. **Pipeline integration**: Include pipeline events
4. **Mention detection**: Highlight when you're mentioned

---

## Error Handling

- **No activity**: "Quiet day! No activity in this period."
- **User not found**: List active project members
- **Large range**: Paginate or suggest smaller range
