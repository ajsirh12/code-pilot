---
name: project-context
description: This skill should be used when the user asks about "CLAUDE.md structure", "project context", "project state management", "session continuity", "how to track project progress", "init context", or mentions maintaining context across sessions. Also triggered by Korean phrases like "프로젝트 컨텍스트", "CLAUDE.md 작성", "세션 간 컨텍스트", "프로젝트 상태 관리".
---

# Project Context Management

CLAUDE.md를 활용한 프로젝트 컨텍스트 관리 가이드.

## Core Structure

CLAUDE.md는 3가지 섹션으로 구성:

```markdown
# Project: [프로젝트명]

## Context (불변)
프로젝트가 뭔지 - 초기 1회 작성, 거의 수정 없음

## Status (가변)
지금 뭐하는지 - 세션마다 업데이트

## Knowledge (축적)
알게 된 것들 - 중요 결정만 한 줄씩 추가
```

### Context Section

프로젝트의 핵심 정보. 거의 변경되지 않음:

```markdown
## Context
- 목적: 한 줄로 프로젝트 설명
- 스택: 사용 기술 나열
- 규칙: 코드 컨벤션, 디렉토리 구조
- 문서: 상세 문서 위치 (있다면)
```

### Status Section

현재 작업 상태. 세션 끝날 때 30초면 업데이트:

```markdown
## Status
- Phase: Build | Ship | Maintain
- Focus: 현재 작업 중인 것
- Next: 다음에 할 것
- Blocked: 막힌 것 (있다면)
```

### Knowledge Section

프로젝트 진행하며 축적된 결정/학습. 로그처럼 추가:

```markdown
## Knowledge
- 2024-01: OAuth는 Keycloak 사용 결정
- 2024-02: 성능 이슈로 Redis 캐시 도입
- 2024-03: API v2 마이그레이션 완료
```

## Phase Model

프로젝트 단계는 3개로 단순화:

| Phase | 설명 | 주요 활동 |
|-------|------|----------|
| **Build** | 기능 개발 중 | 구현, 테스트, 리팩토링 |
| **Ship** | 배포/릴리즈 준비 | 빌드, 배포, 릴리즈 노트 |
| **Maintain** | 운영/개선 | 버그픽스, 모니터링, 최적화 |

대부분의 시간은 Build 단계에서 보냄.

## When to Update

### 매 세션 시작 시
- Status 섹션 확인하여 현재 상태 파악
- Claude가 자동으로 CLAUDE.md 읽음

### 매 세션 종료 시
- Status의 Focus/Next 업데이트
- 중요 결정 있었다면 Knowledge에 추가

### Phase 변경 시
- Build → Ship: 릴리즈 준비 시작
- Ship → Maintain: 배포 완료 후
- Maintain → Build: 새 기능 개발 시작

## Templates

프로젝트 타입별 템플릿 사용:

- **base**: 범용 기본 템플릿
- **webapp**: 프론트엔드/풀스택 웹앱
- **api**: 백엔드 API 서버
- **library**: 라이브러리/패키지

`/init-context` 명령으로 초기화 가능.

## Best Practices

### DO
- Status는 4줄 이내로 짧게
- Knowledge는 날짜 + 한 줄 요약
- Context는 처음에 잘 작성하고 거의 안 건드림

### DON'T
- 상세 기획서를 CLAUDE.md에 넣지 않음 → docs/ 폴더에
- 코드 규칙을 장황하게 쓰지 않음 → hookify 사용
- 모든 변경사항을 Knowledge에 기록 → 중요 결정만

## Integration with Other Plugins

| 플러그인 | 역할 |
|---------|------|
| **project-context** | 상태/컨텍스트 관리 |
| **hookify** | 코드 규칙 강제 |
| **feature-dev** | 기능 개발 워크플로우 |

## Example CLAUDE.md

```markdown
# Project: 사용자 인증 시스템

## Context
- 목적: OAuth 기반 SSO 인증 시스템
- 스택: Node.js, Express, PostgreSQL, Redis
- 규칙: ESLint Airbnb, Conventional Commits
- 문서: docs/ARCHITECTURE.md

## Status
- Phase: Build
- Focus: 토큰 갱신 로직 구현
- Next: 세션 만료 처리
- Blocked: -

## Knowledge
- 2024-01: Keycloak 선정 (vs Auth0 - 비용 이슈)
- 2024-02: Redis 세션 저장소 도입
- 2024-03: JWT 대신 opaque token 사용 결정
```

## Quick Reference

```
/init-context          # CLAUDE.md 템플릿 생성
/init-context webapp   # 웹앱 템플릿으로 생성
```

템플릿 위치: `${CLAUDE_PLUGIN_ROOT}/skills/project-context/templates/`
