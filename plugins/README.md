# Code Pilot Plugins

TePS'EG 팀을 위한 Claude Code 플러그인 컬렉션입니다. 커스텀 명령어, 에이전트, 워크플로우를 통해 기능을 확장합니다.

## Claude Code 플러그인이란?

Claude Code 플러그인은 커스텀 슬래시 명령어, 전문 에이전트, 훅, MCP 서버로 Claude Code를 확장하는 확장 기능입니다. 프로젝트와 팀 간에 공유하여 일관된 도구와 워크플로우를 제공합니다.

## Plugins in This Directory

| Name | Description | Contents |
|------|-------------|----------|
| [explanatory-output-style](./explanatory-output-style/) | Adds educational insights about implementation choices and codebase patterns (mimics the deprecated Explanatory output style) | **Hook:** SessionStart - Injects educational context at the start of each session |
| [tdd](./tdd/) | Test-Driven Development (TDD) 방법론 가이드 - 테스트 우선 개발, 레드-그린-리팩터 사이클 | **Skill:** `test-driven-development` - TDD 원칙, Iron Law, 안티패턴 가이드 |
| [feature-dev](./feature-dev/) | Comprehensive feature development workflow with a structured 7-phase approach | **Command:** `/feature-dev` - Guided feature development workflow<br>**Agents:** `code-explorer`, `code-architect`, `code-reviewer` - For codebase analysis, architecture design, and quality review |
| [frontend-design](./frontend-design/) | Create distinctive, production-grade frontend interfaces that avoid generic AI aesthetics | **Skill:** `frontend-design` - Auto-invoked for frontend work, providing guidance on bold design choices, typography, animations, and visual details |
| [hookify](./hookify/) | Easily create custom hooks to prevent unwanted behaviors by analyzing conversation patterns or explicit instructions | **Commands:** `/hookify`, `/hookify:list`, `/hookify:configure`, `/hookify:help`<br>**Agent:** `conversation-analyzer` - Analyzes conversations for problematic behaviors<br>**Skill:** `writing-rules` - Guidance on hookify rule syntax |
| [learning-output-style](./learning-output-style/) | Interactive learning mode that requests meaningful code contributions at decision points (mimics the unshipped Learning output style) | **Hook:** SessionStart - Encourages users to write meaningful code (5-10 lines) at decision points while receiving educational insights |
| [plugin-dev](./plugin-dev/) | Comprehensive toolkit for developing Claude Code plugins with 7 expert skills and AI-assisted creation | **Command:** `/plugin-dev:create-plugin` - 8-phase guided workflow for building plugins<br>**Agents:** `agent-creator`, `plugin-validator`, `skill-reviewer`<br>**Skills:** Hook development, MCP integration, plugin structure, settings, commands, agents, and skill development |
| [code-quality](./code-quality/) | Code quality review agents analyzing local git diff. Specializes in comments, tests, error handling, type design, and code simplification | **Command:** `/code-quality:review` - Run with optional review aspects (comments, tests, errors, types, code, simplify, all)<br>**Agents:** `comment-analyzer`, `test-analyzer`, `silent-failure-hunter`, `type-design-analyzer`, `code-reviewer`, `code-simplifier` |
| [ralph-wiggum](./ralph-wiggum/) | Interactive self-referential AI loops for iterative development. Claude works on the same task repeatedly until completion | **Commands:** `/ralph-loop`, `/cancel-ralph` - Start/stop autonomous iteration loops<br>**Hook:** Stop - Intercepts exit attempts to continue iteration |
| [project-context](./project-context/) | Manage project context with CLAUDE.md templates. Track project state, phase, and knowledge across sessions with auto-detect | **Command:** `/init-context` - Initialize CLAUDE.md with project template (supports auto-detect)<br>**Skill:** `project-context` - CLAUDE.md structure guide and update workflow |
| [dependency-check](./dependency-check/) | Analyze project dependencies, check for vulnerabilities, and recommend updates | **Command:** `/check-deps` - Scan dependencies for vulnerabilities and updates<br>**Agent:** `dependency-analyzer` - Deep analysis with risk assessment<br>**Skill:** `dependency-check` - Dependency management guide |
| [debug-helper](./debug-helper/) | Debug assistance with error analysis, log parsing, and debugging strategies | **Command:** `/debug` - Analyze errors, parse logs, find recent errors<br>**Agent:** `error-analyzer` - Deep error analysis with code tracing<br>**Skill:** `debug-helper` - Debugging guide by language |
| [refactoring](./refactoring/) | Code refactoring analysis with patterns, SOLID principles, and safe transformation strategies | **Command:** `/refactor` - Analyze code and suggest improvements<br>**Agent:** `refactoring-advisor` - Comprehensive refactoring roadmap<br>**Skill:** `refactoring` - Refactoring patterns and code smells guide |
| [db-architect](./db-architect/) | DBA 역할의 데이터베이스 전문가 플러그인 - 스키마 분석, 쿼리 최적화, 마이그레이션 생성 | **Commands:** `/analyze-schema`, `/optimize-query`, `/create-migration`, `/detect-n1`<br>**Agents:** `schema-analyzer`, `query-optimizer`<br>**Skills:** `query-optimization`, `migration-patterns` |
| [perf-analyzer](./perf-analyzer/) | 성능 엔지니어 역할의 플러그인 - 프로파일링, 벤치마크, 병목 탐지 | **Commands:** `/profile`, `/benchmark`, `/find-bottlenecks`<br>**Agent:** `performance-analyzer`<br>**Skill:** `profiling-patterns` |
| [api-designer](./api-designer/) | API 아키텍트 역할의 플러그인 - OpenAPI 생성, 엔드포인트 설계, API 문서 자동화 | **Commands:** `/generate-openapi`, `/design-endpoint`, `/generate-docs`, `/generate-mock`<br>**Agent:** `api-architect`<br>**Skill:** `api-patterns` |
| [mobile-dev](./mobile-dev/) | 모바일 전문가 역할의 플러그인 - iOS/Android 빌드 자동화, 스토어 메타데이터 관리 | **Commands:** `/build-app`, `/manage-metadata`, `/setup-signing`, `/deploy-beta`<br>**Agent:** `mobile-specialist`<br>**Skill:** `mobile-patterns` |
| [mcp-builder](./mcp-builder/) | MCP 서버 개발 가이드 - Python (FastMCP) 또는 Node/TypeScript (MCP SDK)로 MCP 서버 구축 | **Skill:** `mcp-builder` - MCP 서버 설계, 구현, 평가 가이드<br>**References:** MCP 베스트 프랙티스, Python/Node 서버 구현 예제<br>**Scripts:** 연결 테스트, 평가 도구 |
| [security-guidance](./security-guidance/) | Security reminder hook that warns about potential security issues when editing files | **Hook:** PreToolUse - Monitors 9 security patterns including command injection, XSS, eval usage, dangerous HTML, and unsafe code patterns |
| [agent-sdk-dev](./agent-sdk-dev/) | Claude Agent SDK development toolkit | **Commands:** `/new-sdk-app` - Create new SDK app<br>**Agents:** `agent-sdk-verifier-py`, `agent-sdk-verifier-ts` - Verify SDK implementations |
| [code-review](./code-review/) | Automated code review for pull requests using specialized agents | **Command:** `/code-review` - Run automated PR review with confidence-based scoring |
| [code-simplifier](./code-simplifier/) | Simplifies and refines code for clarity and maintainability | **Agent:** `code-simplifier` - Simplify code while preserving functionality |
| [commit-commands](./commit-commands/) | Streamline git workflow with simple commands | **Commands:** `/commit`, `/commit-push-pr`, `/clean_gone` - Git workflow automation |
| [clangd-lsp](./clangd-lsp/) | C/C++ language server (clangd) for code intelligence | LSP integration for `.c`, `.h`, `.cpp`, `.hpp` files |
| [csharp-lsp](./csharp-lsp/) | C# language server for code intelligence | LSP integration for `.cs` files |
| [gopls-lsp](./gopls-lsp/) | Go language server for code intelligence | LSP integration for `.go` files |
| [jdtls-lsp](./jdtls-lsp/) | Java language server (Eclipse JDT.LS) | LSP integration for `.java` files |
| [kotlin-lsp](./kotlin-lsp/) | Kotlin language server for code intelligence | LSP integration for `.kt`, `.kts` files |
| [lua-lsp](./lua-lsp/) | Lua language server for code intelligence | LSP integration for `.lua` files |
| [php-lsp](./php-lsp/) | PHP language server (Intelephense) | LSP integration for `.php` files |
| [pyright-lsp](./pyright-lsp/) | Python language server (Pyright) for type checking | LSP integration for `.py`, `.pyi` files |
| [rust-analyzer-lsp](./rust-analyzer-lsp/) | Rust language server for code intelligence | LSP integration for `.rs` files |
| [swift-lsp](./swift-lsp/) | Swift language server (SourceKit-LSP) | LSP integration for `.swift` files |
| [typescript-lsp](./typescript-lsp/) | TypeScript/JavaScript language server | LSP integration for `.ts`, `.tsx`, `.js`, `.jsx` files |
| [playwright](./playwright/) | Browser automation and E2E testing MCP server by Microsoft | MCP server for web interaction, screenshots, form filling, automated testing |
| [gitlab](./gitlab/) | GitLab MCP server for full API integration | MCP server for issues, MRs, pipelines, wikis, milestones (requires `GITLAB_PERSONAL_ACCESS_TOKEN` env var) |
| [claude-code-setup](./claude-code-setup/) | Analyze codebases and recommend tailored Claude Code automations | **Skill:** Recommends hooks, skills, MCP servers, subagents, and slash commands based on codebase analysis |
| [claude-md-management](./claude-md-management/) | Tools to maintain and improve CLAUDE.md files | **Command:** `/revise-claude-md` - Capture session learnings<br>**Skill:** `claude-md-improver` - Audit CLAUDE.md quality |
| [playground](./playground/) | Creates interactive HTML playgrounds with visual controls and live preview | **Skill:** Templates for design-playground, data-explorer, concept-map, document-critique |
| [asana](./asana/) | Asana project management integration | MCP server (SSE) for task management, project search, assignments |
| [context7](./context7/) | Upstash Context7 for up-to-date documentation lookup | MCP server for version-specific docs and code examples from source repos |
| [slack](./slack/) | Slack workspace integration | MCP server (SSE) for message search, channel access, thread reading |
| [supabase](./supabase/) | Supabase MCP integration for database operations | MCP server for Firestore, auth, storage, real-time subscriptions |
| [greptile](./greptile/) | AI code review agent for GitHub and GitLab | MCP server for PR review comments (requires `GREPTILE_API_KEY` env var) |
| [firebase](./firebase/) | Google Firebase MCP integration | MCP server for Firestore, auth, cloud functions, hosting, storage |

## 설치

이 플러그인들은 Code Pilot 마켓플레이스에 포함되어 있습니다.

1. 마켓플레이스 추가:
```bash
/plugin marketplace add http://gitlab.tepseg.com:8087/ai/code-pilot.git
```

2. 플러그인 설치:
```bash
/plugin
# 원하는 플러그인 선택하여 설치
```

3. 또는 프로젝트의 `.claude/settings.json`에서 직접 설정할 수 있습니다.

## 플러그인 구조

각 플러그인은 표준 Claude Code 플러그인 구조를 따릅니다:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── commands/                # Slash commands (optional)
├── agents/                  # Specialized agents (optional)
├── skills/                  # Agent Skills (optional)
├── hooks/                   # Event handlers (optional)
├── .mcp.json                # External tool configuration (optional)
└── README.md                # Plugin documentation
```

## 기여 가이드

새 플러그인을 추가할 때:

1. 표준 플러그인 구조를 따르세요
2. 상세한 README.md를 포함하세요
3. `.claude-plugin/plugin.json`에 플러그인 메타데이터를 추가하세요
4. 모든 명령어와 에이전트를 문서화하세요
5. 사용 예시를 제공하세요

## 관리자

- **deekee** (burlesquer@yonsei.ac.kr)
