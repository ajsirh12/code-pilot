---
name: generate-docs
description: API 문서 자동 생성 (Swagger UI, Redoc 등)
argument-hint: "[openapi.yaml] [--format swagger|redoc|markdown]"
allowed-tools: ["Read", "Glob", "Write", "Bash"]
---

# API 문서 생성 명령어

OpenAPI 스펙에서 다양한 형식의 API 문서를 생성한다.

## 실행 단계

1. **OpenAPI 스펙 로드**
   - 지정된 파일 또는 자동 탐색
   - YAML/JSON 파싱
   - 유효성 검증

2. **문서 형식 선택**

   **Swagger UI:**
   ```html
   <!DOCTYPE html>
   <html>
   <head>
     <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist/swagger-ui.css">
   </head>
   <body>
     <div id="swagger-ui"></div>
     <script src="https://unpkg.com/swagger-ui-dist/swagger-ui-bundle.js"></script>
     <script>
       SwaggerUIBundle({
         url: './openapi.yaml',
         dom_id: '#swagger-ui'
       });
     </script>
   </body>
   </html>
   ```

   **Redoc:**
   ```html
   <!DOCTYPE html>
   <html>
   <head>
     <script src="https://cdn.redoc.ly/redoc/latest/bundles/redoc.standalone.js"></script>
   </head>
   <body>
     <redoc spec-url="./openapi.yaml"></redoc>
   </body>
   </html>
   ```

   **Markdown:**
   ```markdown
   # API Documentation

   ## Endpoints

   ### GET /users
   Get all users

   **Parameters:**
   | Name | In | Type | Required | Description |
   |------|-----|------|----------|-------------|
   | page | query | integer | No | Page number |

   **Responses:**
   - 200: Success
   - 401: Unauthorized
   ```

3. **추가 기능**
   - 인터랙티브 API 테스트
   - 코드 샘플 생성 (curl, Python, JavaScript)
   - 인증 설정 가이드
   - 변경 이력 (Changelog)

4. **배포 옵션**
   ```bash
   # 정적 사이트 생성
   npx @redocly/cli build-docs openapi.yaml -o docs/

   # Docker로 서빙
   docker run -p 8080:8080 -v $(pwd):/spec redocly/redoc
   ```

5. **출력**
   - 문서 HTML 파일
   - 배포 가이드
   - CI/CD 통합 스크립트
