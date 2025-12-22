---
description: Manage Deploy Keys for CI/CD SSH access to repositories
argument-hint: "list|add|remove|enable [key-title]"
allowed-tools: Bash(curl:*), Bash(ssh-keygen:*)
---

## Context

- Current branch: !`git branch --show-current`
- Project: !`basename $(git rev-parse --show-toplevel)`

## GitLab Deploy Keys Management

이 명령어는 GitLab Deploy Keys를 관리합니다. Deploy Keys는 CI/CD 파이프라인에서 다른 저장소에 접근할 때 사용하는 SSH 키입니다.

### Deploy Keys vs SSH Keys

| 구분 | Deploy Keys | SSH Keys |
|------|-------------|----------|
| 범위 | 특정 프로젝트 | 사용자 전체 |
| 용도 | CI/CD, 자동화 | 개인 접근 |
| 공유 | 프로젝트 간 공유 가능 | 사용자 고유 |
| 권한 | Read-only 또는 Read-write | 사용자 권한 따름 |

---

## Deploy Keys API

### Deploy Keys 조회

```bash
# 프로젝트의 Deploy Keys 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_keys"

# 특정 Deploy Key 상세
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_keys/:key_id"

# 모든 Deploy Keys (Admin only)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/deploy_keys"
```

### Deploy Key 생성

```bash
# Read-only Deploy Key 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "CI/CD Read Access",
    "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... deploy@ci",
    "can_push": false
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_keys"

# Read-write Deploy Key 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "CI/CD Write Access",
    "key": "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... deploy@ci",
    "can_push": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_keys"
```

### Deploy Key 수정

```bash
# Deploy Key 권한 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "Updated Deploy Key",
    "can_push": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_keys/:key_id"
```

### Deploy Key 삭제

```bash
# Deploy Key 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_keys/:key_id"
```

---

## 프로젝트 간 Deploy Key 공유

### 기존 Deploy Key 활성화

```bash
# 다른 프로젝트의 Deploy Key를 현재 프로젝트에서 활성화
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_keys/:key_id/enable"
```

### 공유 키 사용 시나리오

```
Project A: Deploy Key 생성 (원본)
    ↓
Project B: 같은 Key를 enable (공유)
    ↓
Project C: 같은 Key를 enable (공유)
```

---

## SSH 키 생성 가이드

### Ed25519 키 생성 (권장)

```bash
# Ed25519 키 생성 (더 안전, 더 짧음)
ssh-keygen -t ed25519 -C "deploy@project-name" -f deploy_key -N ""

# 생성된 키 확인
cat deploy_key.pub
```

### RSA 키 생성 (레거시 호환)

```bash
# RSA 4096 키 생성
ssh-keygen -t rsa -b 4096 -C "deploy@project-name" -f deploy_key_rsa -N ""
```

---

## CI/CD에서 Deploy Key 사용

### .gitlab-ci.yml 예시

```yaml
variables:
  GIT_STRATEGY: clone
  GIT_SUBMODULE_STRATEGY: recursive

before_script:
  # SSH 에이전트 설정
  - eval $(ssh-agent -s)
  - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
  - mkdir -p ~/.ssh
  - chmod 700 ~/.ssh
  - ssh-keyscan gitlab.example.com >> ~/.ssh/known_hosts
  - chmod 644 ~/.ssh/known_hosts

deploy:
  script:
    # Deploy Key로 다른 저장소 클론
    - git clone git@gitlab.example.com:group/other-repo.git
    # 또는 서브모듈 업데이트
    - git submodule update --init --recursive
```

### GitLab CI 변수 설정

```bash
# SSH_PRIVATE_KEY 변수 생성 (Protected, Masked)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "key": "SSH_PRIVATE_KEY",
    "value": "'"$(cat deploy_key)"'",
    "protected": true,
    "masked": false,
    "variable_type": "file"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables"
```

---

## Deploy Key 모니터링

```bash
# 프로젝트의 Deploy Keys 요약
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_keys" | \
  jq '.[] | {id, title, can_push, created_at}'

# Push 권한이 있는 키만 확인
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_keys" | \
  jq '[.[] | select(.can_push == true)] | length'
```

---

## 보안 권장사항

| 항목 | 권장사항 |
|------|----------|
| 키 타입 | Ed25519 사용 권장 |
| 권한 | 최소 권한 원칙 (read-only 우선) |
| 키 분리 | 환경별 (dev/staging/prod) 키 분리 |
| 만료 | 정기적인 키 로테이션 |
| 저장 | GitLab CI 변수에 Protected로 저장 |

---

## Deploy Tokens vs Deploy Keys

| 구분 | Deploy Keys | Deploy Tokens |
|------|-------------|---------------|
| 인증 방식 | SSH | HTTPS |
| 용도 | Git SSH 접근 | Git HTTPS, Registry 접근 |
| Container Registry | 불가 | 가능 |
| Package Registry | 불가 | 가능 |

## Your Task

사용자의 요청에 따라 Deploy Keys를 관리하세요.

1. 환경변수 확인
2. Deploy Keys 목록 조회
3. Deploy Key 생성/삭제
4. 프로젝트 간 키 공유 설정
5. CI/CD 변수 연동

$ARGUMENTS
