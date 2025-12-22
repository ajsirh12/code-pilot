---
description: Create and manage GitLab Milestones
argument-hint: "create|close|list [title] [--due-date YYYY-MM-DD]"
allowed-tools: Bash(curl:*)
---

## GitLab Milestone Management

이 명령어는 GitLab Milestone을 생성하고 관리합니다.

### 주요 기능

1. **Milestone 생성**: 새 마일스톤 생성
2. **Milestone 수정**: 기존 마일스톤 업데이트
3. **Milestone 닫기**: 마일스톤 완료 처리
4. **Milestone 조회**: 마일스톤 목록 조회

### GitLab API 사용법

```bash
# Milestone 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "Phase 1 - MVP",
    "description": "Phase 1 목표:\n- 기본 기능 구현\n- 테스트 완료",
    "due_date": "2025-01-31",
    "start_date": "2025-01-01"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/milestones"

# Milestone 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "state_event=close" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/milestones/:milestone_id"

# Milestone 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/milestones?state=active"

# Milestone 상세 조회 (이슈/MR 포함)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/milestones/:milestone_id/issues"

# Milestone 머지 리퀘스트 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/milestones/:milestone_id/merge_requests"
```

## Your Task

사용자의 요청에 따라 GitLab Milestone을 생성하거나 관리하세요.

1. 환경변수 확인 (GITLAB_URL, GITLAB_TOKEN, GITLAB_PROJECT_ID)
2. 마일스톤 생성/수정/조회 작업 실행
3. 결과를 사용자에게 보고

$ARGUMENTS
