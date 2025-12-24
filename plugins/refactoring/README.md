# refactoring

코드 리팩토링 분석, 패턴 제안, 안전한 변환 가이드 플러그인.

## 기능

- **코드 분석**: 복잡도, 코드 스멜, SOLID 위반 감지
- **리팩토링 제안**: 구체적인 개선 방안 및 코드 예시
- **안전한 변환**: 단계별 리팩토링 로드맵
- **패턴 적용**: 디자인 패턴 적용 가이드

## 지원 언어

- JavaScript/TypeScript
- Python
- Java
- Go
- C#
- 기타 (일반 리팩토링 원칙)

## 사용법

### 명령어

```bash
/refactor src/services/user.js     # 특정 파일 분석
/refactor UserService              # 패턴 검색 후 분석
/refactor                          # 최근 변경 파일 분석
```

### 에이전트

`refactoring-advisor` - 심층 리팩토링 분석이 필요할 때:
- 코드베이스 구조 분석
- 의존성 매핑
- 단계별 리팩토링 로드맵
- 리스크 평가

## 감지 항목

### 코드 스멜

| 스멜 | 설명 | 해결책 |
|------|------|--------|
| Long Method | 50줄 이상 함수 | Extract Method |
| Large Class | 300줄 이상 클래스 | Extract Class |
| Long Parameter List | 5개 이상 매개변수 | Parameter Object |
| Duplicate Code | 중복 코드 | Extract Method/Class |
| Feature Envy | 다른 클래스 메서드 과다 사용 | Move Method |

### SOLID 원칙

| 원칙 | 위반 신호 | 권장 사항 |
|------|----------|----------|
| SRP | 클래스가 여러 이유로 변경됨 | 책임 분리 |
| OCP | 확장 시 기존 코드 수정 필요 | 추상화 도입 |
| LSP | 하위 클래스가 상위와 다르게 동작 | 인터페이스 분리 |
| ISP | 사용하지 않는 메서드 구현 강제 | 인터페이스 세분화 |
| DIP | 구체 클래스에 직접 의존 | 의존성 주입 |

## 출력 예시

```markdown
## 🔧 Refactoring Analysis

### Overview
- **Target**: src/services/order.js
- **Health Score**: 65/100
- **Critical Issues**: 2

### Top Issues

| Priority | Issue | Location | Type |
|----------|-------|----------|------|
| Critical | God Class | order.js | Architecture |
| High | Long Method | order.js:45-120 | Complexity |
| Medium | Magic Numbers | order.js:23,67,89 | Maintainability |

### Recommended Actions
1. Extract OrderValidator class
2. Split processOrder into smaller methods
3. Define constants for magic numbers

### Refactoring Roadmap
Phase 1: Extract constants (Low Risk)
Phase 2: Extract methods (Medium Risk)
Phase 3: Split class (Higher Risk)
```

## 복잡도 기준

| 지표 | 양호 | 경고 | 위험 |
|------|------|------|------|
| 함수 길이 | <20줄 | 20-50줄 | >50줄 |
| 클래스 크기 | <200줄 | 200-400줄 | >400줄 |
| 매개변수 | <4개 | 4-6개 | >6개 |
| 조건 깊이 | <3 | 3-5 | >5 |
| 순환 복잡도 | <10 | 10-20 | >20 |

## 관련 플러그인

| 플러그인 | 역할 |
|---------|------|
| refactoring | 구조 개선/리팩토링 |
| debug-helper | 에러 분석/디버깅 |
| code-quality | 코드 리뷰 |
