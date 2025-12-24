---
name: refactoring
description: This skill should be used when the user asks about "refactoring code", "code smells", "clean code", "code quality improvement", "design patterns", "SOLID principles", "extract method", "reducing complexity", or needs help restructuring code. Also triggered by Korean phrases like "리팩토링", "코드 개선", "코드 정리", "복잡도 줄이기", "클린 코드", "디자인 패턴", "코드 스멜".
---

# Refactoring Guide

코드 리팩토링 패턴, 전략, 안전한 변환 기법 가이드.

## Refactoring Fundamentals

### What is Refactoring?

> "외부 동작을 바꾸지 않으면서 내부 구조를 개선하는 것"
> — Martin Fowler

**리팩토링 목적**:
- 가독성 향상
- 유지보수성 개선
- 확장성 확보
- 버그 예방

**리팩토링이 아닌 것**:
- 기능 추가
- 버그 수정
- 성능 최적화 (별도 작업)

### When to Refactor

**리팩토링 시점**:
| 상황 | 신호 |
|------|------|
| 기능 추가 전 | 구조가 추가를 어렵게 할 때 |
| 버그 수정 후 | 버그 원인이 복잡한 코드일 때 |
| 코드 리뷰 시 | 개선점이 발견되었을 때 |
| 이해하기 어려울 때 | 코드를 읽기 위해 해석이 필요할 때 |

---

## Code Smells

### Bloaters (비대화)

**Long Method (긴 메서드)**:
```javascript
// Bad: 50+ 줄 함수
function processOrder(order) {
  // 검증 20줄
  // 계산 15줄
  // 저장 15줄
}

// Good: 분리된 함수
function processOrder(order) {
  validate(order);
  calculate(order);
  save(order);
}
```

**Large Class (큰 클래스)**:
- 하나의 클래스가 너무 많은 책임
- 해결: 클래스 분리, 역할 분리

**Long Parameter List (긴 매개변수)**:
```python
# Bad
def send_email(to, cc, bcc, subject, body, attachments, priority, reply_to):
    pass

# Good
@dataclass
class EmailConfig:
    to: str
    subject: str
    body: str
    cc: str = None
    bcc: str = None
    attachments: list = None
    priority: str = "normal"
    reply_to: str = None

def send_email(config: EmailConfig):
    pass
```

### Object-Orientation Abusers

**Switch Statements**:
```typescript
// Bad
function getDiscount(type: string): number {
  switch (type) {
    case 'gold': return 0.3;
    case 'silver': return 0.2;
    case 'bronze': return 0.1;
    default: return 0;
  }
}

// Good: 다형성
interface Customer {
  getDiscount(): number;
}
class GoldCustomer implements Customer {
  getDiscount() { return 0.3; }
}
```

### Change Preventers

**Divergent Change (발산적 변경)**:
- 하나의 클래스가 여러 이유로 변경됨
- 해결: 단일 책임 원칙 적용

**Shotgun Surgery (산탄총 수술)**:
- 하나의 변경이 여러 클래스에 영향
- 해결: 관련 코드 모으기

---

## SOLID Principles

### S - Single Responsibility

```javascript
// Bad: 여러 책임
class User {
  save() { /* DB 저장 */ }
  sendEmail() { /* 이메일 전송 */ }
  generateReport() { /* 리포트 생성 */ }
}

// Good: 단일 책임
class User { /* 사용자 데이터만 */ }
class UserRepository { save(user) { /* DB */ } }
class EmailService { send(user) { /* 이메일 */ } }
class ReportGenerator { generate(user) { /* 리포트 */ } }
```

### O - Open/Closed

```python
# Bad: 확장 시 수정 필요
class AreaCalculator:
    def calculate(self, shape):
        if shape.type == "circle":
            return 3.14 * shape.radius ** 2
        elif shape.type == "rectangle":
            return shape.width * shape.height

# Good: 확장에 열려있고 수정에 닫혀있음
class Shape(ABC):
    @abstractmethod
    def area(self) -> float:
        pass

class Circle(Shape):
    def area(self):
        return 3.14 * self.radius ** 2

class Rectangle(Shape):
    def area(self):
        return self.width * self.height
```

