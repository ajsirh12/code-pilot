# Code Pilot

TePS'EG 팀을 위한 Claude Code 플러그인 컬렉션입니다.

## 설치

GitLab에서 플러그인 마켓플레이스 추가:

```bash
/plugin marketplace add https://github.com/ajsirh12/code-pilot
```

## 업데이트

```bash
/plugin marketplace update https://github.com/ajsirh12/code-pilot
```

## 플러그인 목록

자세한 내용은 [plugins 디렉토리](./plugins/README.md)를 참고하세요.

### Development
- `tdd` - Test-Driven Development (테스트 우선 개발, 레드-그린-리팩터)
- `feature-dev` - 기능 개발 워크플로우
- `frontend-design` - 프론트엔드 디자인 스킬
- `plugin-dev` - 플러그인 개발 도구 (스킬 생성 가이드 포함)
- `mcp-builder` - MCP 서버 개발 가이드 (Python/Node)
- `agent-sdk-dev` - Agent SDK 개발 툴킷
- `webapp-testing` - 웹앱 테스팅 (Playwright)
- `playwright` - 브라우저 자동화 및 E2E 테스팅 MCP 서버 (Microsoft)
- `web-artifacts-builder` - React/Tailwind 아티팩트 빌더
- `refactoring` - 코드 리팩토링 (패턴, 전략, 안전한 변환)
- `debug-helper` - 디버그 도우미 (에러 분석, 로그 파싱)
- `dependency-check` - 의존성 검사 (취약점 체크, 업데이트 추천)
- `playground` - 인터랙티브 HTML 플레이그라운드 생성
- `context7` - Upstash Context7 문서 조회 MCP 서버
- `supabase` - Supabase MCP 서버 (DB, 인증, 스토리지)
- `firebase` - Google Firebase MCP 서버 (Firestore, 인증, 호스팅)

### DevOps
- `gitlab` - GitLab MCP 서버 (이슈, MR, 파이프라인, 위키, 마일스톤)
- `mobile-dev` - 모바일 앱 개발 (빌드 자동화, 스토어 배포)

### Productivity
- `code-quality` - 코드 품질 분석 에이전트 (git diff 기반)
- `code-review` - 자동 PR 코드 리뷰 (GitHub)
- `code-simplifier` - 코드 단순화 에이전트
- `commit-commands` - Git 워크플로우 (커밋, PR)
- `hookify` - 커스텀 훅 생성
- `doc-coauthoring` - 문서 공동 작성
- `project-context` - 프로젝트 컨텍스트 (CLAUDE.md 템플릿 관리)
- `claude-code-setup` - Claude Code 자동화 추천 (훅, 스킬, MCP 등)
- `claude-md-management` - CLAUDE.md 파일 관리 및 세션 학습 캡처
- `asana` - Asana 프로젝트 관리 MCP 서버
- `slack` - Slack 워크스페이스 연동 MCP 서버
- `greptile` - AI 코드 리뷰 에이전트 (GitHub/GitLab)

### Architecture
- `api-designer` - API 아키텍트 (OpenAPI, 엔드포인트 설계, 문서화)
- `db-architect` - DBA (스키마 분석, 쿼리 최적화, 마이그레이션)
- `perf-analyzer` - 성능 분석 (프로파일링, 벤치마크, 병목 탐지)

### Documents
- `docx` - Word 문서 생성/편집
- `pdf` - PDF 생성/편집
- `pptx` - PowerPoint 생성/편집
- `xlsx` - Excel 생성/편집

### Design
- `brand-guidelines` - TePS'EG 브랜드 가이드라인
- `canvas-design` - 캔버스 디자인
- `theme-factory` - 테마 스타일링

### Creative
- `algorithmic-art` - 알고리즘 아트 생성
- `slack-gif-creator` - Slack GIF 생성

### Other
- `explanatory-output-style` - 설명적 출력 스타일
- `learning-output-style` - 학습 출력 스타일
- `ralph-wiggum` - 반복 개발 루프
- `security-guidance` - 보안 가이드 훅
- `internal-comms` - 내부 커뮤니케이션

### LSP (Language Server Protocol)
- `typescript-lsp` - TypeScript/JavaScript
- `pyright-lsp` - Python
- `gopls-lsp` - Go
- `rust-analyzer-lsp` - Rust
- `clangd-lsp` - C/C++
- `jdtls-lsp` - Java
- `kotlin-lsp` - Kotlin
- `csharp-lsp` - C#
- `swift-lsp` - Swift
- `php-lsp` - PHP
- `lua-lsp` - Lua

## 변경 이력

플러그인 추가/변경 이력 및 사용법은 [CHANGELOG.md](./CHANGELOG.md)를 참고하세요.

## 관리자

- **deekee** (burlesquer@yonsei.ac.kr)
