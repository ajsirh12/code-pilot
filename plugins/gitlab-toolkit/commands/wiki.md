---
description: Create and manage GitLab Wiki pages
argument-hint: "create|update|list [page-slug]"
allowed-tools: Bash(curl:*)
---

## GitLab Wiki Management

이 명령어는 GitLab Wiki 페이지를 생성하고 관리합니다.

### 주요 기능

1. **Wiki 페이지 생성**: 새 위키 페이지 생성
2. **Wiki 페이지 수정**: 기존 페이지 업데이트
3. **Wiki 페이지 삭제**: 페이지 삭제
4. **Wiki 조회**: 전체 페이지 목록 조회

### 권장 Wiki 구조

```
Home (index)
├── Getting Started
│   ├── Installation
│   ├── Configuration
│   └── Quick Start
├── User Guide
│   ├── Features
│   └── FAQ
├── Developer Guide
│   ├── Architecture
│   ├── API Reference
│   └── Contributing
└── Operations
    ├── Deployment
    ├── Monitoring
    └── Troubleshooting
```

### GitLab API 사용법

```bash
# Wiki 페이지 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "Home",
    "content": "# Project Wiki\n\nWelcome to the project wiki!\n\n## Quick Links\n\n- [Getting Started](getting-started)\n- [User Guide](user-guide)\n- [API Reference](api-reference)",
    "format": "markdown"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/wikis"

# 하위 페이지 생성 (슬러그에 슬래시 사용)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "getting-started/installation",
    "content": "# Installation Guide\n\n## Prerequisites\n\n- Node.js 18+\n- npm or yarn",
    "format": "markdown"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/wikis"

# Wiki 페이지 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "content": "Updated content here",
    "format": "markdown"
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/wikis/:slug"

# Wiki 페이지 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/wikis/:slug"

# Wiki 목록 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/wikis"

# Wiki 페이지 상세 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/wikis/:slug"
```

### Markdown 형식

Wiki는 GitLab Flavored Markdown을 지원합니다:
- **Mermaid 다이어그램**: ```mermaid
- **수식**: $`E = mc^2`$
- **작업 목록**: - [ ] Task
- **접기**: <details><summary>Title</summary>Content</details>

## Your Task

사용자의 요청에 따라 GitLab Wiki를 관리하세요.

1. 환경변수 확인
2. Wiki 페이지 생성/수정/삭제 작업 실행
3. Markdown 형식으로 콘텐츠 작성

$ARGUMENTS
