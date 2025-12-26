---
name: Database Migration Patterns
description: |
  데이터베이스 마이그레이션 베스트 프랙티스와 안전한 스키마 변경 패턴을 제공하는 스킬.
  사용자가 "마이그레이션", "스키마 변경", "테이블 수정", "컬럼 추가",
  "롤백", "무중단 배포" 등을 언급할 때 이 스킬을 사용합니다.
version: 1.0.0
---

# 데이터베이스 마이그레이션 패턴

## 안전한 마이그레이션 원칙

### 롤백 가능성 확보
모든 마이그레이션은 롤백(Down) 스크립트 포함:
```sql
-- Up
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Down
ALTER TABLE users DROP COLUMN phone;
```

### 무중단 배포 (Zero-Downtime)

**컬럼 추가** (안전):
```sql
-- 새 컬럼은 NULL 허용 또는 DEFAULT 값 필수
ALTER TABLE users ADD COLUMN nickname VARCHAR(50) DEFAULT '';
```

**컬럼 삭제** (3단계):
1. 코드에서 컬럼 사용 제거
2. 배포 후 안정화 확인
3. 마이그레이션으로 컬럼 삭제

**컬럼 이름 변경** (위험 - 피할 것):
```sql
-- 대신: 새 컬럼 추가 → 데이터 복사 → 구 컬럼 삭제
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);
UPDATE users SET full_name = name;
-- 코드 변경 후
ALTER TABLE users DROP COLUMN name;
```

## 마이그레이션 파일 컨벤션

### 버전 관리
```
migrations/
├── 20240101120000_create_users.sql
├── 20240102090000_add_users_email_index.sql
└── 20240103150000_create_posts.sql
```

### 파일 구조
```sql
-- Migration: create_users
-- Created: 2024-01-01
-- Description: 사용자 테이블 생성

-- ====== UP ======
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

-- ====== DOWN ======
DROP TABLE IF EXISTS users;
```

## ORM별 마이그레이션

### Prisma
```prisma
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  posts Post[]
}
```
```bash
npx prisma migrate dev --name add_users
```

### TypeORM
```typescript
export class CreateUsers1704067200000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE users (...)
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE users`);
  }
}
```

### Drizzle
```typescript
import { pgTable, serial, varchar } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: varchar('email', { length: 255 }).notNull().unique(),
});
```
```bash
npx drizzle-kit generate:pg
```

## 주의사항

### 락(Lock) 관리
- 대용량 테이블 ALTER는 락 발생
- PostgreSQL: `CONCURRENTLY` 옵션 사용
- 트래픽 낮은 시간대에 실행

### 데이터 마이그레이션
- 대용량 데이터는 배치 처리
- 트랜잭션 크기 제한
- 진행 상황 로깅

### 프로덕션 체크리스트
- [ ] 스테이징에서 테스트 완료
- [ ] 롤백 스크립트 검증
- [ ] 백업 생성
- [ ] 실행 시간 예측
- [ ] 모니터링 대시보드 준비
