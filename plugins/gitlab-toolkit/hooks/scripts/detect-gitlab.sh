#!/bin/bash
# GitLab Auto-Detection Hook
# Detects .git directory and GitLab remote, sets environment variables

set -euo pipefail

# Read input (required by hook protocol)
input=$(cat)

# Check if we're in a directory with .git
if [ ! -d ".git" ]; then
  echo '{"continue": true, "suppressOutput": true}'
  exit 0
fi

# Get remote URL
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
  echo '{"continue": true, "suppressOutput": true}'
  exit 0
fi

# Check if it's a GitLab URL (tepseg.com or gitlab.com)
if [[ ! "$REMOTE_URL" =~ gitlab ]]; then
  echo '{"continue": true, "suppressOutput": true}'
  exit 0
fi

# Extract project path from URL
# Handles: git@gitlab.tepseg.com:group/project.git
#          https://gitlab.tepseg.com/group/project.git
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

# Check if GITLAB_URL and GITLAB_TOKEN are set
if [ -z "${GITLAB_URL:-}" ] || [ -z "${GITLAB_TOKEN:-}" ]; then
  # Can't query API without credentials
  cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "GitLab 저장소 감지됨: $PROJECT_PATH\n\n환경변수가 설정되지 않았습니다:\nexport GITLAB_URL=\"https://gitlab.tepseg.com\"\nexport GITLAB_TOKEN=\"glpat-xxxx\""
}
EOF
  exit 0
fi

# URL encode the project path
ENCODED_PATH=$(echo "$PROJECT_PATH" | sed 's/\//%2F/g')

# Query GitLab API for project ID
PROJECT_INFO=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$ENCODED_PATH" 2>/dev/null || echo "")

if [ -z "$PROJECT_INFO" ] || [[ "$PROJECT_INFO" == *"error"* ]] || [[ "$PROJECT_INFO" == *"message"* ]]; then
  cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "GitLab 저장소 감지됨: $PROJECT_PATH\n\n⚠️ API 조회 실패 - 프로젝트 접근 권한을 확인하세요."
}
EOF
  exit 0
fi

# Extract project ID
PROJECT_ID=$(echo "$PROJECT_INFO" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
PROJECT_NAME=$(echo "$PROJECT_INFO" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$PROJECT_ID" ]; then
  echo '{"continue": true, "suppressOutput": true}'
  exit 0
fi

# Set environment variable if CLAUDE_ENV_FILE is available
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export GITLAB_PROJECT_ID=\"$PROJECT_ID\"" >> "$CLAUDE_ENV_FILE"
fi

# Output success message
cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "✅ GitLab 프로젝트 감지됨\n   이름: $PROJECT_NAME\n   경로: $PROJECT_PATH\n   ID: $PROJECT_ID\n\n   GITLAB_PROJECT_ID=$PROJECT_ID 자동 설정됨"
}
EOF
