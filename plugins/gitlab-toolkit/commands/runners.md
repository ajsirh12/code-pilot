---
description: Manage GitLab Runners for CI/CD pipelines
argument-hint: "list|register|pause [runner-id]"
allowed-tools: Bash(curl:*)
---

## GitLab Runners Management

이 명령어는 GitLab CI/CD Runner를 관리합니다.

### Runner 유형

| 유형 | 설명 |
|------|------|
| **Instance Runners** | GitLab 인스턴스 전체에서 공유 |
| **Group Runners** | 그룹 내 프로젝트에서 공유 |
| **Project Runners** | 특정 프로젝트 전용 |

### Runner 상태

| 상태 | 설명 |
|------|------|
| `online` | 활성 상태, 작업 수행 가능 |
| `offline` | 비활성 상태 |
| `stale` | 오랫동안 연결 없음 |
| `never_contacted` | 등록 후 연결 없음 |

---

## GitLab API 사용법

### Project Runners 관리

```bash
# 프로젝트에 사용 가능한 Runner 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/runners"

# 활성 Runner만
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/runners?status=online"

# Runner 상세 정보
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/runners/:runner_id"

# Project에 Runner 연결 (기존 Runner)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "runner_id=:runner_id" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/runners"

# Project에서 Runner 해제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/runners/:runner_id"
```

---

### Runner 등록 (Self-hosted)

```bash
# 1. Registration Token 조회 (Project)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" | jq '.runners_token'

# 2. Runner 등록 (deprecated - 새 방식 권장)
# GitLab 16.0+ 에서는 Runner Authentication Token 사용

# 새 Runner Authentication Token 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "runner_type": "project_type",
    "project_id": '$GITLAB_PROJECT_ID',
    "description": "Production Runner",
    "tag_list": ["docker", "linux", "production"],
    "run_untagged": false,
    "locked": true
  }' \
  "$GITLAB_URL/api/v4/user/runners"

# Docker로 Runner 실행
# docker run -d --name gitlab-runner \
#   -v /var/run/docker.sock:/var/run/docker.sock \
#   -v gitlab-runner-config:/etc/gitlab-runner \
#   gitlab/gitlab-runner:latest

# Runner 등록 (docker exec)
# docker exec -it gitlab-runner gitlab-runner register \
#   --url "https://gitlab.example.com" \
#   --token "RUNNER_TOKEN" \
#   --executor "docker" \
#   --docker-image "alpine:latest" \
#   --description "Docker Runner"
```

---

### Runner 설정 수정

```bash
# Runner 정보 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "description": "Updated Runner",
    "active": true,
    "paused": false,
    "tag_list": ["docker", "linux", "ci"],
    "run_untagged": false,
    "locked": true,
    "access_level": "not_protected",
    "maximum_timeout": 3600
  }' \
  "$GITLAB_URL/api/v4/runners/:runner_id"

# Runner 일시정지
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "paused=true" \
  "$GITLAB_URL/api/v4/runners/:runner_id"

# Runner 재활성화
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "paused=false" \
  "$GITLAB_URL/api/v4/runners/:runner_id"

# Runner 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/runners/:runner_id"
```

---

### Runner Jobs 조회

```bash
# Runner가 실행한 Jobs
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/runners/:runner_id/jobs"

# 실행 중인 Jobs만
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/runners/:runner_id/jobs?status=running"
```

---

## 프로덕션 Runner 구성 권장사항

### Tag 기반 Runner 분리

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  tags:
    - docker
    - linux
  script:
    - docker build -t app .

test:
  stage: test
  tags:
    - docker
    - linux
  script:
    - npm test

deploy_production:
  stage: deploy
  tags:
    - production  # 프로덕션 전용 Runner
    - privileged
  script:
    - ./deploy.sh
  environment:
    name: production
```

### Runner 태그 전략

| 태그 | 용도 |
|------|------|
| `docker` | Docker executor 사용 |
| `linux` / `windows` | OS 구분 |
| `production` | 프로덕션 배포 전용 |
| `privileged` | Docker-in-Docker 필요 |
| `gpu` | GPU 작업용 |
| `high-memory` | 메모리 집약 작업 |

---

## Runner 모니터링

```bash
# 전체 Runner 상태 요약
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/runners" | \
  jq 'group_by(.status) | map({status: .[0].status, count: length})'

# Offline Runner 찾기
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/runners?status=offline" | \
  jq '.[] | {id, description, contacted_at}'
```

## Your Task

사용자의 요청에 따라 GitLab Runner를 관리하세요.

1. 환경변수 확인
2. Runner 목록 확인
3. Runner 등록/수정/삭제
4. 태그 및 설정 관리

$ARGUMENTS
