---
name: Profiling Patterns
description: |
  애플리케이션 프로파일링 기법과 성능 최적화 패턴에 대한 지식을 제공하는 스킬.
  사용자가 "프로파일링", "성능 분석", "벤치마크", "메모리 누수",
  "CPU 사용량", "핫스팟", "병목" 등을 언급할 때 이 스킬을 사용합니다.
version: 1.0.0
---

# 프로파일링 & 성능 최적화 패턴

## 프로파일링 도구

### Node.js
```bash
# V8 내장 프로파일러
node --prof app.js
node --prof-process isolate-*.log > profile.txt

# 힙 스냅샷
node --inspect app.js
# DevTools > Memory > Take snapshot

# clinic.js (종합 진단)
npx clinic doctor -- node app.js
npx clinic flame -- node app.js
```

### Python
```bash
# cProfile (기본 프로파일러)
python -m cProfile -s cumtime app.py

# line_profiler (라인별 분석)
@profile
def slow_function():
    ...
kernprof -l -v app.py

# memory_profiler
@profile
def memory_heavy():
    ...
python -m memory_profiler app.py

# py-spy (프로덕션 안전)
py-spy record -o profile.svg --pid <PID>
```

### Go
```go
import (
    "net/http"
    _ "net/http/pprof"
)

func main() {
    go http.ListenAndServe(":6060", nil)
    // ...
}
```
```bash
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30
go tool pprof http://localhost:6060/debug/pprof/heap
```

## 성능 안티패턴

### O(n²) 이상 복잡도
```typescript
// BAD
function findDuplicates(arr: string[]) {
  return arr.filter((item, index) =>
    arr.indexOf(item) !== index  // O(n²)
  );
}

// GOOD
function findDuplicates(arr: string[]) {
  const seen = new Set<string>();
  const duplicates: string[] = [];
  for (const item of arr) {
    if (seen.has(item)) duplicates.push(item);
    seen.add(item);
  }
  return duplicates;  // O(n)
}
```

### 동기 블로킹
```typescript
// BAD: 순차 처리
for (const url of urls) {
  const data = await fetch(url);
  results.push(data);
}

// GOOD: 병렬 처리
const results = await Promise.all(
  urls.map(url => fetch(url))
);
```

### 메모리 누수 패턴
```typescript
// BAD: 이벤트 리스너 누수
element.addEventListener('click', handler);
// cleanup 없음

// BAD: 클로저에 의한 참조 유지
function process() {
  const largeData = getLargeData();
  return () => {
    console.log(largeData.length); // largeData 참조 유지
  };
}

// BAD: 무한 성장 캐시
const cache = new Map();
function getData(key) {
  if (!cache.has(key)) {
    cache.set(key, compute(key)); // 삭제 로직 없음
  }
  return cache.get(key);
}
```

## 최적화 패턴

### 메모이제이션
```typescript
function memoize<T, R>(fn: (arg: T) => R): (arg: T) => R {
  const cache = new Map<T, R>();
  return (arg: T) => {
    if (cache.has(arg)) return cache.get(arg)!;
    const result = fn(arg);
    cache.set(arg, result);
    return result;
  };
}
```

### 디바운스/스로틀
```typescript
function debounce<T extends (...args: any[]) => any>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => void {
  let timeoutId: NodeJS.Timeout;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}
```

### 청크 처리
```typescript
async function processInChunks<T>(
  items: T[],
  processor: (item: T) => Promise<void>,
  chunkSize = 100
) {
  for (let i = 0; i < items.length; i += chunkSize) {
    const chunk = items.slice(i, i + chunkSize);
    await Promise.all(chunk.map(processor));
  }
}
```

## 벤치마크 가이드라인

### 정확한 측정
1. 워밍업 실행 (JIT 컴파일)
2. 충분한 반복 횟수
3. 통계적 유의성 확인
4. GC 영향 고려

### 비교 시 주의점
- 동일 조건에서 비교
- 실제 데이터 크기 사용
- 에지 케이스 포함
- 메모리 사용량도 측정
