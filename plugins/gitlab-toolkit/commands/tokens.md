---
description: Manage Project and Group Access Tokens for API and Git access
argument-hint: "list|create|revoke [token-name] [scopes]"
allowed-tools: Bash(curl:*)
---

## Context

- Current branch: !`git branch --show-current`
- Project: !`basename $(git rev-parse --show-toplevel)`

## GitLab Access Tokens Management

이 명령어는 GitLab Project Access Tokens과 Group Access Tokens을 관리합니다.

### Token 유형

| 유형 | 범위 | 용도 |
|------|------|------|
| **Personal Access Token** | 사용자 전체 | 개인 API 접근 |
| **Project Access Token** | 특정 프로젝트 | 프로젝트 자동화 |
| **Group Access Token** | 그룹 전체 | 그룹 수준 자동화 |
| **Deploy Token** | 프로젝트/그룹 | Registry 접근 전용 |

---

## Project Access Tokens API

### Token 조회

```bash
# 프로젝트의 Access Tokens 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens"

# 특정 Token 상세
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens/:token_id"
```

### Token 생성

```bash
# Read-only Token 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "CI Read Token",
    "scopes": ["read_api", "read_repository"],
    "access_level": 20,
    "expires_at": "2025-12-31"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens"

# Full Access Token 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "CI Full Access",
    "scopes": ["api", "read_repository", "write_repository", "read_registry", "write_registry"],
    "access_level": 40,
    "expires_at": "2025-12-31"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens"

# Registry 전용 Token
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Registry Access",
    "scopes": ["read_registry", "write_registry"],
    "access_level": 30,
    "expires_at": "2025-06-30"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens"
```

### Token 갱신 (Rotate)

```bash
# Token 갱신 (새 토큰 발급, 기존 토큰 무효화)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "expires_at": "2026-01-01"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens/:token_id/rotate"
```

### Token 취소

```bash
# Token 취소 (삭제)
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens/:token_id"
```

---

## Group Access Tokens API

### Group Token 조회

```bash
# 그룹의 Access Tokens 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups/:group_id/access_tokens"

# 특정 Token 상세
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups/:group_id/access_tokens/:token_id"
```

### Group Token 생성

```bash
# 그룹 Token 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Group CI Token",
    "scopes": ["api", "read_repository"],
    "access_level": 40,
    "expires_at": "2025-12-31"
  }' \
  "$GITLAB_URL/api/v4/groups/:group_id/access_tokens"
```

### Group Token 취소

```bash
# 그룹 Token 취소
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups/:group_id/access_tokens/:token_id"
```

---

## Deploy Tokens API

### Deploy Token 조회

```bash
# 프로젝트 Deploy Tokens
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_tokens"

# 그룹 Deploy Tokens
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups/:group_id/deploy_tokens"
```

### Deploy Token 생성

```bash
# 프로젝트 Deploy Token
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Docker Registry Token",
    "username": "docker-pull",
    "expires_at": "2025-12-31",
    "scopes": ["read_registry"]
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_tokens"

# Package Registry 접근 Token
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "npm Registry Token",
    "username": "npm-deploy",
    "expires_at": "2025-12-31",
    "scopes": ["read_package_registry", "write_package_registry"]
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_tokens"
```

### Deploy Token 삭제

```bash
# 프로젝트 Deploy Token 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_tokens/:token_id"
```

---

## Token Scopes

### Access Token Scopes

| Scope | 권한 |
|-------|------|
| `api` | 전체 API 접근 |
| `read_api` | 읽기 전용 API |
| `read_repository` | Git clone (HTTPS) |
| `write_repository` | Git push |
| `read_registry` | Container Registry pull |
| `write_registry` | Container Registry push |
| `create_runner` | Runner 등록 |
| `ai_features` | AI 기능 접근 |

### Deploy Token Scopes

| Scope | 권한 |
|-------|------|
| `read_repository` | Git clone |
| `read_registry` | Container Registry pull |
| `write_registry` | Container Registry push |
| `read_package_registry` | Package Registry read |
| `write_package_registry` | Package Registry write |

---

## Access Levels

| Level | 이름 | 숫자값 |
|-------|------|--------|
| Guest | Guest | 10 |
| Reporter | Reporter | 20 |
| Developer | Developer | 30 |
| Maintainer | Maintainer | 40 |
| Owner | Owner | 50 |

---

## CI/CD에서 Token 사용

### .gitlab-ci.yml 예시

```yaml
variables:
  # 프로젝트 Token을 CI 변수로 사용
  GIT_CREDENTIALS: "https://oauth2:${PROJECT_ACCESS_TOKEN}@gitlab.example.com"

build:
  script:
    # Token으로 다른 저장소 클론
    - git clone https://oauth2:${PROJECT_ACCESS_TOKEN}@gitlab.example.com/group/other-repo.git

deploy:
  script:
    # Registry 로그인
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

---

## Token 모니터링

```bash
# 만료 예정 Token 확인 (30일 이내)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens" | \
  jq --arg date "$(date -d '+30 days' +%Y-%m-%d)" \
    '.[] | select(.expires_at != null and .expires_at < $date) | {name, expires_at}'

# Active Token 수
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens" | \
  jq '[.[] | select(.active == true)] | length'

# Token 권한 요약
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens" | \
  jq '.[] | {name, scopes, access_level, expires_at}'
```

---

## 보안 권장사항

| 항목 | 권장사항 |
|------|----------|
| 만료일 | 반드시 설정 (최대 1년 권장) |
| 권한 | 최소 권한 원칙 적용 |
| 로테이션 | 정기적 갱신 (분기별 권장) |
| 저장 | GitLab CI 변수에 Protected, Masked로 저장 |
| 명명 | 용도 명확히 표시 (e.g., "CI-Deploy-Prod") |

## Your Task

사용자의 요청에 따라 Access Tokens을 관리하세요.

1. 환경변수 확인
2. Token 목록 조회
3. Token 생성/갱신/삭제
4. 만료 예정 Token 확인
5. 결과 보고

$ARGUMENTS
