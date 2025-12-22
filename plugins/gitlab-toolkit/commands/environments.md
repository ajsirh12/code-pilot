---
description: Manage GitLab Environments and Deployments
argument-hint: "create|stop|list [environment-name]"
allowed-tools: Bash(curl:*)
---

## GitLab Environments Management

이 명령어는 GitLab 배포 환경을 관리합니다.

### 주요 기능

1. **Environment 생성**: 배포 환경 정의
2. **Environment 수정**: 환경 설정 변경
3. **Environment 중지**: 환경 비활성화
4. **Environment 삭제**: 환경 제거
5. **Deployments 조회**: 배포 이력 확인

---

## 권장 환경 구성

```
┌──────────────────────────────────────────────────────────┐
│                     Environments                          │
├──────────────────────────────────────────────────────────┤
│  development    →  개발 환경 (자동 배포)                  │
│  staging        →  스테이징 환경 (자동 배포)              │
│  production     →  프로덕션 환경 (수동 승인 필요)         │
├──────────────────────────────────────────────────────────┤
│  review/*       →  MR별 리뷰 환경 (동적 생성/삭제)        │
└──────────────────────────────────────────────────────────┘
```

---

## GitLab API 사용법

### Environment 관리

```bash
# Environment 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "production",
    "external_url": "https://app.example.com"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments"

# Staging 환경
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "staging",
    "external_url": "https://staging.example.com"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments"

# Development 환경
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "development",
    "external_url": "https://dev.example.com"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments"

# Environment 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments"

# 활성 환경만 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments?states=available"

# Environment 상세 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments/:environment_id"

# Environment 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "production",
    "external_url": "https://new-url.example.com"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments/:environment_id"

# Environment 중지 (stop)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments/:environment_id/stop"

# Environment 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments/:environment_id"

# 중지된 환경 일괄 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/environments/review_apps?before=2024-01-01&limit=100"
```

---

### Deployments 관리

```bash
# Deployment 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deployments"

# 특정 환경의 Deployments
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deployments?environment=production"

# 성공한 Deployments만
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deployments?status=success"

# Deployment 상세 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deployments/:deployment_id"

# Deployment MR 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deployments/:deployment_id/merge_requests"
```

---

## .gitlab-ci.yml 환경 설정 예시

```yaml
stages:
  - build
  - test
  - deploy

# Development 자동 배포
deploy_development:
  stage: deploy
  script:
    - ./deploy.sh development
  environment:
    name: development
    url: https://dev.example.com
  only:
    - develop

# Staging 자동 배포
deploy_staging:
  stage: deploy
  script:
    - ./deploy.sh staging
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - main

# Production 수동 배포
deploy_production:
  stage: deploy
  script:
    - ./deploy.sh production
  environment:
    name: production
    url: https://app.example.com
  when: manual  # 수동 승인 필요
  only:
    - main

# Review Apps (MR별 동적 환경)
deploy_review:
  stage: deploy
  script:
    - ./deploy-review.sh
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: https://$CI_COMMIT_REF_SLUG.review.example.com
    on_stop: stop_review
  only:
    - merge_requests

stop_review:
  stage: deploy
  script:
    - ./stop-review.sh
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    action: stop
  when: manual
  only:
    - merge_requests
```

---

## Environment States

| 상태 | 설명 |
|------|------|
| `available` | 활성 상태 |
| `stopped` | 중지됨 |
| `stopping` | 중지 중 |

## Deployment Status

| 상태 | 설명 |
|------|------|
| `created` | 생성됨 |
| `running` | 실행 중 |
| `success` | 성공 |
| `failed` | 실패 |
| `canceled` | 취소됨 |

## Your Task

사용자의 요청에 따라 GitLab Environment를 관리하세요.

1. 환경변수 확인
2. 환경 생성/수정/삭제
3. 배포 이력 확인
4. 결과 보고

$ARGUMENTS
