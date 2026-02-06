# Changelog

All notable changes to Code Pilot plugins will be documented in this file.

## [2026-02-06] - Chrome DevTools Integration

### Added

#### chrome-devtools
Chrome DevTools MCP 서버 - AI 코딩 어시스턴트가 Chrome 브라우저를 제어하고 검사

**출처:** [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) (Google 공식)

**버전:** 0.16.0

**주요 기능:**
- **성능 인사이트**: Chrome DevTools를 사용해 성능 트레이스 기록 및 분석
- **고급 브라우저 디버깅**: 네트워크 요청 분석, 스크린샷, 콘솔 메시지 (소스맵 스택 트레이스)
- **신뢰성 있는 자동화**: Puppeteer 기반 브라우저 제어

**도구 (26개):**
| 카테고리 | 도구 |
|----------|------|
| Input automation (8) | `click`, `drag`, `fill`, `fill_form`, `handle_dialog`, `hover`, `press_key`, `upload_file` |
| Navigation (6) | `close_page`, `list_pages`, `navigate_page`, `new_page`, `select_page`, `wait_for` |
| Emulation (2) | `emulate`, `resize_page` |
| Performance (3) | `performance_analyze_insight`, `performance_start_trace`, `performance_stop_trace` |
| Network (2) | `get_network_request`, `list_network_requests` |
| Debugging (5) | `evaluate_script`, `get_console_message`, `list_console_messages`, `take_screenshot`, `take_snapshot` |

**사용법:**
```
# 성능 분석
"Check the performance of https://example.com"

# 스크린샷 촬영
"Take a screenshot of the current page"

# 네트워크 요청 분석
"List all network requests on this page"

# 콘솔 메시지 확인
"Show me the console messages"
```

**설정 옵션:**
- `--headless` - 헤드리스 모드 (UI 없음)
- `--browser-url` - 실행 중인 Chrome 인스턴스에 연결
- `--autoConnect` - Chrome 144+ 자동 연결
- `--isolated` - 임시 사용자 데이터 디렉토리 사용

---

## [2026-02-02] - Figma Integration

### Added

#### figma
Figma MCP 서버 통합 - 디자인을 코드로 변환하는 워크플로우

**출처:** [figma/mcp-server-guide](https://github.com/figma/mcp-server-guide)

**MCP 서버:**
| 서버 | URL |
|------|-----|
| `figma` | `https://mcp.figma.com/mcp` |
| `figma-desktop` | `http://127.0.0.1:3845/mcp` |

**Skills:**
- `/implement-design` - Figma 디자인을 pixel-perfect 코드로 변환
- `/create-design-system-rules` - 프로젝트별 디자인 시스템 규칙 생성
- `/code-connect-components` - Figma 컴포넌트와 코드 컴포넌트 연결

**사용법:**
```
# Figma 디자인 구현
"Implement this Figma design: https://figma.com/design/.../...?node-id=42-15"

# 디자인 시스템 규칙 생성
"Create design system rules for my React project"

# Code Connect 설정
"Connect this Figma component to code: [URL]"
```

**사전 설정:**
- Remote 서버: 별도 설정 없음 (OAuth 인증)
- Desktop 서버: Figma 데스크톱 앱에서 Dev Mode > MCP server 활성화

---

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
