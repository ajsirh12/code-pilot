---
description: Create and manage GitLab Snippets
argument-hint: "create|list|delete [title]"
allowed-tools: Bash(curl:*)
---

## GitLab Snippets Management

이 명령어는 GitLab Snippets(코드 스니펫)을 생성하고 관리합니다.

### 주요 기능

1. **Snippet 생성**: 코드 스니펫 생성
2. **Snippet 수정**: 기존 스니펫 업데이트
3. **Snippet 삭제**: 스니펫 삭제
4. **Snippet 조회**: 스니펫 목록 조회

### Snippet 유형

- **Project Snippet**: 프로젝트 범위 스니펫
- **Personal Snippet**: 개인 스니펫 (글로벌)

### GitLab API 사용법

```bash
# Project Snippet 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "Database Connection Helper",
    "description": "PostgreSQL 연결 헬퍼 함수",
    "visibility": "internal",
    "files": [
      {
        "file_path": "db-helper.ts",
        "content": "import { Pool } from '\"'\"'pg'\"'\"';\n\nexport const pool = new Pool({\n  connectionString: process.env.DATABASE_URL\n});\n\nexport async function query(text: string, params?: any[]) {\n  const client = await pool.connect();\n  try {\n    return await client.query(text, params);\n  } finally {\n    client.release();\n  }\n}"
      }
    ]
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/snippets"

# 다중 파일 Snippet 생성
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "Docker Setup",
    "visibility": "private",
    "files": [
      {
        "file_path": "Dockerfile",
        "content": "FROM node:18-alpine\nWORKDIR /app\nCOPY package*.json ./\nRUN npm ci\nCOPY . .\nCMD [\"npm\", \"start\"]"
      },
      {
        "file_path": "docker-compose.yml",
        "content": "version: \"3.8\"\nservices:\n  app:\n    build: .\n    ports:\n      - \"3000:3000\""
      }
    ]
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/snippets"

# Snippet 수정
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "title": "Updated Title",
    "files": [
      {
        "action": "update",
        "file_path": "db-helper.ts",
        "content": "// Updated content"
      }
    ]
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/snippets/:snippet_id"

# Snippet 삭제
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/snippets/:snippet_id"

# Project Snippet 목록
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/snippets"

# Snippet 상세 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/snippets/:snippet_id"

# Snippet Raw 내용 조회
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/snippets/:snippet_id/files/main/:file_path/raw"
```

### Visibility 옵션

| 값 | 설명 |
|---|------|
| `private` | 프로젝트 멤버만 |
| `internal` | 로그인한 사용자 |
| `public` | 모든 사람 |

### 활용 예시

- 자주 사용하는 코드 패턴
- 설정 파일 템플릿
- 스크립트 모음
- 문서화된 코드 예제

## Your Task

사용자의 요청에 따라 GitLab Snippet을 생성하거나 관리하세요.

1. 환경변수 확인
2. 스니펫 생성/수정/삭제 작업 실행
3. 적절한 visibility 설정

$ARGUMENTS
