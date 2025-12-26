---
name: generate-mock
description: OpenAPI 스펙 기반 Mock 서버 생성
argument-hint: "[openapi.yaml] [--port 3000]"
allowed-tools: ["Read", "Glob", "Write", "Bash"]
---

# Mock 서버 생성 명령어

OpenAPI 스펙을 기반으로 Mock API 서버를 생성한다.

## 실행 단계

1. **OpenAPI 스펙 분석**
   - 엔드포인트 목록 추출
   - 요청/응답 스키마 파싱
   - 예제 데이터 수집

2. **Mock 서버 옵션**

   **Prism (권장):**
   ```bash
   # 설치 및 실행
   npm install -g @stoplight/prism-cli
   prism mock openapi.yaml --port 3000

   # Docker
   docker run -p 3000:4010 -v $(pwd):/spec \
     stoplight/prism:4 mock /spec/openapi.yaml
   ```

   **MSW (프론트엔드 통합):**
   ```typescript
   // mocks/handlers.ts
   import { rest } from 'msw';

   export const handlers = [
     rest.get('/api/users', (req, res, ctx) => {
       return res(
         ctx.json([
           { id: '1', name: 'John Doe', email: 'john@example.com' }
         ])
       );
     }),
   ];
   ```

   **JSON Server (간단한 경우):**
   ```bash
   # db.json 생성
   npx json-server --watch db.json --port 3000
   ```

3. **Mock 데이터 생성**
   ```typescript
   // Faker.js 활용
   import { faker } from '@faker-js/faker';

   const mockUser = {
     id: faker.string.uuid(),
     name: faker.person.fullName(),
     email: faker.internet.email(),
     createdAt: faker.date.past().toISOString(),
   };
   ```

4. **동적 응답 설정**
   - 성공/에러 시나리오
   - 지연 시간 시뮬레이션
   - 조건부 응답

5. **출력 파일**
   ```
   mock/
   ├── server.js          # Mock 서버 진입점
   ├── handlers/          # 엔드포인트별 핸들러
   │   ├── users.js
   │   └── posts.js
   ├── data/              # Mock 데이터
   │   └── users.json
   └── README.md          # 실행 가이드
   ```

6. **실행 명령**
   ```bash
   # 개발 모드
   npm run mock

   # 또는 직접 실행
   node mock/server.js
   ```
