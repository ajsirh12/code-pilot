# Changelog

All notable changes to Code Pilot plugins will be documented in this file.

## [2026-02-02] - Plugin Expansion

### Added - 9 New Plugins from Official Repository

#### Official Plugins

##### claude-code-setup
코드베이스 분석 후 Claude Code 자동화 추천 (훅, 스킬, MCP 서버, 서브에이전트)

**사용법:**
```
"recommend automations for this project"
"help me set up Claude Code"
"what hooks should I use?"
```

---

##### claude-md-management
CLAUDE.md 파일 관리 - 품질 감사 및 세션 학습 캡처

**사용법:**
```bash
# 세션 학습 캡처
/revise-claude-md

# CLAUDE.md 품질 감사
"audit my CLAUDE.md files"
"check if my CLAUDE.md is up to date"
```

---

##### playground
인터랙티브 HTML 플레이그라운드 생성 (디자인, 데이터 탐색, 컨셉맵, 문서 리뷰)

**사용법:**
```
"create a design playground for this component"
"build a data explorer for this API"
"make a concept map playground for learning React"
```

**템플릿:**
- `design-playground` - 컴포넌트, 레이아웃, 색상, 타이포그래피
- `data-explorer` - SQL, API, 파이프라인, 정규식
- `concept-map` - 학습, 지식 갭, 스코프 매핑
- `document-critique` - 문서 리뷰 (승인/거절/코멘트)

---

#### External MCP Integrations

##### asana
Asana 프로젝트 관리 연동

**사전 설정:**
- Asana 계정 연결 필요 (OAuth)

**사용법:**
```
"show my Asana tasks"
"create a task in Asana: Fix login bug"
"list projects in Asana"
```

---

##### context7
Upstash Context7 - 최신 문서 조회 MCP 서버

**사용법:**
```
"look up React 19 documentation"
"find the latest Next.js API routes docs"
"get TypeScript 5.4 release notes"
```

---

##### slack
Slack 워크스페이스 연동

**사전 설정:**
- Slack 계정 연결 필요 (OAuth)

**사용법:**
```
"search Slack for deployment issues"
"show recent messages in #engineering"
"find the thread about API redesign"
```

---

##### supabase
Supabase MCP 서버 (DB, 인증, 스토리지, 실시간 구독)

**사전 설정:**
- Supabase 계정 연결 필요

**사용법:**
```
"run this SQL query on Supabase"
"list tables in my Supabase project"
"show Supabase auth users"
```

---

##### greptile
AI 코드 리뷰 에이전트 (GitHub/GitLab PR 리뷰)

**사전 설정:**
```bash
export GREPTILE_API_KEY="your-api-key"
```

**사용법:**
```
"show Greptile review comments on this PR"
"resolve Greptile comment #123"
```

---

##### firebase
Google Firebase MCP 서버 (Firestore, 인증, Cloud Functions, 호스팅)

**사전 설정:**
- Firebase CLI 로그인 필요: `firebase login`

**사용법:**
```
"list Firestore collections"
"show Firebase auth users"
"deploy to Firebase hosting"
"list Cloud Functions"
```

---

### Changed

#### Author 정보 통일
기존 플러그인의 Anthropic 이메일을 `deekee (burlesquer@yonsei.ac.kr)`로 변경:
- `code-review`
- `commit-commands`
- `agent-sdk-dev`

---

## [2026-01-22] - TDD Plugin

### Added
- `tdd` - Test-Driven Development 가이드 (레드-그린-리팩터 사이클)

---

## [2026-01-19] - Playwright & GitLab

### Added
- `playwright` - Microsoft Playwright MCP 서버 (브라우저 자동화, E2E 테스팅)
- `gitlab` - GitLab MCP 서버 (이슈, MR, 파이프라인, 위키, 마일스톤)
