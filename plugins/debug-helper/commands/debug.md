---
description: Analyze errors, parse logs, and provide debugging guidance
argument-hint: "[error message or log file path]"
allowed-tools: ["Read", "Bash", "Glob", "Grep", "TodoWrite", "WebSearch"]
---

# Debug Helper

에러 분석, 로그 파싱, 디버깅 가이드를 제공한다.

## Input Detection

Parse from: $ARGUMENTS

| 입력 타입 | 감지 방법 | 동작 |
|----------|----------|------|
| 에러 메시지 | 텍스트에 Error/Exception 포함 | 에러 분석 |
| 파일 경로 | .log, .txt 확장자 또는 경로 형태 | 로그 파일 분석 |
| 빈 입력 | 인자 없음 | 최근 에러 검색 |

---

## Workflow

### 1. Error Analysis (에러 메시지 입력 시)

에러 메시지에서 추출:
- 에러 타입 (TypeError, NullPointerException 등)
- 스택 트레이스
- 발생 위치 (파일:라인)
- 관련 변수/값

분석 후 제공:
```markdown
## Error Analysis

### What Happened
[에러 설명]

### Why It Happened
[원인 분석]

### How to Fix
1. [수정 방법 1]
2. [수정 방법 2]

### Related Code
[관련 코드 위치 및 수정 제안]
```

### 2. Log File Analysis (로그 파일 입력 시)

```bash
# 에러/경고 추출
grep -E "(ERROR|WARN|Exception|Failed)" [logfile]

# 최근 N줄
tail -100 [logfile]

# 타임스탬프 기준 필터
grep "2024-12-24" [logfile]
```

분석 후 제공:
```markdown
## Log Analysis

### Summary
- Total lines: [N]
- Errors: [N]
- Warnings: [N]
- Time range: [start] ~ [end]

### Critical Errors
| Time | Level | Message |
|------|-------|---------|
| ... | ERROR | ... |

### Error Patterns
- [패턴 1]: [N]회 발생
- [패턴 2]: [N]회 발생

### Recommendations
1. [권장 사항]
```

### 3. Recent Error Search (빈 입력 시)

프로젝트에서 최근 에러 검색:

```bash
# Node.js
npm run build 2>&1 | tail -50
npm test 2>&1 | grep -A5 "FAIL\|Error"

# Python
python -m pytest 2>&1 | grep -A5 "FAILED\|Error"

# 로그 파일 검색
find . -name "*.log" -mtime -1 -exec tail -20 {} \;
```

---

## Common Error Patterns

### JavaScript/TypeScript

| 에러 | 원인 | 해결 |
|------|------|------|
| `TypeError: Cannot read property 'x' of undefined` | null/undefined 접근 | Optional chaining (?.) 사용 |
| `ReferenceError: x is not defined` | 변수 미선언 | import 또는 선언 확인 |
| `SyntaxError: Unexpected token` | 문법 오류 | 괄호/따옴표 확인 |

### Python

| 에러 | 원인 | 해결 |
|------|------|------|
| `AttributeError: 'NoneType'` | None 객체 접근 | None 체크 추가 |
| `ImportError: No module named` | 모듈 미설치 | pip install 실행 |
| `KeyError: 'x'` | 딕셔너리 키 없음 | .get() 또는 키 확인 |

### Database

| 에러 | 원인 | 해결 |
|------|------|------|
| `Connection refused` | DB 서버 미실행 | 서버 시작 확인 |
| `Duplicate entry` | 중복 키 | UPSERT 또는 체크 추가 |
| `Deadlock` | 트랜잭션 충돌 | 락 순서 조정 |

---

## Debugging Strategies

### 1. Reproduce
- 에러 재현 가능한가?
- 특정 조건에서만 발생하는가?

### 2. Isolate
- 어느 코드에서 발생하는가?
- 최소 재현 케이스는?

### 3. Inspect
- 변수 값 확인 (console.log, print, debugger)
- 스택 트레이스 분석

### 4. Fix & Verify
- 수정 후 테스트
- 유사 케이스 확인

---

## Output Format

```markdown
## 🐛 Debug Report

### Error
[에러 메시지]

### Analysis
- **Type**: [에러 타입]
- **Location**: [파일:라인]
- **Cause**: [원인]

### Solution
1. [단계별 해결 방법]

### Code Fix
\`\`\`[language]
// Before
[기존 코드]

// After
[수정된 코드]
\`\`\`

### Prevention
- [재발 방지 방법]
```

---

## Examples

```bash
/debug TypeError: Cannot read property 'name' of undefined
/debug ./logs/app.log
/debug                    # 최근 에러 검색
```
