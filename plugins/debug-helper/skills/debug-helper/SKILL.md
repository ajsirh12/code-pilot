---
name: debug-helper
description: This skill should be used when the user asks about "debugging errors", "error analysis", "log parsing", "stack trace", "exception handling", "why is this error happening", or needs help fixing bugs. Also triggered by Korean phrases like "에러 분석", "디버깅", "로그 분석", "왜 에러가 나", "버그 수정", "오류 해결".
---

# Debugging Guide

에러 분석, 로그 파싱, 디버깅 전략 가이드.

## Debugging Process

### 1. Understand the Error

**스택 트레이스 읽기**:
```
Error: Cannot find module 'express'
    at Function.Module._resolveFilename (internal/modules/cjs/loader.js:636:15)
    at Function.Module._load (internal/modules/cjs/loader.js:562:25)
    at require (internal/modules/cjs/helpers.js:90:18)
    at Object.<anonymous> (/app/server.js:1:17)  ← 실제 발생 위치
```

- 맨 아래 = 에러 메시지
- 위로 올라갈수록 = 호출 스택
- 내 코드 찾기 = node_modules 아닌 경로

### 2. Reproduce

```bash
# 동일 조건으로 재현
NODE_ENV=production npm start

# 최소 재현 케이스
node -e "require('express')"
```

### 3. Isolate

**이분 탐색**:
1. 코드 절반 주석
2. 에러 발생 확인
3. 발생하면 그 절반, 아니면 다른 절반
4. 반복

**로깅 추가**:
```javascript
console.log('Checkpoint 1', { variable });
console.log('Checkpoint 2', { anotherVar });
```

### 4. Fix & Verify

수정 후 확인:
- 원래 에러 해결?
- 새 에러 발생 안 함?
- 관련 테스트 통과?

---

## Error Types by Language

### JavaScript/TypeScript

| 타입 | 설명 | 일반적 원인 |
|------|------|-------------|
| `TypeError` | 타입 불일치 | null/undefined 접근 |
| `ReferenceError` | 미선언 변수 | import 누락, 오타 |
| `SyntaxError` | 문법 오류 | 괄호, 따옴표 |
| `RangeError` | 범위 초과 | 무한 재귀, 배열 인덱스 |

### Python

| 타입 | 설명 | 일반적 원인 |
|------|------|-------------|
| `AttributeError` | 속성 없음 | None 체크 누락 |
| `KeyError` | 딕셔너리 키 없음 | .get() 미사용 |
| `IndexError` | 인덱스 초과 | 범위 체크 누락 |
| `ImportError` | 모듈 없음 | 설치 안 됨 |

### Java

| 타입 | 설명 | 일반적 원인 |
|------|------|-------------|
| `NullPointerException` | null 참조 | null 체크 누락 |
| `ClassCastException` | 잘못된 캐스팅 | 타입 확인 필요 |
| `ArrayIndexOutOfBoundsException` | 배열 범위 초과 | 인덱스 검증 |

---

## Log Analysis

### Log Levels

| Level | 용도 | 대응 |
|-------|------|------|
| `FATAL` | 시스템 중단 | 즉시 확인 |
| `ERROR` | 기능 실패 | 조사 필요 |
| `WARN` | 잠재적 문제 | 모니터링 |
| `INFO` | 일반 정보 | 참고용 |
| `DEBUG` | 상세 정보 | 개발 시 |

### Parsing Commands

```bash
# 에러만 추출
grep -E "ERROR|Exception" app.log

# 최근 100줄
tail -100 app.log

# 시간대 필터
grep "2024-12-24 10:" app.log

# 에러 카운트
grep -c "ERROR" app.log

# 에러 패턴 분석
grep "ERROR" app.log | cut -d' ' -f4- | sort | uniq -c | sort -rn
```

---

## Debugging Tools

### Node.js

```bash
# 디버거 시작
node --inspect server.js

# Chrome DevTools 연결
chrome://inspect

# 환경변수로 상세 로그
DEBUG=* npm start
```

### Python

```bash
# pdb 디버거
python -m pdb script.py

# 브레이크포인트 코드
import pdb; pdb.set_trace()

# pytest 디버깅
pytest --pdb
```

### Browser

```javascript
// 브레이크포인트
debugger;

// 콘솔 로깅
console.log({ variable });
console.table(array);
console.trace();
```

---

## Common Fixes

### Null/Undefined

```javascript
// Before
user.name

// After
user?.name
user?.name ?? 'default'
```

### Async/Await

```javascript
// Before (에러 무시됨)
fetchData();

// After (에러 캐치)
try {
  await fetchData();
} catch (err) {
  console.error(err);
}
```

### Import Errors

```bash
# 모듈 재설치
rm -rf node_modules
npm install

# 캐시 클리어
npm cache clean --force
```

---

## Quick Reference

```bash
/debug [에러 메시지]    # 에러 분석
/debug [로그 경로]      # 로그 분석
/debug                  # 최근 에러 검색
```

### 디버깅 체크리스트

- [ ] 에러 메시지 정확히 읽기
- [ ] 스택 트레이스에서 내 코드 찾기
- [ ] 재현 가능한지 확인
- [ ] 최소 재현 케이스 만들기
- [ ] 수정 후 테스트
