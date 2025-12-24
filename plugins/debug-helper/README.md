# debug-helper

에러 분석, 로그 파싱, 디버깅 가이드 플러그인.

## 기능

- **에러 분석**: 에러 메시지 분석 및 해결책 제시
- **로그 파싱**: 로그 파일에서 에러/경고 추출 및 패턴 분석
- **디버깅 가이드**: 언어별 디버깅 전략 제공
- **코드 추적**: 스택 트레이스 기반 코드 분석

## 지원 언어

- JavaScript/TypeScript
- Python
- Java
- Go
- Rust
- 기타 (일반 에러 패턴)

## 사용법

### 명령어

```bash
/debug TypeError: Cannot read property 'name' of undefined
/debug ./logs/app.log
/debug                    # 최근 에러 검색
```

### 에이전트

`error-analyzer` - 심층 에러 분석이 필요할 때:
- 스택 트레이스 추적
- 코드 컨텍스트 분석
- 근본 원인 파악
- 수정 제안

## 출력 예시

```markdown
## 🐛 Debug Report

### Error
TypeError: Cannot read property 'name' of undefined

### Analysis
- **Type**: TypeError
- **Location**: src/user.js:42
- **Cause**: user 객체가 null인 상태에서 .name 접근

### Solution
1. Optional chaining 사용: user?.name
2. Null 체크 추가: if (user) { ... }

### Code Fix
// Before
const name = user.name;

// After
const name = user?.name ?? 'Unknown';
```

## 관련 플러그인

| 플러그인 | 역할 |
|---------|------|
| debug-helper | 에러 분석/디버깅 |
| code-quality | 코드 리뷰 |
| dependency-check | 의존성 취약점 |
