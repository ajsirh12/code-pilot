---
name: create-migration
description: 데이터베이스 마이그레이션 파일 생성
argument-hint: "<migration-name> [--type sql|prisma|typeorm|drizzle]"
allowed-tools: ["Read", "Glob", "Grep", "Write", "Bash"]
---

# 마이그레이션 생성 명령어

데이터베이스 스키마 변경을 위한 마이그레이션 파일을 생성한다.

## 실행 단계

1. **프로젝트 분석**
   - 기존 마이그레이션 디렉토리 탐색
   - 사용 중인 마이그레이션 도구 감지
   - 버전 넘버링 규칙 파악

2. **마이그레이션 타입 결정**
   - `--type` 지정 시 해당 형식 사용
   - 미지정 시 프로젝트에서 자동 감지:
     - `prisma/` → Prisma
     - `*.entity.ts` → TypeORM
     - `drizzle/` → Drizzle
     - `migrations/*.sql` → 순수 SQL

3. **파일 생성**

   **순수 SQL 형식:**
   ```
   migrations/
   └── YYYYMMDDHHMMSS_migration_name.sql
   ```

   ```sql
   -- Up Migration
   CREATE TABLE ...;

   -- Down Migration
   DROP TABLE ...;
   ```

   **Prisma 형식:**
   ```
   prisma db push 또는 prisma migrate dev --name migration_name
   ```

   **TypeORM 형식:**
   ```typescript
   export class MigrationName implements MigrationInterface {
     async up(queryRunner: QueryRunner): Promise<void> { }
     async down(queryRunner: QueryRunner): Promise<void> { }
   }
   ```

   **Drizzle 형식:**
   ```typescript
   export const migration = {
     up: async (db) => { },
     down: async (db) => { }
   }
   ```

4. **안전성 검사**
   - 데이터 손실 가능성 경고
   - 롤백 가능 여부 확인
   - 프로덕션 주의사항 안내

## 자주 사용하는 마이그레이션 패턴

- 테이블 생성/삭제
- 컬럼 추가/삭제/수정
- 인덱스 생성/삭제
- 외래키 추가/삭제
- 데이터 마이그레이션
