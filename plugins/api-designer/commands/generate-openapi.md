---
name: generate-openapi
description: 코드베이스에서 OpenAPI/Swagger 스펙 자동 생성
argument-hint: "[소스 디렉토리] [--output openapi.yaml]"
allowed-tools: ["Read", "Glob", "Grep", "Write", "Bash"]
---

# OpenAPI 스펙 생성 명령어

코드베이스를 분석하여 OpenAPI 3.0 스펙을 자동 생성한다.

## 실행 단계

1. **프로젝트 분석**
   - 프레임워크 감지 (Express, Fastify, NestJS, Flask, FastAPI 등)
   - 기존 OpenAPI 스펙 확인
   - 라우트 정의 파일 탐색

2. **라우트 추출**

   **Express/Fastify:**
   ```typescript
   app.get('/users/:id', handler);
   app.post('/users', handler);
   ```

   **NestJS:**
   ```typescript
   @Controller('users')
   export class UsersController {
     @Get(':id')
     @ApiOperation({ summary: 'Get user' })
     getUser(@Param('id') id: string) {}
   }
   ```

   **FastAPI:**
   ```python
   @app.get("/users/{user_id}")
   def get_user(user_id: int) -> User:
       ...
   ```

3. **스키마 추출**
   - TypeScript 인터페이스/타입
   - Zod/Yup 스키마
   - Pydantic 모델
   - 데코레이터 메타데이터

4. **OpenAPI 스펙 생성**
   ```yaml
   openapi: 3.0.3
   info:
     title: API Title
     version: 1.0.0
   paths:
     /users/{id}:
       get:
         summary: Get user by ID
         parameters:
           - name: id
             in: path
             required: true
             schema:
               type: string
         responses:
           '200':
             description: Success
             content:
               application/json:
                 schema:
                   $ref: '#/components/schemas/User'
   components:
     schemas:
       User:
         type: object
         properties:
           id:
             type: string
           name:
             type: string
   ```

5. **출력**
   - `openapi.yaml` 또는 `openapi.json` 파일 생성
   - 유효성 검사 결과 출력
   - 누락된 정보 알림
