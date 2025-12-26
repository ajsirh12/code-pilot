---
name: Query Optimization Patterns
description: |
  SQL 쿼리 최적화 패턴과 인덱스 전략에 대한 지식을 제공하는 스킬.
  사용자가 "쿼리 최적화", "SQL 성능", "인덱스 전략", "느린 쿼리",
  "EXPLAIN 분석", "실행 계획" 등을 언급할 때 이 스킬을 사용합니다.
version: 1.0.0
---

# SQL 쿼리 최적화 패턴

## 인덱스 최적화

### 복합 인덱스 순서
WHERE 절에서 자주 사용되는 컬럼을 앞에 배치:
```sql
-- 좋음: user_id로 필터링 후 date로 정렬
CREATE INDEX idx_orders ON orders(user_id, created_at DESC);

-- 나쁨: 선택도가 낮은 컬럼이 앞에
CREATE INDEX idx_orders ON orders(status, user_id);
```

### 커버링 인덱스
쿼리에 필요한 모든 컬럼을 인덱스에 포함:
```sql
-- PostgreSQL
CREATE INDEX idx_users ON users(email) INCLUDE (name, status);

-- MySQL
CREATE INDEX idx_users ON users(email, name, status);
```

### 부분 인덱스
자주 조회되는 데이터만 인덱싱:
```sql
CREATE INDEX idx_active_users ON users(email)
WHERE status = 'active';
```

## 쿼리 리팩토링 패턴

### N+1 문제 해결
```sql
-- BAD: 루프에서 개별 조회
SELECT * FROM users WHERE id = ?;

-- GOOD: 한 번에 조회
SELECT u.*, p.* FROM users u
LEFT JOIN posts p ON u.id = p.user_id
WHERE u.id IN (...);
```

### 서브쿼리 vs JOIN
```sql
-- 서브쿼리 (느릴 수 있음)
SELECT * FROM orders
WHERE user_id IN (SELECT id FROM users WHERE status = 'active');

-- JOIN (보통 더 빠름)
SELECT o.* FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE u.status = 'active';
```

### 페이징 최적화
```sql
-- BAD: OFFSET이 크면 느림
SELECT * FROM posts ORDER BY id LIMIT 10 OFFSET 10000;

-- GOOD: Cursor 기반 페이징
SELECT * FROM posts
WHERE id > :last_id
ORDER BY id LIMIT 10;
```

## DB별 최적화 팁

### PostgreSQL
- `EXPLAIN (ANALYZE, BUFFERS)` 사용
- `pg_stat_statements`로 느린 쿼리 모니터링
- BRIN 인덱스: 시계열 데이터에 효과적

### MySQL
- `EXPLAIN FORMAT=JSON` 상세 분석
- `FORCE INDEX` 힌트 사용 (주의)
- InnoDB Buffer Pool 튜닝

### 공통
- 통계 정보 최신 유지 (`ANALYZE`)
- 실행 계획 캐시 활용
- Connection Pooling 적용
