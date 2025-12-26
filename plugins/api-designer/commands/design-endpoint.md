---
name: design-endpoint
description: RESTful API 엔드포인트 설계 가이드
argument-hint: "<리소스명> [CRUD|custom]"
allowed-tools: ["Read", "Glob", "Grep", "Write"]
---

# 엔드포인트 설계 명령어

RESTful 원칙에 따른 API 엔드포인트를 설계한다.

## 실행 단계

1. **리소스 분석**
   - 리소스 이름 복수형 변환
   - 관련 리소스 관계 파악
   - 기존 API 패턴 확인

2. **CRUD 엔드포인트 생성**
   ```
   GET    /users          - 목록 조회
   POST   /users          - 생성
   GET    /users/{id}     - 단일 조회
   PUT    /users/{id}     - 전체 수정
   PATCH  /users/{id}     - 부분 수정
   DELETE /users/{id}     - 삭제
   ```

3. **중첩 리소스**
   ```
   GET    /users/{userId}/posts        - 사용자의 게시글 목록
   POST   /users/{userId}/posts        - 사용자의 게시글 생성
   GET    /users/{userId}/posts/{id}   - 특정 게시글 조회
   ```

4. **필터링/페이징/정렬**
   ```
   GET /users?status=active&role=admin     # 필터링
   GET /users?page=2&limit=20              # 페이징
   GET /users?sort=created_at&order=desc   # 정렬
   GET /users?fields=id,name,email         # 필드 선택
   ```

5. **커스텀 액션**
   ```
   POST /users/{id}/activate      - 상태 변경 액션
   POST /users/{id}/send-email    - 부작용 있는 액션
   GET  /users/me                 - 현재 사용자
   GET  /users/search?q=keyword   - 검색
   ```

6. **응답 형식**
   ```json
   {
     "data": { ... },
     "meta": {
       "total": 100,
       "page": 1,
       "limit": 20
     },
     "links": {
       "self": "/users?page=1",
       "next": "/users?page=2"
     }
   }
   ```

7. **에러 응답**
   ```json
   {
     "error": {
       "code": "VALIDATION_ERROR",
       "message": "Invalid input",
       "details": [
         { "field": "email", "message": "Invalid email format" }
       ]
     }
   }
   ```

8. **출력**
   - 설계된 엔드포인트 목록
   - OpenAPI 스펙 조각
   - 구현 가이드
