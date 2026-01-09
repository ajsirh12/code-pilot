# Claude Code Plugins

This directory contains some official Claude Code plugins that extend functionality through custom commands, agents, and workflows. These are examples of what's possible with the Claude Code plugin system—many more plugins are available through community marketplaces.

## What are Claude Code Plugins?

Claude Code plugins are extensions that enhance Claude Code with custom slash commands, specialized agents, hooks, and MCP servers. Plugins can be shared across projects and teams, providing consistent tooling and workflows.

Learn more in the [official plugins documentation](https://docs.claude.com/en/docs/claude-code/plugins).

## Plugins in This Directory

| Name | Description | Contents |
|------|-------------|----------|
| [explanatory-output-style](./explanatory-output-style/) | Adds educational insights about implementation choices and codebase patterns (mimics the deprecated Explanatory output style) | **Hook:** SessionStart - Injects educational context at the start of each session |
| [feature-dev](./feature-dev/) | Comprehensive feature development workflow with a structured 7-phase approach | **Command:** `/feature-dev` - Guided feature development workflow<br>**Agents:** `code-explorer`, `code-architect`, `code-reviewer` - For codebase analysis, architecture design, and quality review |
| [frontend-design](./frontend-design/) | Create distinctive, production-grade frontend interfaces that avoid generic AI aesthetics | **Skill:** `frontend-design` - Auto-invoked for frontend work, providing guidance on bold design choices, typography, animations, and visual details |
| [hookify](./hookify/) | Easily create custom hooks to prevent unwanted behaviors by analyzing conversation patterns or explicit instructions | **Commands:** `/hookify`, `/hookify:list`, `/hookify:configure`, `/hookify:help`<br>**Agent:** `conversation-analyzer` - Analyzes conversations for problematic behaviors<br>**Skill:** `writing-rules` - Guidance on hookify rule syntax |
| [learning-output-style](./learning-output-style/) | Interactive learning mode that requests meaningful code contributions at decision points (mimics the unshipped Learning output style) | **Hook:** SessionStart - Encourages users to write meaningful code (5-10 lines) at decision points while receiving educational insights |
| [plugin-dev](./plugin-dev/) | Comprehensive toolkit for developing Claude Code plugins with 7 expert skills and AI-assisted creation | **Command:** `/plugin-dev:create-plugin` - 8-phase guided workflow for building plugins<br>**Agents:** `agent-creator`, `plugin-validator`, `skill-reviewer`<br>**Skills:** Hook development, MCP integration, plugin structure, settings, commands, agents, and skill development |
| [code-quality](./code-quality/) | Code quality review agents analyzing local git diff. Specializes in comments, tests, error handling, type design, and code simplification | **Command:** `/code-quality:review` - Run with optional review aspects (comments, tests, errors, types, code, simplify, all)<br>**Agents:** `comment-analyzer`, `test-analyzer`, `silent-failure-hunter`, `type-design-analyzer`, `code-reviewer`, `code-simplifier` |
| [gitlab-toolkit](./gitlab-toolkit/) | Intelligent GitLab workflow automation with 46 commands and 8 agents for issues, MRs, pipelines, and security | **Commands:** `/gitlab-toolkit`, `/gl-issue`, `/gl-mr`, `/gl-pipeline`, `/gl-commit`, etc. (46 total)<br>**Agents:** `project-initializer`, `pipeline-debugger`, `git-workflow`, `issue-manager`, `mr-workflow`, `code-navigator`, `registry-manager`, `security-auditor`<br>**Skill:** `gitlab-toolkit` - Workflow decision tree and API patterns<br>**Hook:** SessionStart - Auto-detect GitLab projects |
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

## Installation

These plugins are included in the Claude Code repository. To use them in your own projects:

1. Install Claude Code globally:
```bash
npm install -g claude-code
```

2. Navigate to your project and run Claude Code:
```bash
claude
```

3. Use the `/plugin` command to install plugins from marketplaces, or configure them in your project's `.claude/settings.json`.

For detailed plugin installation and configuration, see the [official documentation](https://docs.claude.com/en/docs/claude-code/plugins).

## Plugin Structure

Each plugin follows the standard Claude Code plugin structure:

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

## Contributing

When adding new plugins to this directory:

1. Follow the standard plugin structure
2. Include a comprehensive README.md
3. Add plugin metadata in `.claude-plugin/plugin.json`
4. Document all commands and agents
5. Provide usage examples

## Learn More

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code/overview)
- [Plugin System Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Agent SDK Documentation](https://docs.claude.com/en/api/agent-sdk/overview)
