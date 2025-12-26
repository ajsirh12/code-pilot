---
name: API Design Patterns
description: |
  RESTful API 설계 패턴과 베스트 프랙티스에 대한 지식을 제공하는 스킬.
  사용자가 "API 설계", "REST", "엔드포인트", "OpenAPI", "Swagger",
  "API 버저닝", "GraphQL" 등을 언급할 때 이 스킬을 사용합니다.
version: 1.0.0
---

# API 설계 패턴

## RESTful 설계 원칙

### 리소스 네이밍
```
# 좋음: 복수형 명사, 소문자, 하이픈
GET /users
GET /user-profiles
GET /order-items

# 나쁨
GET /getUsers       # 동사 사용
GET /UserProfiles   # 대문자
GET /user_profiles  # 언더스코어
```

### HTTP 메서드
| 메서드 | 용도 | 멱등성 | 안전 |
|--------|------|--------|------|
| GET | 조회 | ✅ | ✅ |
| POST | 생성 | ❌ | ❌ |
| PUT | 전체 수정 | ✅ | ❌ |
| PATCH | 부분 수정 | ❌ | ❌ |
| DELETE | 삭제 | ✅ | ❌ |

### HTTP 상태 코드
```
# 성공
200 OK - 일반 성공
201 Created - 리소스 생성
204 No Content - 삭제 성공

# 클라이언트 에러
400 Bad Request - 잘못된 요청
401 Unauthorized - 인증 필요
403 Forbidden - 권한 없음
404 Not Found - 리소스 없음
409 Conflict - 충돌 (중복 등)
422 Unprocessable Entity - 유효성 검증 실패

# 서버 에러
500 Internal Server Error
502 Bad Gateway
503 Service Unavailable
```

## 응답 형식

### 성공 응답
```json
{
  "data": {
    "id": "123",
    "type": "user",
    "attributes": {
      "name": "John Doe",
      "email": "john@example.com"
    }
  },
  "meta": {
    "requestId": "abc-123"
  }
}
```

### 목록 응답 (페이징)
```json
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "totalPages": 5
  },
  "links": {
    "self": "/users?page=1",
    "first": "/users?page=1",
    "prev": null,
    "next": "/users?page=2",
    "last": "/users?page=5"
  }
}
```

### 에러 응답
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request was invalid",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Email must be a valid email address"
      }
    ],
    "requestId": "abc-123",
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

## 인증 패턴

### JWT
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

### API Key
```
X-API-Key: your-api-key
# 또는
Authorization: ApiKey your-api-key
```

### OAuth 2.0
```
# Authorization Code Flow
GET /oauth/authorize?
  response_type=code&
  client_id=CLIENT_ID&
  redirect_uri=CALLBACK_URL&
  scope=read:user

# Token Exchange
POST /oauth/token
{
  "grant_type": "authorization_code",
  "code": "AUTH_CODE",
  "redirect_uri": "CALLBACK_URL"
}
```

## 버저닝 전략

### URL 버저닝 (권장)
```
GET /v1/users
GET /v2/users
```

### 헤더 버저닝
```
GET /users
Accept: application/vnd.api+json; version=1
```

### 쿼리 파라미터
```
GET /users?version=1
```

## GraphQL 패턴

### 스키마 정의
```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
}

type Query {
  user(id: ID!): User
  users(limit: Int, offset: Int): [User!]!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
}
```

### 쿼리 예시
```graphql
query GetUserWithPosts($id: ID!) {
  user(id: $id) {
    name
    email
    posts(limit: 10) {
      title
      createdAt
    }
  }
}
```

## Rate Limiting

### 응답 헤더
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1609459200
```

### 429 응답
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "retryAfter": 60
  }
}
```
