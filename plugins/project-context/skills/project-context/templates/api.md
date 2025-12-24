# Project: [API 이름]

## Context

### Overview
- 목적: [API가 제공하는 핵심 기능]
- 클라이언트: [사용하는 서비스/앱]
- 담당: [팀명 또는 담당자]

### Tech Stack
- Runtime: [Node.js / Python / Go / Java]
- Framework: [Express / FastAPI / Gin / Spring]
- Database: [PostgreSQL / MySQL / MongoDB]
- Cache: [Redis / Memcached]
- Queue: [RabbitMQ / Kafka / SQS]

### Structure
```
src/
├── routes/        # API 라우트 정의
├── controllers/   # 요청 핸들러
├── services/      # 비즈니스 로직
├── models/        # 데이터 모델
├── middlewares/   # 미들웨어
├── utils/         # 유틸리티
└── types/         # 타입 정의
```

### API Design
- Style: [REST / GraphQL / gRPC]
- Version: [URL 버전 /v1 / 헤더 버전]
- Auth: [JWT / OAuth2 / API Key]
- Rate Limit: [요청 제한 정책]

### Conventions
- Naming: [snake_case / camelCase]
- Error Format: [RFC 7807 / Custom]
- Pagination: [Cursor / Offset]

---

## Status

### Current Sprint
- Phase: `Build` | `Ship` | `Maintain`
- Sprint: [번호/기간]
- Goal: [이번 스프린트 목표]

### Progress
- Focus: [현재 작업 중인 엔드포인트]
- Next: [다음 작업]
- Blocked: -

### Environments
| Env | URL | DB |
|-----|-----|-----|
| Dev | [URL] | [DB명] |
| Staging | [URL] | [DB명] |
| Prod | [URL] | [DB명] |

---

## Knowledge

### Architecture
- [YYYY-MM]: [DB 스키마 설계 결정]
- [YYYY-MM]: [인증 방식 선택]

### Performance
- [YYYY-MM]: [캐싱 전략]
- [YYYY-MM]: [쿼리 최적화]

### Security
- [YYYY-MM]: [보안 관련 결정]

### Breaking Changes
- [YYYY-MM]: [API 변경 이력]

---

## References
- API Docs: [Swagger/OpenAPI 링크]
- DB Schema: [ERD 링크]
- Architecture: [설계 문서 링크]
- Postman: [Collection 링크]
