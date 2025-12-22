---
description: Create and manage GitLab Labels
argument-hint: "create|list|delete [label-name] [--color #FF0000]"
allowed-tools: Bash(curl:*)
---

## GitLab Labels Management

이 명령어는 GitLab Labels를 생성하고 관리합니다.

### 주요 기능

1. **Label 생성**: 새 라벨 생성 (색상, 설명 포함)
2. **Label 수정**: 기존 라벨 업데이트
3. **Label 삭제**: 라벨 삭제
4. **Label 조회**: 라벨 목록 조회
5. **Scoped Labels**: 범위 라벨 생성 (priority::high, status::in-progress 등)

### 권장 라벨 체계

| 카테고리 | 라벨 예시 | 색상 |
|----------|-----------|------|
| Type | `bug`, `feature`, `enhancement`, `documentation` | Red, Green, Blue, Yellow |
| Priority | `priority::critical`, `priority::high`, `priority::medium`, `priority::low` | #FF0000, #FF6600, #FFCC00, #00FF00 |
| Status | `status::todo`, `status::in-progress`, `status::review`, `status::done` | #E0E0E0, #0066FF, #9933FF, #00CC00 |
| Phase | `phase::1-planning`, `phase::2-development`, `phase::3-testing` | Various |

### GitLab API 사용법

```bash
# Label 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "priority::high",
    "color": "#FF6600",
    "description": "High priority issue"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels"

# Label 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "new_name=priority::critical&color=#FF0000" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels/:label_id"

# Label 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels/:label_id"

# Label 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels"

# 여러 라벨 한번에 생성 (스크립트)
labels='[
  {"name": "bug", "color": "#FF0000", "description": "Bug report"},
  {"name": "feature", "color": "#00FF00", "description": "New feature"},
  {"name": "enhancement", "color": "#0066FF", "description": "Enhancement"}
]'
echo "$labels" | jq -c '.[]' | while read label; do
  curl --request POST \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    --header "Content-Type: application/json" \
    --data "$label" \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/labels"
done
```

## Your Task

사용자의 요청에 따라 GitLab Labels를 생성하거나 관리하세요.

1. 환경변수 확인
2. 라벨 생성/수정/삭제/조회 작업 실행
3. Scoped Labels 사용 시 `::` 구분자 형식 준수

$ARGUMENTS
