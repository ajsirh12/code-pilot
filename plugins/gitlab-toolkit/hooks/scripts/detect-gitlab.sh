#!/bin/bash
# GitLab Auto-Detection Hook with Session Context
# Detects GitLab project and shows current work status

set -euo pipefail

# Read input (required by hook protocol)
input=$(cat)

# ============================================
# Phase 1: Git Detection
# ============================================

if [ ! -d ".git" ]; then
  echo '{"continue": true, "suppressOutput": true}'
  exit 0
fi

# Get current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")

# Get git status summary
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$UNCOMMITTED" -gt 0 ]; then
  GIT_STATUS="$UNCOMMITTED uncommitted"
else
  GIT_STATUS="clean"
fi

# Get remote URL
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
  # Git repo but no remote
  cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "📁 Git 저장소 ($BRANCH, $GIT_STATUS)\\n\\n원격 저장소가 설정되지 않았습니다.\\n/gl-bootstrap 으로 GitLab 연결 가능"
}
EOF
  exit 0
fi

# Check if it's a GitLab URL
if [[ ! "$REMOTE_URL" =~ gitlab ]]; then
  echo '{"continue": true, "suppressOutput": true}'
  exit 0
fi

# ============================================
# Phase 2: Extract Project Path
# ============================================

PROJECT_PATH=""
if [[ "$REMOTE_URL" =~ git@[^:]+:(.+)\.git$ ]]; then
  PROJECT_PATH="${BASH_REMATCH[1]}"
elif [[ "$REMOTE_URL" =~ https?://[^/]+/(.+)\.git$ ]]; then
  PROJECT_PATH="${BASH_REMATCH[1]}"
elif [[ "$REMOTE_URL" =~ https?://[^/]+/(.+)$ ]]; then
  PROJECT_PATH="${BASH_REMATCH[1]}"
fi

if [ -z "$PROJECT_PATH" ]; then
  echo '{"continue": true, "suppressOutput": true}'
  exit 0
fi

# ============================================
# Phase 3: Check Credentials
# ============================================

if [ -z "${GITLAB_URL:-}" ] || [ -z "${GITLAB_TOKEN:-}" ]; then
  cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "📁 $PROJECT_PATH ($BRANCH, $GIT_STATUS)\\n\\n⚠️ GitLab 환경변수 미설정:\\nexport GITLAB_URL=\\"https://gitlab.tepseg.com\\"\\nexport GITLAB_TOKEN=\\"glpat-xxxx\\""
}
EOF
  exit 0
fi

# ============================================
# Phase 4: Query GitLab API
# ============================================

ENCODED_PATH=$(echo "$PROJECT_PATH" | sed 's/\//%2F/g')

# Get project info
PROJECT_INFO=$(curl -s --max-time 5 --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$ENCODED_PATH" 2>/dev/null || echo "")

if [ -z "$PROJECT_INFO" ] || [[ "$PROJECT_INFO" == *"error"* ]] || [[ "$PROJECT_INFO" == *"message"* ]]; then
  cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "📁 $PROJECT_PATH ($BRANCH, $GIT_STATUS)\\n\\n⚠️ GitLab API 조회 실패"
}
EOF
  exit 0
fi

# Extract project ID and name
PROJECT_ID=$(echo "$PROJECT_INFO" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
PROJECT_NAME=$(echo "$PROJECT_INFO" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$PROJECT_ID" ]; then
  echo '{"continue": true, "suppressOutput": true}'
  exit 0
fi

# Set environment variable
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export GITLAB_PROJECT_ID=\"$PROJECT_ID\"" >> "$CLAUDE_ENV_FILE"
fi

# ============================================
# Phase 5: Get Current User
# ============================================

USER_INFO=$(curl -s --max-time 3 --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/user" 2>/dev/null || echo "")

USER_ID=""
USERNAME=""
if [ -n "$USER_INFO" ] && [[ "$USER_INFO" != *"error"* ]]; then
  USER_ID=$(echo "$USER_INFO" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
  USERNAME=$(echo "$USER_INFO" | grep -o '"username":"[^"]*"' | head -1 | cut -d'"' -f4)
fi

# ============================================
# Phase 6: Get My Issues (In Progress)
# ============================================

ISSUES_MSG=""
if [ -n "$USER_ID" ]; then
  MY_ISSUES=$(curl -s --max-time 3 --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$PROJECT_ID/issues?assignee_id=$USER_ID&state=opened&per_page=3" 2>/dev/null || echo "[]")

  ISSUE_COUNT=$(echo "$MY_ISSUES" | grep -o '"iid"' | wc -l | tr -d ' ')

  if [ "$ISSUE_COUNT" -gt 0 ]; then
    # Extract issue info (simplified parsing)
    ISSUES_MSG="\\n📋 내 이슈 ($ISSUE_COUNT)"

    # Parse first 3 issues
    while IFS= read -r line; do
      if [ -n "$line" ]; then
        ISSUES_MSG="$ISSUES_MSG\\n   $line"
      fi
    done < <(echo "$MY_ISSUES" | grep -o '"iid":[0-9]*,"title":"[^"]*"' | head -3 | \
      sed 's/"iid":\([0-9]*\),"title":"\([^"]*\)"/ → #\1 \2/')
  fi
fi

# ============================================
# Phase 7: Get My MRs
# ============================================

MRS_MSG=""
if [ -n "$USER_ID" ]; then
  MY_MRS=$(curl -s --max-time 3 --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$PROJECT_ID/merge_requests?author_id=$USER_ID&state=opened&per_page=3" 2>/dev/null || echo "[]")

  MR_COUNT=$(echo "$MY_MRS" | grep -o '"iid"' | wc -l | tr -d ' ')

  if [ "$MR_COUNT" -gt 0 ]; then
    MRS_MSG="\\n🔀 내 MR ($MR_COUNT)"

    while IFS= read -r line; do
      if [ -n "$line" ]; then
        MRS_MSG="$MRS_MSG\\n   $line"
      fi
    done < <(echo "$MY_MRS" | grep -o '"iid":[0-9]*,"title":"[^"]*"' | head -3 | \
      sed 's/"iid":\([0-9]*\),"title":"\([^"]*\)"/ → !\1 \2/')
  fi
fi

# ============================================
# Phase 8: Get Uncommitted Files
# ============================================

UNCOMMITTED_MSG=""
if [ "$UNCOMMITTED" -gt 0 ]; then
  UNCOMMITTED_MSG="\\n📝 미커밋 ($UNCOMMITTED files)"

  # Get first 3 modified files
  while IFS= read -r file; do
    if [ -n "$file" ]; then
      UNCOMMITTED_MSG="$UNCOMMITTED_MSG\\n   $file"
    fi
  done < <(git status --porcelain 2>/dev/null | head -3 | sed 's/^/   /')
fi

# ============================================
# Phase 9: Get Last Commit
# ============================================

LAST_COMMIT=$(git log -1 --format="%h %s" 2>/dev/null | head -c 60 || echo "")
LAST_COMMIT_MSG=""
if [ -n "$LAST_COMMIT" ]; then
  LAST_COMMIT_MSG="\\n📌 최근: $LAST_COMMIT"
fi

# ============================================
# Output
# ============================================

cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\\n📁 $PROJECT_NAME ($BRANCH, $GIT_STATUS)$ISSUES_MSG$MRS_MSG$UNCOMMITTED_MSG$LAST_COMMIT_MSG\\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}
EOF
