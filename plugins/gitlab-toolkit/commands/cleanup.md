---
description: Cleanup GitLab Container Registry, old pipelines, and artifacts
argument-hint: "registry|pipelines|artifacts [--older-than 30d] [--keep 10]"
allowed-tools: Bash(curl:*)
---

## GitLab Cleanup Management

이 명령어는 GitLab 리소스 정리를 관리합니다.

### 정리 대상

1. **Container Registry**: 오래된 이미지/태그 삭제
2. **Pipelines**: 오래된 파이프라인 삭제
3. **Artifacts**: 만료된 아티팩트 정리
4. **Environments**: 중지된 환경 삭제
5. **Branches**: Merged/Stale 브랜치 정리

---

## Container Registry 정리

```bash
# Registry Repositories 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories"

# Repository의 태그 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id/tags"

# 특정 태그 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id/tags/:tag_name"

# 여러 태그 일괄 삭제 (정규식)
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name_regex_delete": ".*",
    "keep_n": 10,
    "older_than": "30d"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id/tags"

# 옵션 설명:
# - name_regex_delete: 삭제할 태그 패턴 (정규식)
# - name_regex_keep: 유지할 태그 패턴 (정규식)
# - keep_n: 최신 N개 유지
# - older_than: N일 이상 된 태그만 삭제 (예: "30d", "7d")

# 프로덕션 이미지는 유지하고 나머지 정리
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name_regex_delete": ".*",
    "name_regex_keep": "^v[0-9]+\\.[0-9]+\\.[0-9]+$|^latest$|^main$",
    "keep_n": 5,
    "older_than": "14d"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id/tags"

# 전체 Repository 삭제 (주의!)
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id"
```

---

## Pipeline 정리

```bash
# 오래된 Pipeline 목록 (30일 이상)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?updated_before=2024-01-01&per_page=100"

# 실패한 Pipeline만
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?status=failed&per_page=100"

# Pipeline 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id"

# 오래된 Pipeline 일괄 삭제 스크립트
delete_old_pipelines() {
  local days_old=${1:-30}
  local before_date=$(date -d "-$days_old days" +%Y-%m-%d)

  curl --silent --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?updated_before=$before_date&per_page=100" | \
    jq -r '.[].id' | while read pipeline_id; do
      echo "Deleting pipeline $pipeline_id"
      curl --request DELETE \
        --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/$pipeline_id"
    done
}
```

---

## Artifacts 정리

```bash
# Job Artifacts 정보
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/jobs/:job_id/artifacts"

# 특정 Job의 Artifacts 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/jobs/:job_id/artifacts"

# 프로젝트 전체 Artifacts 크기 확인
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID?statistics=true" | \
  jq '.statistics.job_artifacts_size'

# .gitlab-ci.yml에서 Artifacts 만료 설정
# artifacts:
#   paths:
#     - build/
#   expire_in: 1 week
```

---

## Environment 정리

```bash
# 중지된 Environment 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments?states=stopped"

# 중지된 Review Apps 일괄 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments/review_apps?before=2024-11-01&limit=100"

# 개별 Environment 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments/:environment_id"
```

---

## Branch 정리

```bash
# Merged 브랜치 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/branches?merged=true"

# Stale 브랜치 (마지막 커밋 90일 이상)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/branches" | \
  jq --arg date "$(date -d '-90 days' +%Y-%m-%dT%H:%M:%SZ)" \
  '.[] | select(.commit.committed_date < $date) | .name'

# 브랜치 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/branches/:branch_name"

# Protected 브랜치는 삭제 불가 (먼저 보호 해제 필요)
```

---

## 자동 정리 스크립트

```bash
#!/bin/bash
# cleanup.sh - GitLab 리소스 자동 정리

GITLAB_URL="${GITLAB_URL}"
GITLAB_TOKEN="${GITLAB_TOKEN}"
GITLAB_PROJECT_ID="${GITLAB_PROJECT_ID}"

echo "=== GitLab Cleanup Script ==="

# 1. Container Registry 정리 (30일 이상, 최신 10개 유지)
echo "Cleaning Container Registry..."
REPOS=$(curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories" | jq -r '.[].id')

for repo_id in $REPOS; do
  curl -X DELETE -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name_regex_delete":".*","name_regex_keep":"^v[0-9]+|^latest$","keep_n":10,"older_than":"30d"}' \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/$repo_id/tags"
done

# 2. 오래된 Pipeline 삭제 (60일 이상)
echo "Cleaning old Pipelines..."
BEFORE_DATE=$(date -d '-60 days' +%Y-%m-%d 2>/dev/null || date -v-60d +%Y-%m-%d)
PIPELINES=$(curl -s -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?updated_before=$BEFORE_DATE&per_page=100" | jq -r '.[].id')

for pipeline_id in $PIPELINES; do
  curl -X DELETE -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/$pipeline_id"
done

# 3. 중지된 Review Apps 삭제
echo "Cleaning stopped Review Apps..."
curl -X DELETE -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments/review_apps?limit=100"

echo "=== Cleanup Complete ==="
```

---

## Pipeline Schedule로 자동화

```bash
# 정리 스케줄 생성 (매주 일요일 새벽 3시)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "description": "Weekly Cleanup",
    "ref": "main",
    "cron": "0 3 * * 0",
    "cron_timezone": "Asia/Seoul",
    "active": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipeline_schedules"
```

## Your Task

사용자의 요청에 따라 GitLab 리소스를 정리하세요.

1. 환경변수 확인
2. 정리 대상 확인 (Registry, Pipelines, Artifacts 등)
3. 유지할 항목 확인 후 정리 실행
4. 정리 결과 보고

$ARGUMENTS
