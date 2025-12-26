---
name: optimize-query
description: SQL 쿼리를 분석하여 성능 최적화 제안
argument-hint: "[쿼리 또는 파일경로]"
allowed-tools: ["Read", "Glob", "Grep", "Write"]
---

# 쿼리 최적화 명령어

SQL 쿼리를 분석하여 성능 개선점을 찾고 최적화된 쿼리를 제안한다.

## 실행 단계

1. **쿼리 수집**
   - 사용자가 직접 쿼리 제공
   - 파일에서 쿼리 추출 (`.sql`, 코드 내 쿼리)
   - ORM 쿼리 분석 (raw query, query builder)

2. **분석 항목**
   - SELECT * 사용 여부
   - 인덱스 활용 가능성
   - JOIN 효율성 (타입, 순서)
   - WHERE 절 최적화
   - 서브쿼리 vs JOIN 비교
   - LIMIT/OFFSET 페이징 문제
   - N+1 쿼리 패턴

3. **EXPLAIN 분석 가이드**
   ```sql
   -- PostgreSQL
   EXPLAIN ANALYZE SELECT ...

   -- MySQL
   EXPLAIN FORMAT=JSON SELECT ...
   ```

4. **최적화 제안**
   - 인덱스 추가/수정 DDL 제공
   - 리팩토링된 쿼리 제안
   - 예상 성능 개선 효과 설명

5. **출력 형식**
   ```
   ## 쿼리 분석 결과

   ### 원본 쿼리
   [쿼리]

   ### 발견된 문제점
   1. [CRITICAL] Full table scan 예상
   2. [WARNING] SELECT * 사용

   ### 최적화된 쿼리
   [개선 쿼리]

   ### 권장 인덱스
   CREATE INDEX idx_... ON ...
   ```

## DB별 최적화 팁

각 DB 엔진의 특성을 고려한 최적화 제안 제공
