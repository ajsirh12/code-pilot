---
name: find-bottlenecks
description: 코드베이스에서 성능 병목 패턴 탐지
argument-hint: "[디렉토리 경로]"
allowed-tools: ["Read", "Glob", "Grep", "TodoWrite"]
---

# 병목 탐지 명령어

코드베이스를 정적 분석하여 성능 병목이 될 수 있는 패턴을 찾는다.

## 실행 단계

1. **코드 스캔**
   - 지정된 디렉토리 또는 전체 프로젝트 스캔
   - 언어별 성능 안티패턴 탐지

2. **탐지 패턴**

   **공통 패턴:**
   - 중첩 루프 (O(n²) 이상)
   - 루프 내 I/O 작업
   - 불필요한 객체 생성
   - 동기 블로킹 호출
   - 메모이제이션 없는 재귀

   **JavaScript/TypeScript:**
   ```typescript
   // BAD: 루프 내 await
   for (const item of items) {
     await processItem(item); // 순차 처리
   }

   // BAD: 배열 메서드 체이닝
   arr.filter(...).map(...).filter(...).reduce(...);

   // BAD: 불필요한 스프레드
   const copy = [...largeArray];
   ```

   **Python:**
   ```python
   # BAD: 리스트 컴프리헨션 중첩
   [[x*y for x in range(1000)] for y in range(1000)]

   # BAD: 문자열 연결
   result = ""
   for s in strings:
       result += s  # O(n²)
   ```

   **일반:**
   - 정규식 ReDoS 취약점
   - 무한 성장 가능한 캐시
   - 락 경합 가능성
   - 연결 풀 미사용

3. **심각도 분류**
   - CRITICAL: 프로덕션 장애 가능
   - HIGH: 확장성 문제
   - MEDIUM: 성능 저하
   - LOW: 최적화 가능

4. **출력 형식**
   ```
   ## 병목 탐지 결과

   ### 발견된 문제 (12건)

   #### CRITICAL (2건)
   1. **src/services/data.ts:45**
      - 패턴: O(n³) 중첩 루프
      - 영향: 데이터 증가 시 급격한 성능 저하
      - 수정: 해시맵 활용

   #### HIGH (4건)
   ...

   ### 요약
   - 스캔된 파일: 156개
   - 발견된 패턴: 12개
   - 예상 개선 효과: 최대 80% 성능 향상
   ```
