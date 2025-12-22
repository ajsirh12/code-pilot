#!/bin/bash
# GitLab 리소스 정리 스크립트
# Usage: ./cleanup.sh

set -e

GITLAB_URL="${GITLAB_URL:-https://gitlab.tepseg.com}"
if [ -z "$GITLAB_TOKEN" ] || [ -z "$GITLAB_PROJECT_ID" ]; then
  echo "Error: GITLAB_TOKEN and GITLAB_PROJECT_ID must be set"
  exit 1
fi

echo "=== GitLab Cleanup Script ==="
echo "URL: $GITLAB_URL"
echo "Project ID: $GITLAB_PROJECT_ID"

# 1. Container Registry 정리 (30일 이상, 최신 10개 유지)
echo ""
echo "Cleaning Container Registry..."

REPOS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories" | jq -r '.[].id')

for repo_id in $REPOS; do
  curl -s --request DELETE \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    --header "Content-Type: application/json" \
    --data '{
      "name_regex_delete": ".*",
      "name_regex_keep": "^v[0-9]+|^latest$|^main$",
      "keep_n": 10,
      "older_than": "30d"
    }' \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/$repo_id/tags"
  echo "  Cleaned repository: $repo_id"
done

# 2. 오래된 Pipeline 삭제 (60일 이상)
echo ""
echo "Cleaning old Pipelines..."

# macOS와 Linux 호환
if date --version >/dev/null 2>&1; then
  BEFORE_DATE=$(date -d '-60 days' +%Y-%m-%d)
else
  BEFORE_DATE=$(date -v-60d +%Y-%m-%d)
fi

PIPELINES=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?updated_before=$BEFORE_DATE&per_page=100" | jq -r '.[].id')

count=0
for pipeline_id in $PIPELINES; do
  curl -s --request DELETE \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/$pipeline_id"
  ((count++))
done
echo "  Deleted $count pipelines"

# 3. 중지된 Review Apps 삭제
echo ""
echo "Cleaning stopped Review Apps..."

curl -s --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments/review_apps?limit=100"

echo "  Cleaned review apps"

echo ""
echo "=== Cleanup Complete ==="
