---
description: Intelligent search across GitLab - issues, MRs, commits, code with smart filtering
argument-hint: "query [--scope issues|mrs|commits|code]"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Intelligent Search

You are helping a developer find information across GitLab. Follow a systematic approach: understand intent, search smartly, present actionable results.

## Core Principles

- **Understand intent first**: What is the user really looking for?
- **Search smart**: Use appropriate scope and filters
- **Present actionable results**: Enable immediate action on findings
- **Learn from patterns**: Detect patterns in query to auto-filter

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `"query"` - Search with auto-detected scope
- `"query" --scope issues` - Search issues only
- `"query" --scope mrs` - Search MRs only
- `"query" --scope commits` - Search commits only
- `"query" --scope code` - Search code only
- (empty) - Ask what user wants to find

---

## Workflow: Intelligent Search

**Phase 1: Understand Search Intent**

If no query provided, **ask user**:
```
What are you looking for?

Examples:
- "login bug" - Find issues/MRs about login bugs
- "#123" - Find specific issue
- "!45" - Find specific MR
- "function validateUser" - Find code
- "@jane" - Find contributions by user
```

**Detect query patterns**:
- `#123` → Issue search
- `!45` → MR search
- `@username` → User contributions
- `file:path` → Code in specific file
- Quoted text → Exact match

**Phase 2: Execute Search**

1. **Verify environment first**:
   ```bash
   echo "Searching in project: $GITLAB_PROJECT_ID"
   ```

2. **Run search based on scope**:
   ```bash
   # Auto-detect or use specified scope
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/search?scope=[scope]&search=[query]"
   ```

3. **For comprehensive search, run multiple scopes in parallel**

**Phase 3: Analyze Results**

Before presenting, analyze:
- Total results per scope
- Relevance (title match vs content match)
- Recency (newer = more relevant)
- Status (open issues/MRs more important)

**Phase 4: Present Smart Results**

```
🔍 Search Results for "login bug"

Found 12 results across 4 scopes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 ISSUES (3 results) - Most Relevant

🔴 #123  Login fails on Safari           open     priority::high
   └─ Matches: title, description
   └─ Last activity: 2 hours ago

🟢 #98   Login button styling fix        closed
   └─ Matches: description
   └─ Closed: 1 week ago

🟢 #45   Login redirect issue            closed
   └─ Matches: title
   └─ Closed: 1 month ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔀 MERGE REQUESTS (2 results)

🟢 !45   Fix login bug on Safari         open     ready to merge
   └─ Linked to: #123
   └─ Pipeline: passed

🟣 !32   Refactor login flow             merged
   └─ Merged: 2 weeks ago

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 COMMITS (4 results)

abc1234  fix: login validation bug       @jane    2 days ago
def5678  feat: add login analytics       @bob     1 week ago
   └─ (2 more commits...)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 CODE (3 results)

src/auth/login.js:45
   └─ "// Fix for login bug in Safari"

src/components/LoginForm.vue:23
   └─ "handleLoginBug() {"

   └─ (1 more file...)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Recommendation:
   Issue #123 and MR !45 are most relevant.
   The MR is ready to merge and will close #123.

Actions:
1. View issue #123 details
2. View MR !45 (ready to merge!)
3. Search with different scope
4. Refine search query

What would you like to do?
```

**Phase 5: Enable Quick Actions**

Based on user selection:
- View item → Show full details
- Take action → Open appropriate command
- Refine → Run new search with filters

---

## Smart Search Features

**1. Auto-Scope Detection**
```
"#123"         → Directly fetch issue #123
"!45"          → Directly fetch MR !45
"login bug"    → Search all scopes
"fix:"         → Likely commits (conventional commit)
"TODO"         → Likely code search
```

**2. Relevance Ranking**
- Title match > Description match > Content match
- Open items > Closed items
- Recent items > Old items
- High priority > Low priority

**3. Related Items**
- Show linked issues/MRs together
- Group commits by branch/MR

**4. Search Suggestions**
If no results:
```
No results for "lgoin bug"

Did you mean: "login bug"?
Or try:
- Broader search: "login"
- Different scope: --scope code
```

---

## Workflow: Direct Item Lookup

When query is `#123` or `!45`:

**Phase 1: Fetch Item Directly**

```bash
# For issue
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/123"

# For MR
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/merge_requests/45"
```

**Phase 2: Show Full Details**

```
📋 Issue #123: Login fails on Safari

Status: 🟢 Open
Priority: 🔴 Critical
Assignee: @jane
Milestone: Phase 1

Description:
Users report that login fails on Safari 17...

Labels: bug, browser-compat, priority::high

Time Tracking:
- Estimate: 4h
- Spent: 2h

Related:
- MR !45 (will close this issue)
- Blocked by: #115

Recent Activity:
- @bob commented 2h ago
- @jane assigned 1d ago

Actions:
1. View comments
2. View linked MR !45
3. Assign to me
4. Add comment
```

---

## Error Handling

- **No results**: Suggest broader search, check spelling
- **Too many results**: Suggest filters, show top 10
- **Rate limited**: Wait and retry
- **Invalid query**: Explain valid query formats

---

## Integration Points

After finding items, offer to:
- `/gl-issue` - Manage found issues
- `/gl-mr` - Manage found MRs
- `/gl-blame` - View code history for found files