### L - Liskov Substitution

```typescript
// 하위 클래스는 상위 클래스를 대체할 수 있어야 함
class Bird {
  fly(): void { /* 비행 */ }
}

// Bad: 펭귄은 날 수 없음
class Penguin extends Bird {
  fly(): void { throw new Error("Can't fly"); }
}

// Good: 인터페이스 분리
interface Flyable { fly(): void; }
interface Swimmable { swim(): void; }

class Sparrow implements Flyable { /* ... */ }
class Penguin implements Swimmable { /* ... */ }
```

### I - Interface Segregation

```typescript
// Bad: 뚱뚱한 인터페이스
interface Worker {
  work(): void;
  eat(): void;
  sleep(): void;
}

// Good: 분리된 인터페이스
interface Workable { work(): void; }
interface Eatable { eat(): void; }
interface Sleepable { sleep(): void; }

class Human implements Workable, Eatable, Sleepable { /* ... */ }
class Robot implements Workable { /* ... */ }
```

### D - Dependency Inversion

```python
# Bad: 구체 클래스 의존
class OrderService:
    def __init__(self):
        self.db = MySQLDatabase()  # 구체 클래스

# Good: 추상화 의존
class OrderService:
    def __init__(self, db: Database):  # 인터페이스
        self.db = db
```

---

## Common Refactoring Patterns

### Extract Method

```javascript
// Before
function printOwing() {
  printBanner();

  // 상세 정보 출력
  console.log('name: ' + name);
  console.log('amount: ' + getOutstanding());
}

// After
function printOwing() {
  printBanner();
  printDetails();
}

function printDetails() {
  console.log('name: ' + name);
  console.log('amount: ' + getOutstanding());
}
```

### Replace Magic Number

```python
# Before
if speed > 120:
    issue_ticket()

# After
SPEED_LIMIT = 120

if speed > SPEED_LIMIT:
    issue_ticket()
```

### Replace Temp with Query

```javascript
// Before
const basePrice = quantity * itemPrice;
if (basePrice > 1000) {
  return basePrice * 0.95;
}

// After
function basePrice() {
  return quantity * itemPrice;
}

if (basePrice() > 1000) {
  return basePrice() * 0.95;
}
```

### Introduce Explaining Variable

```javascript
// Before
if (platform.toUpperCase().includes('MAC') &&
    browser.toUpperCase().includes('SAFARI') &&
    wasInitialized && resize > 0) {
  // ...
}

// After
const isMacSafari = platform.toUpperCase().includes('MAC') &&
                    browser.toUpperCase().includes('SAFARI');
const canResize = wasInitialized && resize > 0;

if (isMacSafari && canResize) {
  // ...
}
```

---

## Safe Refactoring Checklist

리팩토링 전:
- [ ] 테스트 코드 존재 확인
- [ ] 모든 테스트 통과 확인
- [ ] 버전 관리 상태 확인 (clean working tree)

리팩토링 중:
- [ ] 작은 단위로 변경
- [ ] 각 변경 후 테스트 실행
- [ ] 자주 커밋

리팩토링 후:
- [ ] 모든 테스트 통과
- [ ] 코드 리뷰 요청
- [ ] 문서 업데이트 (필요시)

---

## Quick Reference

```bash
/refactor [파일]           # 특정 파일 분석
/refactor [패턴]          # 코드 패턴 검색 및 분석
/refactor                 # 최근 변경 파일 분석
```

### 복잡도 기준

| 지표 | 양호 | 경고 | 위험 |
|------|------|------|------|
| 함수 길이 | <20줄 | 20-50줄 | >50줄 |
| 매개변수 | <4개 | 4-6개 | >6개 |
| 조건 깊이 | <3 | 3-5 | >5 |
| 순환 복잡도 | <10 | 10-20 | >20 |
