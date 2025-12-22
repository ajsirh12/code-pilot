---
description: Manage GitLab CI/CD Pipelines - run, cancel, retry, schedules
argument-hint: "run|cancel|retry|schedule [branch|pipeline-id]"
allowed-tools: Bash(curl:*)
---

## Context

- Current branch: !`git branch --show-current`
- Latest commit: !`git log --oneline -1`

## GitLab Pipeline Management

이 명령어는 GitLab CI/CD 파이프라인을 관리합니다.

### 주요 기능

1. **Pipeline 실행**: 수동으로 파이프라인 트리거
2. **Pipeline 취소**: 실행 중인 파이프라인 취소
3. **Pipeline 재시도**: 실패한 파이프라인 재시도
4. **Pipeline Schedules**: 예약 파이프라인 관리
5. **Pipeline 조회**: 파이프라인 상태 확인

---

## GitLab API 사용법

### Pipeline 실행/관리

```bash
# Pipeline 수동 실행
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "ref": "main",
    "variables": [
      {"key": "DEPLOY_ENV", "value": "staging"},
      {"key": "SKIP_TESTS", "value": "false"}
    ]
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipeline"

# Pipeline 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?per_page=20"

# 특정 브랜치 파이프라인
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines?ref=main&status=success"

# Pipeline 상세 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id"

# Pipeline 변수 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id/variables"

# Pipeline 취소
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id/cancel"

# Pipeline 재시도 (실패한 Jobs만)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id/retry"

# Pipeline 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id"
```

### Jobs 관리

```bash
# Pipeline의 Jobs 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id/jobs"

# Job 상세 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/jobs/:job_id"

# Job 로그 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/jobs/:job_id/trace"

# Job 취소
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/jobs/:job_id/cancel"

# Job 재시도
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/jobs/:job_id/retry"

# Manual Job 실행
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"job_variables_attributes": [{"key": "TEST_VAR", "value": "test"}]}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/jobs/:job_id/play"

# Job Artifacts 다운로드
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --output artifacts.zip \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/jobs/:job_id/artifacts"
```

---

### Pipeline Schedules (예약 파이프라인)

```bash
# Schedule 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "description": "Nightly Build",
    "ref": "main",
    "cron": "0 2 * * *",
    "cron_timezone": "Asia/Seoul",
    "active": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipeline_schedules"

# Weekly Security Scan
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "description": "Weekly Security Scan",
    "ref": "main",
    "cron": "0 3 * * 0",
    "cron_timezone": "Asia/Seoul",
    "active": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipeline_schedules"

# Schedule에 변수 추가
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "key": "SCHEDULED_BUILD",
    "value": "true"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipeline_schedules/:schedule_id/variables"

# Schedule 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipeline_schedules"

# Schedule 수동 실행
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipeline_schedules/:schedule_id/play"

# Schedule 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "active=false" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipeline_schedules/:schedule_id"

# Schedule 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipeline_schedules/:schedule_id"
```

---

## Cron 표현식 예시

| 표현식 | 설명 |
|--------|------|
| `0 2 * * *` | 매일 오전 2시 |
| `0 3 * * 0` | 매주 일요일 오전 3시 |
| `0 0 1 * *` | 매월 1일 자정 |
| `0 */6 * * *` | 6시간마다 |
| `0 9 * * 1-5` | 평일 오전 9시 |

---

## Pipeline Status

| 상태 | 설명 |
|------|------|
| `created` | 생성됨 |
| `waiting_for_resource` | 리소스 대기 |
| `preparing` | 준비 중 |
| `pending` | 대기 중 |
| `running` | 실행 중 |
| `success` | 성공 |
| `failed` | 실패 |
| `canceled` | 취소됨 |
| `skipped` | 스킵됨 |
| `manual` | 수동 실행 대기 |
| `scheduled` | 예약됨 |

## Your Task

사용자의 요청에 따라 GitLab Pipeline을 관리하세요.

1. 환경변수 확인
2. 파이프라인 실행/취소/재시도
3. 스케줄 생성/관리
4. 결과 보고

$ARGUMENTS
