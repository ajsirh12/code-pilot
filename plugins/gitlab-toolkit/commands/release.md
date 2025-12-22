---
description: Create GitLab Releases and Tags
argument-hint: "v1.0.0 [--notes 'Release notes']"
allowed-tools: Bash(curl:*), Bash(git:*)
---

## Context

- Current branch: !`git branch --show-current`
- Latest tags: !`git tag --sort=-version:refname | head -5`
- Recent commits: !`git log --oneline -10`

## GitLab Release Management

이 명령어는 GitLab Release와 Tag를 생성합니다.

### 주요 기능

1. **Tag 생성**: Git 태그 생성 및 푸시
2. **Release 생성**: GitLab Release 생성 (릴리즈 노트 포함)
3. **Release Assets**: 릴리즈에 파일 첨부
4. **Release 조회**: 릴리즈 목록 조회

### Semantic Versioning

- **MAJOR.MINOR.PATCH** 형식 권장
- `v1.0.0` - 초기 릴리즈
- `v1.1.0` - 새 기능 추가
- `v1.1.1` - 버그 수정
- `v2.0.0` - Breaking changes

### GitLab API 사용법

```bash
# Git Tag 생성 및 푸시
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# GitLab Release 생성 (태그 기반)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "tag_name": "v1.0.0",
    "name": "Release v1.0.0",
    "description": "## What'\''s New\n\n- Feature 1\n- Feature 2\n\n## Bug Fixes\n\n- Fix 1\n- Fix 2\n\n## Breaking Changes\n\n- None",
    "milestones": ["Phase 1"],
    "released_at": "2025-01-15T12:00:00Z"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/releases"

# Release에 Asset 링크 추가
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Application Binary",
    "url": "https://example.com/releases/app-v1.0.0.zip",
    "link_type": "package"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/releases/v1.0.0/assets/links"

# Release 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/releases"

# Release 상세 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/releases/v1.0.0"

# Release 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"description": "Updated release notes"}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/releases/v1.0.0"
```

### Release Notes 템플릿

```markdown
## What's New

- Feature 1: Description
- Feature 2: Description

## Bug Fixes

- Fix 1: Description
- Fix 2: Description

## Breaking Changes

- Change 1: Migration guide

## Contributors

- @username1
- @username2
```

## Your Task

사용자의 요청에 따라 GitLab Release를 생성하세요.

1. 버전 번호 결정 (Semantic Versioning 준수)
2. Git 태그 생성 및 푸시
3. GitLab Release 생성 (릴리즈 노트 포함)
4. 필요 시 Asset 링크 추가

$ARGUMENTS
