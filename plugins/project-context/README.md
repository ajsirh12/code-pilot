# project-context

프로젝트 컨텍스트 관리 플러그인. CLAUDE.md를 통해 세션 간 프로젝트 상태를 유지.

## 기능

- **CLAUDE.md 템플릿**: 프로젝트 타입별 템플릿 제공
- **3-Section 구조**: Context(불변), Status(가변), Knowledge(축적)
- **3-Phase 모델**: Build, Ship, Maintain

## 설치

```bash
/plugin install project-context
```

## 사용법

### 초기화

```bash
/init-context           # 자동 분석 (권장)
/init-context webapp    # 웹앱 템플릿 강제 사용
/init-context api       # API 서버 템플릿
/init-context library   # 라이브러리 템플릿
```

### 자동 분석 기능

`/init-context` (인자 없이) 실행 시:

1. 프로젝트 메타데이터 읽기 (package.json, pyproject.toml 등)
2. 기술 스택 감지 (React, TypeScript, FastAPI 등)
3. 디렉토리 구조 파악 (src/, components/, pages/ 등)
4. 사용자에게 "목적"만 질문
5. CLAUDE.md 자동 생성

### CLAUDE.md 구조

```markdown
# Project: [프로젝트명]

## Context
- 목적: 프로젝트 설명
- 스택: 기술 스택
- 규칙: 코드 컨벤션

## Status
- Phase: Build | Ship | Maintain
- Focus: 현재 작업
- Next: 다음 작업
- Blocked: 막힌 것

## Knowledge
- [날짜]: 중요 결정 기록
```

## 워크플로우

1. `/init-context`로 CLAUDE.md 생성
2. Context 섹션 채우기 (1회)
3. 매 세션 종료 시 Status 업데이트 (30초)
4. 중요 결정 시 Knowledge에 추가

## 다른 플러그인과 연계

| 플러그인 | 역할 |
|---------|------|
| project-context | 상태/컨텍스트 관리 |
| hookify | 코드 규칙 강제 |
| feature-dev | 기능 개발 워크플로우 |
