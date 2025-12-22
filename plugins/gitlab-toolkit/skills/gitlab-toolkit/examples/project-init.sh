#!/bin/bash
# GitLab 프로젝트 초기화 스크립트
# Usage: ./project-init.sh

set -e

# 환경변수 확인
GITLAB_URL="${GITLAB_URL:-https://gitlab.tepseg.com}"
if [ -z "$GITLAB_TOKEN" ] || [ -z "$GITLAB_PROJECT_ID" ]; then
  echo "Error: GITLAB_TOKEN and GITLAB_PROJECT_ID must be set"
  exit 1
fi

echo "=== GitLab Project Initialization ==="
echo "URL: $GITLAB_URL"
echo "Project ID: $GITLAB_PROJECT_ID"

# 1. Labels 생성
echo ""
echo "Creating labels..."

labels=(
  '{"name": "bug", "color": "#FF0000", "description": "Bug report"}'
  '{"name": "feature", "color": "#00FF00", "description": "New feature"}'
  '{"name": "enhancement", "color": "#0066FF", "description": "Enhancement"}'
  '{"name": "documentation", "color": "#FFCC00", "description": "Documentation"}'
  '{"name": "priority::critical", "color": "#FF0000", "description": "Critical priority"}'
  '{"name": "priority::high", "color": "#FF6600", "description": "High priority"}'
  '{"name": "priority::medium", "color": "#FFCC00", "description": "Medium priority"}'
  '{"name": "priority::low", "color": "#00FF00", "description": "Low priority"}'
  '{"name": "status::todo", "color": "#E0E0E0", "description": "To do"}'
  '{"name": "status::in-progress", "color": "#0066FF", "description": "In progress"}'
  '{"name": "status::review", "color": "#9933FF", "description": "In review"}'
  '{"name": "status::done", "color": "#00CC00", "description": "Done"}'
)

for label in "${labels[@]}"; do
  name=$(echo "$label" | jq -r '.name')
  curl -s --request POST \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    --header "Content-Type: application/json" \
    --data "$label" \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels" > /dev/null 2>&1 && \
    echo "  Created: $name" || echo "  Skipped: $name (already exists)"
done

# 2. Protected Branches
echo ""
echo "Protecting branches..."

curl -s --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "main",
    "push_access_level": 0,
    "merge_access_level": 40,
    "allow_force_push": false,
    "code_owner_approval_required": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_branches" > /dev/null 2>&1 && \
  echo "  Protected: main (no direct push)" || echo "  Skipped: main (already protected)"

# 3. Project Settings
echo ""
echo "Updating project settings..."

curl -s --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "only_allow_merge_if_pipeline_succeeds": true,
    "only_allow_merge_if_all_discussions_are_resolved": true,
    "remove_source_branch_after_merge": true,
    "squash_option": "default_on",
    "container_registry_enabled": true,
    "packages_enabled": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" > /dev/null

echo "  Updated project settings"

echo ""
echo "=== Initialization Complete ==="
