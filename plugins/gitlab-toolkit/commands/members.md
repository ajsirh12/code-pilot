---
description: Manage GitLab Project Members and Access Levels
argument-hint: "add|remove|list [username] [--level 30]"
allowed-tools: Bash(curl:*)
---

## GitLab Members Management

이 명령어는 GitLab 프로젝트 멤버를 관리합니다.

### Access Levels

| Level | 이름 | 권한 |
|-------|------|------|
| 0 | No access | 접근 불가 |
| 5 | Minimal access | 최소 접근 (그룹만) |
| 10 | Guest | 이슈 조회, 코멘트 |
| 20 | Reporter | 코드 조회, 이슈 관리 |
| 30 | Developer | 코드 푸시, MR 생성 |
| 40 | Maintainer | 브랜치 보호, 멤버 관리 |
| 50 | Owner | 프로젝트 삭제, 모든 권한 |

---

## GitLab API 사용법

```bash
# 멤버 추가
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "user_id": 123,
    "access_level": 30,
    "expires_at": "2025-12-31"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members"

# 멤버 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members"

# 상속된 멤버 포함 조회 (그룹에서 상속)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/all"

# 특정 멤버 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/:user_id"

# 멤버 권한 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "access_level": 40,
    "expires_at": "2026-06-30"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/:user_id"

# 멤버 제거
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/:user_id"

# 사용자 검색 (ID 찾기)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/users?search=username"
```

---

## 초대 링크 (Invite)

```bash
# 이메일로 초대
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "email": "newuser@example.com",
    "access_level": 30,
    "expires_at": "2025-12-31"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/invitations"

# 초대 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/invitations"
```

---

## Project Access Tokens (봇 계정용)

```bash
# Project Access Token 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "CI Bot",
    "scopes": ["api", "read_repository", "write_repository"],
    "access_level": 30,
    "expires_at": "2025-12-31"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens"

# Project Access Tokens 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens"

# Token 취소
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens/:token_id"
```

---

## 권장 멤버 구성 (프로덕션)

```
┌─────────────────────────────────────────────────┐
│                    Owner (50)                    │
│            - 프로젝트 설정 관리                  │
│            - 멤버 권한 관리                      │
├─────────────────────────────────────────────────┤
│               Maintainer (40)                    │
│            - Protected Branch 관리               │
│            - MR 머지                            │
│            - 배포 승인                          │
├─────────────────────────────────────────────────┤
│                Developer (30)                    │
│            - 코드 푸시                          │
│            - MR 생성                            │
│            - 이슈 관리                          │
├─────────────────────────────────────────────────┤
│                Reporter (20)                     │
│            - 코드 조회                          │
│            - 이슈 생성                          │
├─────────────────────────────────────────────────┤
│                  Guest (10)                      │
│            - 이슈 조회                          │
│            - 코멘트                             │
└─────────────────────────────────────────────────┘
```

---

## 만료일 관리

```bash
# 만료 예정 멤버 확인
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members" | \
  jq '.[] | select(.expires_at != null) | {username, expires_at}'

# 만료일 연장
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "expires_at=2026-12-31" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/:user_id"
```

## Your Task

사용자의 요청에 따라 GitLab 멤버를 관리하세요.

1. 환경변수 확인
2. 사용자 검색 (필요시)
3. 적절한 Access Level 설정
4. 멤버 추가/수정/제거

$ARGUMENTS
