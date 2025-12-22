---
description: View security vulnerabilities and dependency scanning reports
argument-hint: "vulnerabilities|dependencies|scan [severity|package-name]"
allowed-tools: Bash(curl:*)
---

## Context

- Current branch: !`git branch --show-current`
- Latest commit: !`git log --oneline -1`

## GitLab Security Management

이 명령어는 GitLab 보안 스캐닝 결과와 취약점을 조회합니다.

### 지원 스캐너

| 스캐너 | 설명 |
|--------|------|
| **SAST** | 소스 코드 정적 분석 |
| **DAST** | 동적 애플리케이션 보안 테스트 |
| **Dependency Scanning** | 의존성 취약점 |
| **Container Scanning** | Docker 이미지 취약점 |
| **Secret Detection** | 시크릿/키 노출 탐지 |
| **License Compliance** | 라이센스 호환성 |

---

## Vulnerabilities API

### 취약점 조회

```bash
# 프로젝트 취약점 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities"

# 심각도별 필터링
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities?severity=critical"

# 상태별 필터링
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities?state=detected"

# 스캐너별 필터링
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities?scanner=dependency_scanning"

# 복합 필터링
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities?severity=critical,high&state=detected"
```

### 특정 취약점 상세

```bash
# 취약점 상세 정보
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities/:vulnerability_id"

# 취약점 발견 정보 (findings)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerability_findings"
```

### 취약점 상태 변경

```bash
# 취약점 확인 (Confirm)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities/:vulnerability_id/confirm"

# 취약점 해결 (Resolve)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities/:vulnerability_id/resolve"

# 취약점 무시 (Dismiss)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities/:vulnerability_id/dismiss"

# 취약점 재개 (Revert)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities/:vulnerability_id/revert"
```

---

## Dependency List API

### 의존성 조회

```bash
# 프로젝트 의존성 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/dependencies"

# 취약한 의존성만
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/dependencies?filter=vulnerable"

# 패키지 관리자별 필터링
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/dependencies?package_manager=npm"
```

---

## Security Dashboard

### 취약점 요약

```bash
# 취약점 통계
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerability_findings/count" | \
  jq '.'

# 심각도별 카운트 (jq로 집계)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities" | \
  jq 'group_by(.severity) | map({severity: .[0].severity, count: length})'

# 상태별 카운트
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities" | \
  jq 'group_by(.state) | map({state: .[0].state, count: length})'
```

---

## Pipeline Security Reports

### Security Report 조회

```bash
# Pipeline의 Security Reports
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id/security"

# SAST Report
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id/jobs" | \
  jq '.[] | select(.name | contains("sast"))'

# Dependency Scanning Report
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/pipelines/:pipeline_id/jobs" | \
  jq '.[] | select(.name | contains("dependency"))'
```

---

## CI/CD Security Scanning 설정

### .gitlab-ci.yml 예시

```yaml
include:
  # Security 스캐닝 템플릿 포함
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml

stages:
  - build
  - test
  - security

variables:
  # SAST 설정
  SAST_EXCLUDED_PATHS: "node_modules, vendor, tests"

  # Dependency Scanning 설정
  DS_EXCLUDED_ANALYZERS: "gemnasium-python"

  # Container Scanning 설정
  CS_IMAGE: "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA"

# Custom Security Job
security-audit:
  stage: security
  script:
    - npm audit --json > npm-audit.json || true
    - pip-audit --format json > pip-audit.json || true
  artifacts:
    reports:
      dependency_scanning: npm-audit.json
```

---

## Severity Levels

| 심각도 | 설명 | 대응 |
|--------|------|------|
| `critical` | 심각한 취약점 | 즉시 수정 필요 |
| `high` | 높은 위험 | 빠른 수정 권장 |
| `medium` | 중간 위험 | 계획적 수정 |
| `low` | 낮은 위험 | 검토 필요 |
| `info` | 정보성 | 참고 |
| `unknown` | 분류 불가 | 수동 검토 |

---

## Vulnerability States

| 상태 | 설명 |
|------|------|
| `detected` | 새로 발견됨 |
| `confirmed` | 확인됨 |
| `resolved` | 해결됨 |
| `dismissed` | 무시됨 (거짓 양성 등) |

---

## 유용한 조합 명령

```bash
# Critical/High 취약점만 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities?severity=critical,high&state=detected" | \
  jq '.[] | {id, title, severity, location: .location.file}'

# npm 패키지 취약점 확인
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/dependencies?package_manager=npm&filter=vulnerable" | \
  jq '.[] | {name, version, vulnerabilities: .vulnerabilities[].severity}'

# 최근 7일 내 발견된 취약점
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities" | \
  jq --arg date "$(date -d '-7 days' +%Y-%m-%dT%H:%M:%SZ)" \
    '[.[] | select(.detected_at > $date)] | length'

# 취약점 리포트 CSV 형식
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/vulnerabilities?severity=critical,high" | \
  jq -r '["ID","Title","Severity","State","File"], (.[] | [.id, .title, .severity, .state, .location.file // "N/A"]) | @csv'
```

---

## 보안 정책

```bash
# Security Policy 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/security_policies"
```

---

## 권장 Workflow

1. **발견** - CI/CD 파이프라인에서 자동 스캔
2. **분류** - 심각도별 우선순위 지정
3. **확인** - 실제 취약점인지 검토
4. **수정** - 패키지 업데이트 또는 코드 수정
5. **해결** - 취약점 상태 resolved로 변경
6. **모니터링** - 새로운 취약점 지속 감시

## Your Task

사용자의 요청에 따라 보안 취약점과 의존성을 조회하세요.

1. 환경변수 확인
2. 취약점 목록 조회 (필터링 적용)
3. 의존성 분석
4. 보안 리포트 요약
5. 권장 조치 제안

$ARGUMENTS
