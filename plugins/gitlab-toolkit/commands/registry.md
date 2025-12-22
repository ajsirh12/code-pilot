---
description: Manage Container Registry and Package Registry (npm/PyPI/Maven/NuGet)
argument-hint: "container|package list|delete|tag [image-name|package-name]"
allowed-tools: Bash(curl:*)
---

## Context

- Current branch: !`git branch --show-current`
- Project: !`basename $(git rev-parse --show-toplevel)`

## GitLab Registry Management

이 명령어는 GitLab Container Registry와 Package Registry를 관리합니다.

### 주요 기능

1. **Container Registry**: Docker/OCI 이미지 관리
2. **Package Registry**: npm, PyPI, Maven, NuGet, Go, Composer 패키지 관리
3. **이미지/패키지 조회**: 태그 및 버전 확인
4. **정리 작업**: 오래된 이미지/패키지 삭제

---

## Container Registry API

### Repository 조회

```bash
# Container Registry Repositories 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories"

# Repository 상세 정보 (tags_count 포함)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories?tags=true&tags_count=true"

# 특정 Repository 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/registry/repositories/:repository_id"
```

### Tags 관리

```bash
# Repository의 Tags 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id/tags"

# 특정 Tag 상세 정보
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id/tags/:tag_name"

# Tag 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id/tags/:tag_name"

# Bulk Tag 삭제 (정규식 매칭)
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name_regex_delete": "v[0-9]+\\.[0-9]+\\.[0-9]+-dev.*",
    "keep_n": 5,
    "older_than": "14d"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id/tags"
```

### Repository 삭제

```bash
# Repository 삭제 (모든 tags 포함)
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id"
```

---

## Package Registry API

### 패키지 목록 조회

```bash
# 프로젝트의 모든 패키지
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/packages"

# 패키지 타입별 필터링
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/packages?package_type=npm"

# 패키지 이름으로 검색
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/packages?package_name=my-package"

# 패키지 상세 정보
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/packages/:package_id"

# 패키지 파일 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/packages/:package_id/package_files"
```

### 패키지 삭제

```bash
# 특정 패키지 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/packages/:package_id"

# 패키지 파일 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/packages/:package_id/package_files/:file_id"
```

---

## npm Registry

### .npmrc 설정

```bash
# .npmrc 예시
@myorg:registry=https://gitlab.example.com/api/v4/projects/$GITLAB_PROJECT_ID/packages/npm/
//gitlab.example.com/api/v4/projects/$GITLAB_PROJECT_ID/packages/npm/:_authToken=${GITLAB_TOKEN}
```

### npm 패키지 조회

```bash
# npm 패키지 메타데이터
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/packages/npm/@scope%2Fpackage-name"
```

---

## PyPI Registry

### pip.conf 설정

```ini
[global]
index-url = https://__token__:${GITLAB_TOKEN}@gitlab.example.com/api/v4/projects/${GITLAB_PROJECT_ID}/packages/pypi/simple
```

### PyPI 패키지 업로드

```bash
# twine으로 업로드
# pip install twine
# twine upload --repository-url https://gitlab.example.com/api/v4/projects/$GITLAB_PROJECT_ID/packages/pypi \
#   -u __token__ -p $GITLAB_TOKEN dist/*
```

---

## Maven Registry

### settings.xml 설정

```xml
<settings>
  <servers>
    <server>
      <id>gitlab-maven</id>
      <configuration>
        <httpHeaders>
          <property>
            <name>Private-Token</name>
            <value>${env.GITLAB_TOKEN}</value>
          </property>
        </httpHeaders>
      </configuration>
    </server>
  </servers>
</settings>
```

---

## NuGet Registry

```bash
# NuGet source 추가
# dotnet nuget add source \
#   "https://gitlab.example.com/api/v4/projects/$GITLAB_PROJECT_ID/packages/nuget/index.json" \
#   --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN
```

---

## Container Registry 정리 정책

```bash
# Cleanup Policy 설정 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id" | \
  jq '.cleanup_policy_started_at'

# 프로젝트 수준 Container Expiration Policy
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "container_expiration_policy_attributes": {
      "enabled": true,
      "cadence": "1d",
      "keep_n": 5,
      "older_than": "14d",
      "name_regex": ".*",
      "name_regex_keep": "main|release-.*"
    }
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"
```

---

## 패키지 타입

| 타입 | 설명 |
|------|------|
| `npm` | Node.js 패키지 |
| `pypi` | Python 패키지 |
| `maven` | Java/Kotlin 패키지 |
| `nuget` | .NET 패키지 |
| `composer` | PHP 패키지 |
| `conan` | C/C++ 패키지 |
| `helm` | Kubernetes Helm Charts |
| `generic` | 일반 파일 패키지 |
| `terraform_module` | Terraform 모듈 |

---

## 유용한 조합 명령

```bash
# 14일 이상 된 dev 태그 정리 (dry-run으로 확인)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/registry/repositories/:repository_id/tags" | \
  jq '[.[] | select(.name | test("dev|snapshot")) | select(.created_at < (now - 14*24*60*60 | todate))] | length'

# 패키지 용량 확인
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/packages" | \
  jq '[.[].size // 0] | add | . / 1024 / 1024 | floor | "\(.)MB"'
```

## Your Task

사용자의 요청에 따라 Container Registry 또는 Package Registry를 관리하세요.

1. 환경변수 확인 ($GITLAB_TOKEN, $GITLAB_URL, $GITLAB_PROJECT_ID)
2. Registry 목록/상세 조회
3. 이미지/패키지 삭제 또는 정리
4. 결과 보고

$ARGUMENTS
