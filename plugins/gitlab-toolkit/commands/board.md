---
description: Configure GitLab Issue Boards
argument-hint: "create|list|add-list [board-name]"
allowed-tools: Bash(curl:*)
---

## GitLab Issue Board Management

이 명령어는 GitLab Issue Board를 생성하고 관리합니다.

### 주요 기능

1. **Board 생성**: 새 이슈 보드 생성
2. **Board List 추가**: 보드에 컬럼(리스트) 추가
3. **Board 수정**: 보드 설정 변경
4. **Board 조회**: 보드 목록 조회

### 권장 Board 구조

```
┌─────────────┬─────────────┬─────────────┬─────────────┬─────────────┐
│    Open     │   To Do     │ In Progress │   Review    │    Done     │
├─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│ (backlog)   │ (planned)   │ (working)   │ (pr/qa)     │ (completed) │
│             │             │             │             │             │
│ - Issue 1   │ - Issue 3   │ - Issue 5   │ - Issue 7   │ - Issue 9   │
│ - Issue 2   │ - Issue 4   │ - Issue 6   │ - Issue 8   │ - Issue 10  │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────────┘
```

### GitLab API 사용법

```bash
# Board 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Development Board"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards"

# Board에 Label List 추가
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "label_id": 123
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards/:board_id/lists"

# Board에 Milestone List 추가
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "milestone_id": 1
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards/:board_id/lists"

# Board에 Assignee List 추가 (Premium)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "assignee_id": 1
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards/:board_id/lists"

# List 순서 변경
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "position=2" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards/:board_id/lists/:list_id"

# List 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards/:board_id/lists/:list_id"

# Board 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards"

# Board 상세 조회 (Lists 포함)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards/:board_id/lists"

# Board 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards/:board_id"
```

### Scoped Board 설정 (Premium)

```bash
# Milestone 범위 Board
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "milestone_id": 1,
    "weight": 2,
    "labels": "priority::high"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards/:board_id"
```

### 보드 자동화 스크립트

```bash
# 표준 Kanban 보드 생성 스크립트
create_kanban_board() {
  # 1. 필요한 라벨 생성
  labels=("status::todo" "status::in-progress" "status::review" "status::done")
  colors=("#428BCA" "#F0AD4E" "#9B59B6" "#5CB85C")

  for i in "${!labels[@]}"; do
    curl --request POST \
      --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
      --header "Content-Type: application/json" \
      --data "{\"name\": \"${labels[$i]}\", \"color\": \"${colors[$i]}\"}" \
      "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels"
  done

  # 2. 보드 생성
  board_id=$(curl --request POST \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    --header "Content-Type: application/json" \
    --data '{"name": "Kanban Board"}' \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards" | jq -r '.id')

  # 3. 각 라벨에 대한 리스트 생성
  for label in "${labels[@]}"; do
    label_id=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
      "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels?search=$label" | jq -r '.[0].id')

    curl --request POST \
      --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
      --header "Content-Type: application/json" \
      --data "{\"label_id\": $label_id}" \
      "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/boards/$board_id/lists"
  done
}
```

## Your Task

사용자의 요청에 따라 GitLab Issue Board를 설정하세요.

1. 환경변수 확인
2. 필요한 라벨이 있는지 확인 (없으면 생성)
3. Board 생성 및 List 추가
4. 결과 확인 및 보고

$ARGUMENTS
