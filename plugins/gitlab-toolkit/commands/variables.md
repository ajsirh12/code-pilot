---
description: Manage GitLab CI/CD Variables (secrets, environment variables)
argument-hint: "create|update|delete KEY [VALUE] [--protected] [--masked]"
allowed-tools: Bash(curl:*)
---

## GitLab CI/CD Variables Management

이 명령어는 GitLab CI/CD 변수를 관리합니다.

### 주요 기능

1. **Variable 생성**: CI/CD 변수 추가
2. **Variable 수정**: 기존 변수 업데이트
3. **Variable 삭제**: 변수 제거
4. **Variable 조회**: 변수 목록 확인

### Variable 유형

| 유형 | 설명 |
|------|------|
| `env_var` | 환경 변수 (기본값) |
| `file` | 파일로 저장 (인증서, 키 등) |

### Variable 옵션

| 옵션 | 설명 |
|------|------|
| `protected` | Protected 브랜치에서만 사용 |
| `masked` | 로그에서 마스킹 (****) |
| `raw` | 변수 확장 비활성화 |
| `environment_scope` | 특정 환경에서만 사용 |

---

## GitLab API 사용법

```bash
# Variable 생성 (기본)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "key": "DATABASE_URL",
    "value": "postgres://user:pass@host:5432/db",
    "protected": true,
    "masked": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables"

# Variable 생성 (환경별)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "key": "API_KEY",
    "value": "prod-api-key-xxx",
    "protected": true,
    "masked": true,
    "environment_scope": "production"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables"

# Staging 환경용 변수
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "key": "API_KEY",
    "value": "staging-api-key-xxx",
    "protected": false,
    "masked": true,
    "environment_scope": "staging"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables"

# File 타입 Variable (인증서, 키 파일)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "key": "SSH_PRIVATE_KEY",
    "value": "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----",
    "variable_type": "file",
    "protected": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables"

# Variable 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables"

# Variable 상세 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables/DATABASE_URL"

# 환경별 Variable 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables/API_KEY?filter%5Benvironment_scope%5D=production"

# Variable 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "value": "new-value",
    "protected": true,
    "masked": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables/DATABASE_URL"

# Variable 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/variables/OLD_VARIABLE"
```

---

## 프로덕션 권장 변수 설정

```bash
# 1. Database
DATABASE_URL (protected, masked)
REDIS_URL (protected, masked)

# 2. API Keys
API_KEY (protected, masked, environment_scope별)
JWT_SECRET (protected, masked)

# 3. Cloud Credentials
AWS_ACCESS_KEY_ID (protected, masked)
AWS_SECRET_ACCESS_KEY (protected, masked)
GOOGLE_APPLICATION_CREDENTIALS (file, protected)

# 4. Container Registry
CI_REGISTRY_USER (protected)
CI_REGISTRY_PASSWORD (protected, masked)

# 5. Deployment
KUBECONFIG (file, protected)
SSH_PRIVATE_KEY (file, protected)

# 6. Monitoring
SENTRY_DSN (protected)
DATADOG_API_KEY (protected, masked)
```

---

## 환경별 변수 관리 예시

```bash
# 개발 환경
environment_scope: "development"
- DEBUG=true
- LOG_LEVEL=debug

# 스테이징 환경
environment_scope: "staging"
- DEBUG=false
- LOG_LEVEL=info
- API_URL=https://staging-api.example.com

# 프로덕션 환경
environment_scope: "production"
- DEBUG=false
- LOG_LEVEL=warn
- API_URL=https://api.example.com
```

---

## Masked Variable 규칙

변수 마스킹을 위한 조건:
- 최소 8자 이상
- Base64 인코딩된 값이거나
- 다음 문자만 포함: `[a-zA-Z0-9+/=.-]`

## Your Task

사용자의 요청에 따라 GitLab CI/CD 변수를 관리하세요.

1. 환경변수 확인
2. 변수 유형 결정 (env_var / file)
3. 보안 옵션 설정 (protected, masked)
4. 환경 범위 설정 (필요 시)

$ARGUMENTS
