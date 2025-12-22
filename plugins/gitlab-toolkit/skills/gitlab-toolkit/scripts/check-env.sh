#!/bin/bash
# GitLab 환경변수 및 연결 확인 스크립트
# Usage: ./check-env.sh

echo "=== GitLab Environment Check ==="

# 환경변수 확인
echo ""
echo "Environment Variables:"
echo "  GITLAB_URL: ${GITLAB_URL:-"(not set)"}"
echo "  GITLAB_TOKEN: ${GITLAB_TOKEN:+"****" + ${GITLAB_TOKEN: -4}}"
echo "  GITLAB_PROJECT_ID: ${GITLAB_PROJECT_ID:-"(not set)"}"

if [ -z "$GITLAB_URL" ] || [ -z "$GITLAB_TOKEN" ] || [ -z "$GITLAB_PROJECT_ID" ]; then
  echo ""
  echo "Error: Missing required environment variables"
  echo ""
  echo "Set them with:"
  echo "  export GITLAB_URL='https://gitlab.tepseg.com'"
  echo "  export GITLAB_TOKEN='glpat-xxxxxxxxxxxx'"
  echo "  export GITLAB_PROJECT_ID='206'"
  exit 1
fi

# API 연결 테스트
echo ""
echo "Testing API connection..."

# 사용자 정보
user_response=$(curl -s -w "\n%{http_code}" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/user")

http_code=$(echo "$user_response" | tail -n 1)
user_body=$(echo "$user_response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
  username=$(echo "$user_body" | jq -r '.username')
  name=$(echo "$user_body" | jq -r '.name')
  echo "  User: $name (@$username)"
else
  echo "  Error: Authentication failed (HTTP $http_code)"
  exit 1
fi

# 프로젝트 정보
project_response=$(curl -s -w "\n%{http_code}" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID")

http_code=$(echo "$project_response" | tail -n 1)
project_body=$(echo "$project_response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
  project_name=$(echo "$project_body" | jq -r '.name')
  project_path=$(echo "$project_body" | jq -r '.path_with_namespace')
  default_branch=$(echo "$project_body" | jq -r '.default_branch')
  visibility=$(echo "$project_body" | jq -r '.visibility')

  echo ""
  echo "Project:"
  echo "  Name: $project_name"
  echo "  Path: $project_path"
  echo "  Default Branch: $default_branch"
  echo "  Visibility: $visibility"
else
  echo "  Error: Project not found (HTTP $http_code)"
  exit 1
fi

echo ""
echo "=== All checks passed ==="
