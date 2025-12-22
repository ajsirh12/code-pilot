---
description: Configure GitLab Webhooks for automation (Slack, CI/CD, external services)
argument-hint: "create|list|delete [webhook-url]"
allowed-tools: Bash(curl:*)
---

## GitLab Webhooks Management

이 명령어는 GitLab Webhooks를 설정하고 관리합니다.

### 주요 기능

1. **Webhook 생성**: 외부 서비스 연동
2. **Webhook 수정**: 설정 변경
3. **Webhook 삭제**: 웹훅 제거
4. **Webhook 테스트**: 웹훅 테스트 트리거
5. **Webhook 조회**: 등록된 웹훅 목록

### 지원 이벤트

| 이벤트 | 설명 |
|--------|------|
| `push_events` | 코드 푸시 |
| `tag_push_events` | 태그 푸시 |
| `merge_requests_events` | MR 생성/수정/머지 |
| `issues_events` | 이슈 생성/수정 |
| `note_events` | 코멘트 |
| `job_events` | CI/CD 잡 |
| `pipeline_events` | 파이프라인 상태 변경 |
| `wiki_page_events` | 위키 페이지 변경 |
| `deployment_events` | 배포 이벤트 |
| `releases_events` | 릴리즈 생성 |

---

## GitLab API 사용법

```bash
# Webhook 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "url": "https://hooks.slack.com/services/xxx/yyy/zzz",
    "name": "Slack Notifications",
    "description": "Send notifications to #dev-channel",
    "push_events": true,
    "push_events_branch_filter": "main",
    "merge_requests_events": true,
    "pipeline_events": true,
    "issues_events": true,
    "note_events": true,
    "tag_push_events": true,
    "releases_events": true,
    "enable_ssl_verification": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/hooks"

# Webhook with Secret Token (보안 강화)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "url": "https://your-server.com/webhook",
    "token": "your-secret-token",
    "push_events": true,
    "enable_ssl_verification": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/hooks"

# Webhook 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/hooks"

# Webhook 상세 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/hooks/:hook_id"

# Webhook 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "url": "https://new-url.com/webhook",
    "push_events": false
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/hooks/:hook_id"

# Webhook 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/hooks/:hook_id"

# Webhook 테스트 (특정 이벤트)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/hooks/:hook_id/test/push_events"
```

---

## 일반적인 Webhook 설정 예시

### Slack 연동

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "url": "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX",
    "name": "Slack #gitlab-notifications",
    "push_events": true,
    "push_events_branch_filter": "main,develop",
    "merge_requests_events": true,
    "pipeline_events": true,
    "note_events": false,
    "enable_ssl_verification": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/hooks"
```

### Discord 연동

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "url": "https://discord.com/api/webhooks/xxx/yyy/gitlab",
    "name": "Discord Notifications",
    "push_events": true,
    "merge_requests_events": true,
    "pipeline_events": true,
    "enable_ssl_verification": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/hooks"
```

### CI/CD Trigger (외부 시스템에서 파이프라인 실행)

```bash
# Pipeline Trigger Token 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"description": "External CI Trigger"}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/triggers"

# 외부에서 파이프라인 트리거
curl --request POST \
  --form "token=TOKEN" \
  --form "ref=main" \
  --form "variables[DEPLOY_ENV]=production" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/trigger/pipeline"
```

---

## Branch Filter

특정 브랜치에서만 이벤트 발생:

```bash
# 단일 브랜치
"push_events_branch_filter": "main"

# 여러 브랜치
"push_events_branch_filter": "main,develop,release/*"

# 와일드카드
"push_events_branch_filter": "feature/*"
```

## Your Task

사용자의 요청에 따라 GitLab Webhook을 설정하세요.

1. 환경변수 확인
2. 연동할 서비스 URL 확인
3. 필요한 이벤트 선택
4. Webhook 생성 및 테스트

$ARGUMENTS
