# TDD Plugin

Test-Driven Development (TDD) 방법론 가이드 플러그인입니다. 테스트 우선 개발 원칙과 레드-그린-리팩터 사이클을 지원합니다.

## Overview

TDD 플러그인은 테스트 주도 개발 방법론을 Claude Code에 통합하여, 코드 작성 전에 테스트를 먼저 작성하는 원칙을 지원합니다.

**핵심 기능:**
- 🔴 **RED**: 실패하는 테스트 먼저 작성
- 🟢 **GREEN**: 최소한의 코드로 테스트 통과
- 🔵 **REFACTOR**: 테스트 통과 상태에서 코드 개선

## Skill

### test-driven-development

자동으로 트리거되는 상황:
- "TDD", "test-driven development" 언급
- "write tests first", "테스트 먼저" 요청
- "red-green-refactor", "레드-그린-리팩터" 언급
- "failing test", "실패하는 테스트" 관련 질문

**제공하는 내용:**
- TDD Iron Law: 테스트 없이 프로덕션 코드 작성 금지
- Red-Green-Refactor 사이클 가이드
- 테스트 안티패턴 및 회피 방법
- Mock vs Fake vs Stub 사용 가이드
- 검증 체크리스트

## Usage

TDD 관련 키워드를 사용하면 자동으로 스킬이 활성화됩니다:

```
User: TDD 방식으로 사용자 인증 기능을 구현해줘
Claude: [TDD 스킬 자동 로드] 먼저 인증 기능에 대한 실패하는 테스트를 작성하겠습니다...
```

```
User: How do I write tests first?
Claude: [TDD 스킬 자동 로드] TDD의 핵심 원칙을 설명드리겠습니다...
```

## The Iron Law

> **NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST**

이 원칙에 예외는 없습니다. 테스트 없이 작성된 코드는 삭제하고 TDD 방식으로 다시 구현해야 합니다.

## Red-Green-Refactor Cycle

| Phase | Action | Verify |
|-------|--------|--------|
| 🔴 RED | 실패하는 테스트 작성 | 올바른 이유로 실패 확인 |
| 🟢 GREEN | 최소한의 코드로 통과 | 모든 테스트 통과 확인 |
| 🔵 REFACTOR | 코드 정리 | 테스트 여전히 통과 확인 |

## Reference Files

상세한 테스트 안티패턴 정보:
- `skills/test-driven-development/references/testing-anti-patterns.md`

## Structure

```
tdd/
└── skills/
    └── test-driven-development/
        ├── SKILL.md                    # 메인 TDD 스킬
        └── references/
            └── testing-anti-patterns.md  # 테스트 안티패턴 가이드
```

## Installation

이 플러그인은 Code Pilot 마켓플레이스에 포함되어 있습니다.