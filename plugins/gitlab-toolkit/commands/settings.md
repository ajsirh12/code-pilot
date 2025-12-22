---
description: Configure GitLab Project Settings - visibility, features, merge settings
argument-hint: "show|update [--visibility private] [--merge-method merge]"
allowed-tools: Bash(curl:*)
---

## GitLab Project Settings Management

이 명령어는 GitLab 프로젝트 설정을 관리합니다.

### 주요 설정 카테고리

1. **Visibility**: 프로젝트 공개 범위
2. **Features**: 기능 활성화/비활성화
3. **Merge Settings**: MR 머지 설정
4. **Repository Settings**: 저장소 설정
5. **CI/CD Settings**: CI/CD 설정

---

## Visibility Settings

```bash
# 프로젝트 가시성 변경
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "visibility": "private"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"

# visibility 옵션:
# - private: 멤버만 접근
# - internal: 로그인한 사용자
# - public: 모든 사람
```

---

## Feature Settings

```bash
# 기능 활성화/비활성화
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "issues_enabled": true,
    "merge_requests_enabled": true,
    "wiki_enabled": true,
    "snippets_enabled": true,
    "container_registry_enabled": true,
    "packages_enabled": true,
    "builds_enabled": true,
    "pages_enabled": false,
    "analytics_enabled": true,
    "security_and_compliance_enabled": true,
    "requirements_enabled": false,
    "monitor_enabled": true,
    "releases_enabled": true,
    "environments_enabled": true,
    "feature_flags_enabled": false,
    "infrastructure_enabled": false
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"
```

---

## Merge Request Settings (프로덕션 필수!)

```bash
# MR 설정 (프로덕션 권장)
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "merge_method": "merge",
    "squash_option": "default_on",
    "merge_pipelines_enabled": true,
    "merge_trains_enabled": false,
    "only_allow_merge_if_pipeline_succeeds": true,
    "only_allow_merge_if_all_discussions_are_resolved": true,
    "remove_source_branch_after_merge": true,
    "printing_merge_request_link_enabled": true,
    "suggestion_commit_message": "Apply suggestion from code review",
    "merge_commit_template": "Merge branch '\''%{source_branch}'\'' into '\''%{target_branch}'\''\n\n%{title}\n\n%{description}",
    "squash_commit_template": "%{title}"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"

# merge_method 옵션:
# - merge: Merge commit 생성
# - rebase_merge: Rebase 후 merge commit
# - ff: Fast-forward merge (선형 히스토리)

# squash_option 옵션:
# - never: Squash 비활성화
# - always: 항상 Squash
# - default_on: 기본 활성화
# - default_off: 기본 비활성화
```

---

## Repository Settings

```bash
# 기본 브랜치 변경
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "default_branch=main" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"

# Repository 크기 제한 (MB)
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "repository_size_limit=500" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"

# LFS 활성화
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "lfs_enabled=true" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"
```

---

## CI/CD Settings

```bash
# CI/CD 설정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "ci_config_path": ".gitlab-ci.yml",
    "build_timeout": 3600,
    "auto_cancel_pending_pipelines": "enabled",
    "build_coverage_regex": "Coverage: (\\d+\\.\\d+)%",
    "public_builds": false,
    "auto_devops_enabled": false,
    "keep_latest_artifact": true,
    "restrict_user_defined_variables": false
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"
```

---

## Issue & MR Templates

```bash
# 기본 이슈 템플릿 설정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "issues_template=bug_report" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"

# 기본 MR 템플릿 설정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "merge_requests_template=default" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"
```

---

## 프로덕션 권장 설정 전체

```bash
# 프로덕션 프로젝트 설정 (한번에)
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "visibility": "private",
    "default_branch": "main",

    "issues_enabled": true,
    "merge_requests_enabled": true,
    "wiki_enabled": true,
    "container_registry_enabled": true,
    "packages_enabled": true,
    "builds_enabled": true,

    "merge_method": "merge",
    "squash_option": "default_on",
    "only_allow_merge_if_pipeline_succeeds": true,
    "only_allow_merge_if_all_discussions_are_resolved": true,
    "remove_source_branch_after_merge": true,

    "auto_cancel_pending_pipelines": "enabled",
    "keep_latest_artifact": true,
    "public_builds": false,
    "auto_devops_enabled": false,

    "lfs_enabled": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"
```

---

## 프로젝트 정보 조회

```bash
# 전체 프로젝트 정보
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"

# 통계 포함
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID?statistics=true"
```

## Your Task

사용자의 요청에 따라 GitLab 프로젝트 설정을 구성하세요.

1. 환경변수 확인
2. 현재 설정 확인
3. 요청된 설정 적용
4. 결과 확인 및 보고

$ARGUMENTS
