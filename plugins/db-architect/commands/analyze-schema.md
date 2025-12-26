---
name: analyze-schema
description: 데이터베이스 스키마를 분석하여 구조, 관계, 개선점 파악
argument-hint: "[파일경로 또는 DB 타입]"
allowed-tools: ["Read", "Glob", "Grep", "Bash", "Write"]
---

# 스키마 분석 명령어

데이터베이스 스키마 파일이나 ORM 모델을 분석하여 구조를 파악하고 개선점을 제안한다.

## 실행 단계

1. **스키마 파일 탐색**
   - SQL 스키마 파일: `*.sql`, `schema.sql`, `migrations/*.sql`
   - ORM 모델: Prisma(`schema.prisma`), TypeORM(`*.entity.ts`), Drizzle(`schema.ts`)
   - 사용자가 경로를 지정하면 해당 파일 분석

2. **분석 항목**
   - 테이블 구조 및 컬럼 정의
   - Primary Key, Foreign Key 관계
   - 인덱스 현황
   - 제약조건 (UNIQUE, NOT NULL, CHECK 등)
   - 데이터 타입 적절성

3. **개선 제안**
   - 누락된 인덱스 추천
   - 정규화/비정규화 제안
   - 네이밍 컨벤션 일관성
   - 외래키 관계 최적화
   - 데이터 타입 최적화

4. **출력 형식**
   ```
   ## 스키마 분석 결과

   ### 테이블 목록
   | 테이블명 | 컬럼수 | PK | FK | 인덱스 |

   ### 관계도 (ERD 텍스트)

   ### 개선 권장사항
   - [HIGH] 인덱스 추가 권장: ...
   - [MEDIUM] 정규화 제안: ...
   - [LOW] 네이밍 개선: ...
   ```

## 지원 DB

PostgreSQL, MySQL, SQLite, MSSQL, Oracle 및 주요 ORM (Prisma, TypeORM, Drizzle, Sequelize)
