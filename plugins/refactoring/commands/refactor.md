---
description: Analyze code and suggest refactoring improvements
argument-hint: "[file path or code pattern to refactor]"
allowed-tools: ["Read", "Bash", "Glob", "Grep", "TodoWrite", "Edit"]
---

# Refactor Command

코드 분석 및 리팩토링 개선점 제안.

## Input Detection

Parse from: $ARGUMENTS

| 입력 타입 | 감지 방법 | 동작 |
|----------|----------|------|
| 파일 경로 | 확장자 포함 경로 | 해당 파일 리팩토링 분석 |
| 패턴/키워드 | 함수명, 클래스명 등 | 코드베이스에서 검색 후 분석 |
| 빈 입력 | 인자 없음 | 최근 변경 파일 분석 |

---

## Workflow

### 1. Code Discovery

입력에 따른 코드 탐색:

```bash
# 파일 경로인 경우
Read [file_path]

# 패턴인 경우
Grep pattern --type [language]

# 빈 입력인 경우
git diff --name-only HEAD~5
```

### 2. Code Analysis

분석 항목:

**복잡도 분석**:
- 함수 길이 (>30줄 경고)
- 조건문 깊이 (>3 경고)
- 매개변수 수 (>4 경고)
- 순환 복잡도

**코드 스멜 감지**:
- 중복 코드
- 긴 메서드
- 큰 클래스
- 긴 매개변수 목록
- 데이터 뭉치
- 기능 편애
- 산탄총 수술

**패턴 위반**:
- 단일 책임 원칙 (SRP)
- 개방-폐쇄 원칙 (OCP)
- 리스코프 치환 원칙 (LSP)
- 인터페이스 분리 원칙 (ISP)
- 의존성 역전 원칙 (DIP)

### 3. Refactoring Suggestions

제안 형식:

```markdown
## Refactoring Report

### Summary
- **File**: [파일명]
- **Issues Found**: [개수]
- **Priority**: [High/Medium/Low]

### Issues

#### 1. [이슈 제목]
- **Type**: [Code Smell / Complexity / Pattern Violation]
- **Location**: [file:line]
- **Severity**: [High/Medium/Low]

**Problem**:
[문제 설명]

**Current Code**:
\`\`\`[language]
// 현재 코드
\`\`\`

**Suggested Fix**:
\`\`\`[language]
// 개선된 코드
\`\`\`

**Why This Helps**:
[개선 이유]

### Refactoring Priority
1. [가장 중요한 변경]
2. [다음 중요한 변경]
...
```

---

## Refactoring Patterns

### Extract Method

긴 함수를 작은 함수로 분리:

```javascript
// Before
function processOrder(order) {
  // 검증 로직 20줄
  // 가격 계산 15줄
  // 저장 10줄
}

// After
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order);
  saveOrder(order, total);
}
```

### Replace Conditional with Polymorphism

복잡한 조건문을 다형성으로:

```javascript
// Before
function getSpeed(vehicle) {
  switch (vehicle.type) {
    case 'car': return vehicle.speed * 1.0;
    case 'bike': return vehicle.speed * 0.8;
    case 'truck': return vehicle.speed * 0.6;
  }
}

// After
class Vehicle { getSpeed() { return this.speed; } }
class Car extends Vehicle { getSpeed() { return this.speed * 1.0; } }
class Bike extends Vehicle { getSpeed() { return this.speed * 0.8; } }
```

### Introduce Parameter Object

긴 매개변수를 객체로:

```python
# Before
def create_user(name, email, age, address, phone, role):
    pass

# After
@dataclass
class UserData:
    name: str
    email: str
    age: int
    address: str
    phone: str
    role: str

def create_user(user_data: UserData):
    pass
```

---

## Safe Refactoring Steps

리팩토링 안전 수칙:

1. **테스트 먼저** - 리팩토링 전 테스트 확인
2. **작은 단위** - 한 번에 하나씩 변경
3. **자주 실행** - 변경 후 테스트 실행
4. **커밋 분리** - 각 리팩토링마다 커밋

```bash
# 테스트 확인
npm test

# 리팩토링 수행
# ... 코드 변경 ...

# 테스트 재실행
npm test

# 통과 시 커밋
git commit -m "refactor: extract validation logic"
```

---

## Output Format

```markdown
## 🔧 Refactoring Analysis

### Overview
- **Target**: [파일/패턴]
- **Lines Analyzed**: [N]
- **Issues Found**: [N]

### Top Issues

| Priority | Issue | Location | Type |
|----------|-------|----------|------|
| High | [설명] | [file:line] | [타입] |

### Detailed Analysis
[각 이슈별 상세 분석 및 수정 제안]

### Quick Wins
1. [즉시 적용 가능한 개선]

### Recommended Order
1. [첫 번째 리팩토링]
2. [두 번째 리팩토링]
...
```

---

## Examples

```bash
/refactor src/services/user.js     # 특정 파일 분석
/refactor UserService              # 패턴 검색 후 분석
/refactor                          # 최근 변경 파일 분석
```
