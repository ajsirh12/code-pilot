# Claude Code 플러그인 온보딩 가이드

> Claude Code 플러그인의 설치, 사용, 개발까지 완벽 가이드

| 항목 | 내용 |
|------|------|
| **작성자** | deekee (박성준) |
| **최종 수정일** | 2025-01-14 |
| **버전** | 1.1.0 |

---

## 목차

1. [개요](#1-개요)
2. [용어 정리](#2-용어-정리)
3. [플러그인 구조](#3-플러그인-구조)
4. [플러그인 설치하기](#4-플러그인-설치하기)
5. [플러그인 관리하기](#5-플러그인-관리하기)
6. [플러그인 만들기](#6-플러그인-만들기)
7. [실습: 로컬 마켓플레이스 만들기](#실습-로컬-마켓플레이스-만들기)
8. [트러블슈팅](#8-트러블슈팅)

---

## 1. 개요

### 플러그인이란?

**플러그인**은 Claude Code의 기능을 확장하는 모듈입니다. 커스텀 명령어, 전문 에이전트, 자동화 훅, 외부 서비스 연동 등을 추가할 수 있습니다.

### 플러그인으로 할 수 있는 것

| 기능 | 설명 | 예시 |
|------|------|------|
| **커스텀 명령어** | `/명령어`로 특정 작업 실행 | `/commit`, `/review`, `/deploy` |
| **전문 에이전트** | 특정 도메인의 자율 에이전트 | 코드 리뷰어, DB 분석가, API 설계자 |
| **자동화 훅** | 이벤트 발생 시 자동 실행 | 파일 저장 전 보안 검사, 세션 시작 시 컨텍스트 로드 |
| **외부 서비스 연동** | MCP로 외부 API 연결 | Asana, GitLab, Slack 연동 |

### 왜 플러그인이 필요한가?

- **반복 작업 자동화**: 매번 같은 지시 대신 명령어 하나로 실행
- **팀 워크플로우 공유**: 팀원 모두 동일한 도구와 규칙 사용
- **전문 지식 캡슐화**: 특정 도메인의 베스트 프랙티스를 플러그인으로 패키징

### 이 문서의 대상

- Claude Code는 사용하지만 **플러그인은 처음**인 사용자
- 플러그인을 설치하고 사용하고 싶은 사용자
- 직접 플러그인을 만들어보고 싶은 사용자

### 이 문서에서 배울 것

```
플러그인 이해 → 설치 → 관리 → 직접 만들기
```

1. 플러그인 구조와 용어 이해
2. 마켓플레이스에서 플러그인 설치
3. 설치된 플러그인 관리 (활성화/비활성화/삭제)
4. `plugin-dev`를 사용해 직접 플러그인 개발

### 전제 조건

- Claude Code가 설치되어 있어야 함
- Claude Code 기본 사용법을 알고 있어야 함 (대화, 파일 읽기/쓰기 등)

### 플러그인 예시

현재 사용 가능한 플러그인 일부:

| 플러그인 | 설명 |
|---------|------|
| `plugin-dev` | 플러그인 개발 툴킷 |
| `code-quality` | 코드 품질 리뷰 에이전트 |
| `commit-commands` | Git 커밋/PR 간소화 |
| `debug-helper` | 에러 분석 및 디버깅 도우미 |

### 마켓플레이스란?

**마켓플레이스**는 플러그인을 배포하고 공유하는 저장소입니다. GitHub 저장소나 로컬 폴더가 마켓플레이스가 될 수 있습니다.

```
마켓플레이스 등록 → 플러그인 선택 → 설치 → 사용
```

대표적인 마켓플레이스:
- `deekee-plugins`: 이 프로젝트에서 사용하는 마켓플레이스

> **Note:** `deekee-plugins` 마켓플레이스 설치 및 접근 권한은 박성준(deekee)에게 문의하세요.

---

## 2. 용어 정리

### 핵심 용어

| 용어 | 설명 |
|------|------|
| **Plugin** | Claude Code 기능을 확장하는 모듈. 명령어, 에이전트, 훅 등을 포함 |
| **Marketplace** | 플러그인을 배포하고 공유하는 저장소 (GitHub 저장소 또는 로컬 폴더) |
| **Scope** | 플러그인 설치 범위 - 누가 어디서 사용할 수 있는지 결정 |

### Scope (설치 범위)

| Scope | 설명 | 사용 사례 |
|-------|------|----------|
| **User** | 모든 프로젝트에서 **나만** 사용 | 개인용 유틸리티, 개인 워크플로우 |
| **Project** | 이 저장소의 **모든 협업자**가 사용 | 팀 공통 도구, 프로젝트 규칙 |
| **Local** | 이 저장소에서 **나만** 사용 | 프로젝트별 개인 설정 |

```
User    = 전역 + 개인
Project = 프로젝트 + 팀 전체
Local   = 프로젝트 + 개인
```

### 플러그인 컴포넌트

| 컴포넌트 | 설명 | 파일 위치 |
|----------|------|----------|
| **Command** | `/명령어`로 실행하는 슬래시 명령어 | `commands/*.md` |
| **Agent** | 특정 작업을 자율적으로 수행하는 에이전트 | `agents/*.md` |
| **Skill** | Claude가 자동으로 로드하는 지식/가이드 | `skills/*/SKILL.md` |
| **Hook** | 이벤트 발생 시 자동 실행되는 스크립트 | `hooks/hooks.json` |
| **MCP** | 외부 서비스와 연동하는 서버 설정 | `.mcp.json` |

### Command vs Agent vs Skill

```
Command: 사용자가 명시적으로 "/명령어" 실행
Agent:   description의 <example> 패턴과 매칭되면 Claude가 자동 호출
Skill:   description의 키워드가 대화에 나오면 지식 자동 로드
```

**호출 방식 비교:**

| 컴포넌트 | 호출 방식 | 트리거 조건 |
|----------|----------|-------------|
| Command | 명시적 | 사용자가 `/명령어` 입력 |
| Agent | 자동 | description의 `<example>` 패턴 매칭 |
| Skill | 자동 | description의 키워드 매칭 |

**예시:**
- `/commit` → Command (사용자가 직접 `/commit` 입력)
- `code-reviewer` → Agent (코드 리뷰 관련 대화가 `<example>` 패턴과 매칭)
- `debug-helper` → Skill ("에러 분석" 키워드가 description과 매칭)

**Agent 트리거 상세:**

Agent의 description에 `<example>` 블록을 작성하면, 비슷한 상황에서 Claude가 자동으로 해당 Agent를 호출합니다:

```yaml
description: |
  코드 리뷰 에이전트

  <example>
  Context: 사용자가 PR 리뷰를 요청함
  user: "이 PR 좀 리뷰해줘"
  assistant: "code-reviewer 에이전트를 사용합니다"
  </example>
```

위 예시가 있으면, 사용자가 "PR 리뷰해줘"라고 말할 때 Claude가 이 Agent를 호출합니다.

### Hook 이벤트

| 이벤트 | 발생 시점 |
|--------|----------|
| `PreToolUse` | 도구 실행 **전** |
| `PostToolUse` | 도구 실행 **후** |
| `SessionStart` | 세션 시작 시 |
| `SessionEnd` | 세션 종료 시 |
| `Stop` | Claude가 응답 완료 시 |
| `UserPromptSubmit` | 사용자가 프롬프트 제출 시 |

### MCP (Model Context Protocol)

외부 서비스와 Claude Code를 연결하는 프로토콜입니다.

```
Claude Code ←→ MCP Server ←→ 외부 서비스 (Asana, GitLab, DB 등)
```

MCP 서버 타입:
- **stdio**: 로컬 프로세스로 실행
- **SSE**: HTTP 스트리밍 (OAuth 지원)
- **HTTP**: REST API 형태

### 설정 파일

| 파일 | 역할 |
|------|------|
| `plugin.json` | 플러그인 메타데이터 (이름, 버전, 설명) |
| `marketplace.json` | 마켓플레이스 메타데이터 (플러그인 목록) |
| `.mcp.json` | MCP 서버 설정 |
| `hooks.json` | 훅 이벤트 매핑 |

### 특수 변수

| 변수 | 설명 |
|------|------|
| `${CLAUDE_PLUGIN_ROOT}` | 플러그인 루트 디렉토리 경로 (이식성을 위해 사용) |

### 플러그인 설치 경로

플러그인이 설치되면 캐시 디렉토리에 저장됩니다.

**Windows:**
```
C:\Users\{사용자명}\.claude\plugins\cache\{마켓플레이스명}\{플러그인명}\{버전}\
```

**macOS/Linux:**
```
~/.claude/plugins/cache/{마켓플레이스명}/{플러그인명}/{버전}/
```

**실제 예시 (Windows):**
```
C:\Users\deekee\.claude\plugins\cache\deekee-plugins\plugin-dev\1.0.0\
├── .claude-plugin\
│   └── plugin.json
├── commands\
├── agents\
├── skills\
└── hooks\
```

**`${CLAUDE_PLUGIN_ROOT}` 의미:**

Hook이나 스크립트에서 `${CLAUDE_PLUGIN_ROOT}`를 사용하면 위 경로로 자동 치환됩니다:

```json
{
  "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/validate.py"
}
```
↓ 실행 시 치환
```
python3 C:\Users\deekee\.claude\plugins\cache\deekee-plugins\my-plugin\1.0.0\hooks\validate.py
```

이렇게 하면 어떤 환경에서든 경로가 올바르게 설정됩니다.

---

## 3. 플러그인 구조

### 디렉토리 구조

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 메타데이터 (필수)
├── commands/                 # 슬래시 명령어 (선택)
│   ├── command-a.md
│   └── command-b.md
├── agents/                   # 에이전트 (선택)
│   └── my-agent.md
├── skills/                   # 스킬 (선택)
│   └── my-skill/
│       ├── SKILL.md
│       ├── references/
│       └── examples/
├── hooks/                    # 훅 (선택)
│   ├── hooks.json
│   └── my-hook.sh
├── .mcp.json                 # MCP 서버 설정 (선택)
└── README.md                 # 플러그인 문서
```

### 컴포넌트 관계도

```
┌─────────────────────────────────────────────────────────────┐
│                        Plugin                                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│   │ Command  │    │  Agent   │    │  Skill   │              │
│   │ /명령어   │    │ 자율실행  │    │ 지식로드  │              │
│   └────┬─────┘    └────┬─────┘    └────┬─────┘              │
│        │               │               │                     │
│        └───────────────┼───────────────┘                     │
│                        │                                     │
│                        ▼                                     │
│   ┌──────────────────────────────────────────┐              │
│   │              Claude Code                  │              │
│   └──────────────────────────────────────────┘              │
│                        │                                     │
│        ┌───────────────┼───────────────┐                     │
│        │               │               │                     │
│   ┌────▼─────┐    ┌────▼─────┐    ┌────▼─────┐              │
│   │   Hook   │    │   MCP    │    │  Tools   │              │
│   │ 이벤트    │    │ 외부연동  │    │ 도구제한  │              │
│   └──────────┘    └──────────┘    └──────────┘              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### plugin.json (필수)

플러그인의 메타데이터를 정의합니다.

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "플러그인 설명"
}
```

### Command 파일 구조

`commands/*.md` 파일은 YAML frontmatter + Markdown 본문으로 구성됩니다.

```markdown
---
name: my-command
description: 명령어 설명
argument-hint: "<arg1> [arg2]"
allowed-tools:
  - Read
  - Write
  - Bash(*)
---

# 명령어 제목

실행 지시사항...
```

**frontmatter 필드:**

| 필드 | 설명 | 필수 |
|------|------|------|
| `name` | 명령어 이름 | O |
| `description` | 명령어 설명 | O |
| `argument-hint` | 인자 힌트 | X |
| `allowed-tools` | 사용 가능한 도구 제한 | X |

**allowed-tools 문법:**

```yaml
allowed-tools:
  - Read              # Read 도구 허용
  - Write             # Write 도구 허용
  - Bash(*)           # 모든 Bash 명령어 허용
  - Bash(git *)       # git으로 시작하는 명령어만 허용
  - Bash(npm test)    # npm test 명령어만 허용
  - mcp__server__*    # 특정 MCP 서버의 모든 도구 허용
```

`Bash(패턴)` 형식으로 허용할 명령어를 제한할 수 있습니다.

### Agent 파일 구조

`agents/*.md` 파일도 YAML frontmatter + System Prompt로 구성됩니다.

```markdown
---
name: my-agent
description: |
  에이전트 설명. 언제 이 에이전트가 호출되는지.

  <example>
  Context: 상황 설명
  user: "사용자 입력"
  assistant: "에이전트 사용 선언"
  </example>
model: inherit
color: cyan
tools:
  - Read
  - Write
  - Bash(*)
---

# 에이전트 시스템 프롬프트

에이전트의 역할과 작업 방식 정의...
```

**frontmatter 필드:**

| 필드 | 설명 | 필수 |
|------|------|------|
| `name` | 에이전트 이름 | O |
| `description` | 트리거 조건 + 예시 포함 | O |
| `model` | 사용할 모델 (inherit/sonnet/opus/haiku) | X |
| `color` | 상태 표시 색상 | X |
| `tools` | 사용 가능한 도구 | X |

### Skill 구조

`skills/skill-name/SKILL.md` 파일로 구성됩니다.

```markdown
---
name: my-skill
description: 스킬 트리거 설명. "키워드1", "키워드2" 등을 언급할 때 사용.
---

# 스킬 제목

스킬 내용 (Claude가 로드하는 지식)...
```

**Progressive Disclosure 구조:**
```
skills/my-skill/
├── SKILL.md           # 핵심 내용 (항상 로드)
├── references/        # 상세 참조 (필요시 로드)
└── examples/          # 예시 (필요시 로드)
```

### Hook 구조

`hooks/hooks.json` 파일로 이벤트와 스크립트를 매핑합니다.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/validate.py"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "세션 시작 시 실행할 프롬프트"
          }
        ]
      }
    ]
  }
}
```

**Hook 타입:**
- `command`: 외부 스크립트 실행 (stdin으로 JSON 입력, stdout으로 결과 출력)
- `prompt`: Claude 컨텍스트에 프롬프트 주입

**Hook 스크립트 입력/출력:**

`command` 타입 Hook은 stdin으로 JSON을 받고, stdout으로 JSON을 출력합니다:

```python
# hooks/validate.py 예시
import sys
import json

# stdin에서 도구 호출 정보 받기
input_data = json.load(sys.stdin)
# input_data 예시:
# {
#   "tool_name": "Write",
#   "tool_input": {"file_path": "/path/to/file", "content": "..."}
# }

# 검증 로직
file_path = input_data.get("tool_input", {}).get("file_path", "")
if ".env" in file_path:
    # 차단: .env 파일 수정 금지
    result = {
        "decision": "block",
        "reason": ".env 파일은 수정할 수 없습니다"
    }
else:
    # 허용
    result = {"decision": "allow"}

# stdout으로 결과 출력
print(json.dumps(result))
```

**Hook 결과 처리:**

| decision | 동작 |
|----------|------|
| `allow` | 도구 실행 허용 |
| `block` | 도구 실행 차단 (reason 표시) |
| `skip` | Hook 건너뛰기 (다음 Hook 실행) |

**prompt 타입 Hook:**

Claude의 컨텍스트에 프롬프트를 주입합니다 (세션 시작 시 지시사항 추가 등):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "이 프로젝트에서는 항상 TypeScript를 사용하세요."
          }
        ]
      }
    ]
  }
}
```

### MCP 설정

`.mcp.json` 파일로 외부 서비스를 연동합니다.

```json
{
  "mcpServers": {
    "my-service": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@service/mcp-server"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

### 마켓플레이스 구조

마켓플레이스는 여러 플러그인을 포함하는 저장소입니다.

```
marketplace/
├── .claude-plugin/
│   └── marketplace.json     # 마켓플레이스 메타데이터
├── plugin-a/
│   └── ...
└── plugin-b/
    └── ...
```

**marketplace.json:**
```json
{
  "name": "my-marketplace",
  "version": "1.0.0",
  "description": "마켓플레이스 설명",
  "plugins": [
    {
      "name": "plugin-a",
      "description": "플러그인 A 설명",
      "version": "1.0.0",
      "source": "./plugin-a"
    }
  ]
}
```

---

## 4. 플러그인 설치하기

플러그인 설치는 2단계 프로세스입니다:

```
1. 마켓플레이스 등록 → 2. 플러그인 설치
```

### 설치 흐름도

```
┌─────────────────┐
│  마켓플레이스    │
│  등록           │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  플러그인 선택   │
│  /plugin install│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Scope 선택     │
│  User/Project/  │
│  Local          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  설치 완료      │
│  바로 사용 가능  │
└─────────────────┘
```

### Step 1: 마켓플레이스 등록

먼저 플러그인을 가져올 마켓플레이스를 등록해야 합니다.

#### 대화형 UI 사용

```
/plugin
```

실행 후 "Add marketplace" 선택 → URL/경로 입력

#### 명령어 사용

```bash
# GitHub 저장소 등록
/plugin marketplace add https://github.com/username/marketplace-repo

# 로컬 폴더 등록
/plugin marketplace add /path/to/local/marketplace

# 예: deekee-plugins 등록
/plugin marketplace add https://github.com/deekee/deekee-plugins
```

#### 등록된 마켓플레이스 확인

```
/plugin marketplace list
```

<!-- 스크린샷: 마켓플레이스 목록 화면 -->
```
┌────────────────────────────────────────────┐
│ Registered Marketplaces                    │
├────────────────────────────────────────────┤
│ ✓ deekee-plugins                           │
│   https://github.com/deekee/deekee-plugins │
│   Plugins: plugin-dev, code-quality, ...   │
└────────────────────────────────────────────┘
```

### Step 2: 플러그인 설치

#### 대화형 UI 사용 (권장)

```
/plugin
```

실행 후:
1. "Install plugin" 선택
2. 마켓플레이스 선택
3. 플러그인 선택
4. Scope 선택 (User/Project/Local)

<!-- 스크린샷: 플러그인 선택 화면 -->
```
┌────────────────────────────────────────────┐
│ Select plugin to install                   │
├────────────────────────────────────────────┤
│ > plugin-dev         플러그인 개발 툴킷     │
│   code-quality       코드 품질 리뷰         │
│   commit-commands    Git 커밋 간소화        │
└────────────────────────────────────────────┘
```

#### 명령어 사용

```bash
# 기본 설치 (scope 선택 프롬프트 표시)
/plugin install plugin-dev@deekee-plugins

# scope 지정 설치
/plugin install plugin-dev@deekee-plugins --scope user
/plugin install plugin-dev@deekee-plugins --scope project
/plugin install plugin-dev@deekee-plugins --scope local
```

### Step 3: Scope 선택

<!-- 스크린샷: Scope 선택 화면 -->
```
┌────────────────────────────────────────────┐
│ Select installation scope                  │
├────────────────────────────────────────────┤
│ > User     - All projects, just for me     │
│   Project  - This repo, all collaborators  │
│   Local    - This repo, just for me        │
└────────────────────────────────────────────┘
```

**Scope 선택 가이드:**

| 상황 | 추천 Scope |
|------|-----------|
| 개인 유틸리티로 모든 프로젝트에서 사용 | User |
| 팀원 모두가 이 프로젝트에서 사용해야 함 | Project |
| 이 프로젝트에서만 개인적으로 테스트 | Local |

### 설치 확인

```
/plugin
```

설치된 플러그인 목록에서 확인:

<!-- 스크린샷: 설치 완료 화면 -->
```
┌────────────────────────────────────────────┐
│ Installed Plugins                          │
├────────────────────────────────────────────┤
│ ✓ plugin-dev@deekee-plugins     [User]     │
│   Commands: /plugin-dev:create-plugin      │
│   Agents: agent-creator, plugin-validator  │
│   Skills: 7 skills loaded                  │
└────────────────────────────────────────────┘
```

### 설치 후 사용

설치가 완료되면 바로 사용할 수 있습니다:

```bash
# 명령어 실행
/plugin-dev:create-plugin

# 또는 자연어로 요청
"플러그인 만들고 싶어" → plugin-dev 스킬 자동 로드
```

---

## 5. 플러그인 관리하기

### 명령어 요약표

| 명령어 | 설명 |
|--------|------|
| `/plugin` | 대화형 플러그인 관리 UI |
| `/plugin install <plugin>@<marketplace>` | 플러그인 설치 |
| `/plugin uninstall <plugin>@<marketplace>` | 플러그인 삭제 |
| `/plugin enable <plugin>@<marketplace>` | 플러그인 활성화 |
| `/plugin disable <plugin>@<marketplace>` | 플러그인 비활성화 |
| `/plugin marketplace add <url/path>` | 마켓플레이스 등록 |
| `/plugin marketplace remove <name>` | 마켓플레이스 제거 |
| `/plugin marketplace list` | 등록된 마켓플레이스 목록 |

### 설치된 플러그인 확인

```
/plugin
```

<!-- 스크린샷: 플러그인 목록 -->
```
┌────────────────────────────────────────────────────────┐
│ Plugin Management                                      │
├────────────────────────────────────────────────────────┤
│ Installed Plugins:                                     │
│                                                        │
│ [User]                                                 │
│ ✓ plugin-dev@deekee-plugins          Enabled          │
│ ✓ code-quality@deekee-plugins        Enabled          │
│                                                        │
│ [Project]                                              │
│ ✓ commit-commands@deekee-plugins     Enabled          │
│                                                        │
│ [Local]                                                │
│ ○ debug-helper@deekee-plugins        Disabled         │
├────────────────────────────────────────────────────────┤
│ Actions:                                               │
│ > Install plugin                                       │
│   Uninstall plugin                                     │
│   Enable/Disable plugin                                │
│   Manage marketplaces                                  │
└────────────────────────────────────────────────────────┘
```

### 플러그인 활성화/비활성화

플러그인을 삭제하지 않고 일시적으로 끌 수 있습니다.

```bash
# 비활성화
/plugin disable plugin-dev@deekee-plugins

# 활성화
/plugin enable plugin-dev@deekee-plugins
```

**사용 사례:**
- 플러그인 간 충돌 테스트
- 특정 작업 시 불필요한 플러그인 비활성화
- 문제 해결을 위한 격리 테스트

### 플러그인 삭제

```bash
/plugin uninstall plugin-dev@deekee-plugins
```

또는 대화형 UI에서 "Uninstall plugin" 선택

### 마켓플레이스 관리

#### 마켓플레이스 추가

```bash
# GitHub URL
/plugin marketplace add https://github.com/username/marketplace

# 로컬 경로
/plugin marketplace add /path/to/marketplace
```

#### 마켓플레이스 제거

```bash
/plugin marketplace remove marketplace-name
```

#### 마켓플레이스 목록

```bash
/plugin marketplace list
```

### Scope별 설정 파일 위치

플러그인 설정은 scope에 따라 다른 위치에 저장됩니다:

| Scope | 설정 파일 위치 |
|-------|---------------|
| User | `~/.claude/settings.json` |
| Project | `.claude/settings.json` (git 추적됨) |
| Local | `.claude/settings.local.json` (git 무시됨) |

### 플러그인 업데이트

마켓플레이스가 업데이트되면 플러그인도 자동으로 최신 버전을 사용합니다.

수동으로 최신 버전을 가져오려면:

```bash
# 마켓플레이스 새로고침
/plugin marketplace add <same-url>  # 다시 등록하면 업데이트됨
```

### 플러그인 정보 확인

설치된 플러그인의 상세 정보 확인:

```
/plugin
```

플러그인 선택 후 상세 정보 확인:

```
┌────────────────────────────────────────────────────────┐
│ plugin-dev@deekee-plugins                              │
├────────────────────────────────────────────────────────┤
│ Version: 0.1.0                                         │
│ Scope: User                                            │
│ Status: Enabled                                        │
│                                                        │
│ Components:                                            │
│ • Commands: /plugin-dev:create-plugin                  │
│ • Agents: agent-creator, plugin-validator, skill-...   │
│ • Skills: hook-development, mcp-integration, ...       │
│ • Hooks: None                                          │
│ • MCP: None                                            │
│                                                        │
│ Description:                                           │
│ 플러그인 개발을 위한 종합 툴킷                           │
└────────────────────────────────────────────────────────┘
```

### 명령어 빠른 참조

```bash
# 설치
/plugin install <plugin>@<marketplace> [--scope user|project|local]

# 삭제
/plugin uninstall <plugin>@<marketplace>

# 활성화/비활성화
/plugin enable <plugin>@<marketplace>
/plugin disable <plugin>@<marketplace>

# 마켓플레이스
/plugin marketplace add <url|path>
/plugin marketplace remove <name>
/plugin marketplace list
```

---

## 6. 플러그인 만들기

### 방법 1: 직접 만들기

[3. 플러그인 구조](#3-플러그인-구조)와 [실습: 로컬 마켓플레이스 만들기](#실습-로컬-마켓플레이스-만들기)를 참고하여 직접 파일을 만들 수 있습니다.

### 방법 2: plugin-dev 사용 (권장)

`plugin-dev` 플러그인을 사용하면 대화형으로 쉽게 플러그인을 만들 수 있습니다.

#### 설치

```bash
/plugin install plugin-dev@deekee-plugins --scope user
```

#### 사용

```bash
# 가이드 워크플로우 시작
/plugin-dev:create-plugin

# 또는 설명과 함께
/plugin-dev:create-plugin 날씨 확인 플러그인
```

Claude가 단계별로 질문하며 플러그인을 생성합니다:
1. 목적/기능 파악
2. 필요한 컴포넌트 결정 (command/agent/skill/hook/mcp)
3. 파일 생성 및 검증

#### 자연어로 요청

plugin-dev가 설치되어 있으면 자연어로도 요청 가능합니다:

```
"GitLab MR 리뷰 플러그인 만들어줘"
"파일 저장 전 보안 검사하는 훅 만들어줘"
```

### 테스트

개발 중인 플러그인을 테스트하려면:

```bash
# 방법 1: --plugin-dir 옵션
claude --plugin-dir /path/to/my-plugin

# 방법 2: 로컬 마켓플레이스로 등록 후 설치
/plugin marketplace add /path/to/my-marketplace
/plugin install my-plugin@my-marketplace --scope local
```

---

## 실습: 로컬 마켓플레이스 만들기

직접 마켓플레이스를 만들고 간단한 플러그인을 등록해봅시다.

### Step 1: plugin-dev 설치

```bash
/plugin install plugin-dev@deekee-plugins --scope user
```

### Step 2: 플러그인 생성

`/plugin-dev:create-plugin` 명령어를 사용합니다:

```
/plugin-dev:create-plugin 인사하는 플러그인 만들어줘
```

Claude가 질문하면 답변하세요:
- 목적: "사용자에게 인사하는 간단한 플러그인"
- 컴포넌트: "command만 필요"
- 명령어: "hello, 이름을 인자로 받아서 인사"

완료되면 플러그인 폴더가 생성됩니다 (예: `greeting-plugin/`, `hello-plugin/` 등 대화 내용에 따라 이름이 결정됨).

### Step 3: 플러그인 테스트 (--plugin-dir)

마켓플레이스에 등록하기 전에 `--plugin-dir` 옵션으로 플러그인을 직접 테스트합니다.

```bash
# 새 터미널에서 플러그인을 로드하여 Claude Code 실행
claude --plugin-dir /path/to/{플러그인명}

# Windows 예시
claude --plugin-dir C:\Users\deekee\project\greeting-plugin

# macOS/Linux 예시
claude --plugin-dir ~/projects/greeting-plugin
```

**테스트 방법:**

1. 명령어가 등록되었는지 확인:
   ```
   /{플러그인명}:hello 테스트
   ```

2. 정상 작동하면 다음 단계로 진행
3. 문제가 있으면 플러그인 파일 수정 후 Claude Code 재시작

> **Tip:** `--plugin-dir`는 설치 없이 플러그인을 즉시 로드하므로 개발 중 빠른 테스트에 유용합니다. 변경사항을 반영하려면 Claude Code를 재시작하세요.

### Step 4: 마켓플레이스 구성

생성된 플러그인을 마켓플레이스로 묶습니다. (아래 예시에서 `{플러그인명}`은 실제 생성된 폴더명으로 대체)

```bash
# 마켓플레이스 폴더 생성
mkdir -p my-marketplace/.claude-plugin

# 플러그인을 마켓플레이스로 이동
mv {플러그인명} my-marketplace/
```

`my-marketplace/.claude-plugin/marketplace.json` 작성:
```json
{
  "name": "my-marketplace",
  "version": "1.0.0",
  "description": "내 첫 번째 마켓플레이스",
  "owner": {
    "name": "your-name",
    "email": "your-email@example.com"
  },
  "plugins": [
    {
      "name": "{플러그인명}",
      "description": "인사하는 플러그인",
      "version": "1.0.0",
      "source": "./{플러그인명}"
    }
  ]
}
```

### Step 5: 최종 구조 확인

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json
└── {플러그인명}/
    ├── .claude-plugin/
    │   └── plugin.json
    └── commands/
        └── *.md
```

### Step 6: 마켓플레이스 등록 및 플러그인 설치

> **권장:** `/plugin` 명령어로 대화형 UI를 사용하면 더 쉽게 등록하고 설치할 수 있습니다.

**방법 1: 대화형 UI (권장)**

```bash
/plugin
```
→ "Manage marketplaces" → "Add marketplace" → 경로 입력 (`./my-marketplace`)
→ "Install plugin" → 마켓플레이스 선택 → 플러그인 선택 → Scope 선택

**방법 2: 명령어 사용**

```bash
# 마켓플레이스 등록 (상대 경로 또는 절대 경로)
/plugin marketplace add ./my-marketplace

# 플러그인 설치
/plugin install {플러그인명}@my-marketplace --scope local
```

**사용:**
```bash
# 명령어 이름은 플러그인에 따라 다름
/{플러그인명}:{명령어} 홍길동
```

### 결과

```
> /{플러그인명}:hello 홍길동
안녕하세요, 홍길동님!
```

> **Tip:** 플러그인 구조를 직접 이해하고 싶다면 [3. 플러그인 구조](#3-플러그인-구조)를 참고하여 수동으로 파일을 만들어볼 수도 있습니다.

---

## 8. 트러블슈팅

### 자주 발생하는 문제

#### 플러그인이 로드되지 않음

**증상:** 설치했는데 명령어/에이전트/스킬이 보이지 않음

**해결:**
```bash
# 1. 설치 상태 확인
/plugin

# 2. 활성화 상태 확인 (Disabled인지)
# → Disabled라면 활성화
/plugin enable plugin-name@marketplace

# 3. Claude Code 재시작
# 터미널 종료 후 다시 실행
```

#### 마켓플레이스 등록 실패

**증상:** `/plugin marketplace add` 실행 시 오류

**해결:**
```bash
# URL이 올바른지 확인
# GitHub: https://github.com/username/repo 형식

# 로컬 경로가 절대 경로인지 확인
/plugin marketplace add /absolute/path/to/marketplace

# 마켓플레이스 구조 확인
# .claude-plugin/marketplace.json 또는 .claude-plugin/plugin.json 필요
```

#### 명령어 실행 오류

**증상:** `/plugin-name:command` 실행 시 오류

**해결:**
```bash
# 1. 명령어 이름 확인
/plugin  # 설치된 플러그인의 명령어 목록 확인

# 2. frontmatter 형식 확인
# commands/*.md 파일의 YAML 형식이 올바른지 확인

# 3. 디버그 모드로 실행
claude --debug
```

#### 훅이 실행되지 않음

**증상:** hooks.json 설정했는데 훅이 작동하지 않음

**해결:**
```bash
# 1. hooks.json 위치 확인
# plugin-root/hooks/hooks.json

# 2. JSON 형식 검증
# 온라인 JSON validator로 확인

# 3. matcher 정규식 확인
# "Edit|Write" 형식의 정규식이 맞는지

# 4. 스크립트 경로 확인
# ${CLAUDE_PLUGIN_ROOT} 사용 권장
```

#### MCP 서버 연결 실패

**증상:** MCP 도구가 표시되지 않거나 오류 발생

**해결:**
```bash
# 1. .mcp.json 위치 확인
# 플러그인 루트에 .mcp.json 파일

# 2. 필요한 패키지 설치 확인
# npx 명령어가 실행되는지 테스트

# 3. 환경 변수 설정 확인
# API_KEY 등 필요한 변수가 설정되어 있는지

# 4. 로그 확인
claude --debug
```

### 디버깅 방법

#### 디버그 모드 실행

```bash
claude --debug
```

디버그 모드에서 확인할 수 있는 것:
- 플러그인 로드 과정
- 훅 실행 결과
- MCP 서버 연결 상태
- 오류 상세 메시지

#### 플러그인 구조 검증

```bash
# plugin-dev의 validator 사용
"내 플러그인 검증해줘"

# 또는 직접 확인
# - plugin.json 존재 여부
# - 필수 필드 (name, version, description)
# - 컴포넌트 파일 위치
```

### FAQ

**Q: Scope를 변경하고 싶어요**

A: 삭제 후 다시 설치해야 합니다:
```bash
/plugin uninstall plugin-name@marketplace
/plugin install plugin-name@marketplace --scope new-scope
```

**Q: 플러그인 간 충돌이 발생해요**

A: 하나씩 비활성화하면서 원인 파악:
```bash
/plugin disable plugin-a@marketplace
# 테스트
/plugin enable plugin-a@marketplace
/plugin disable plugin-b@marketplace
# 테스트
```

**Q: 개발 중인 플러그인 변경이 반영되지 않아요**

A: Claude Code 세션 재시작 필요:
```bash
# 터미널 종료 후 다시 시작
claude

# 또는 --plugin-dir로 직접 로드
claude --plugin-dir /path/to/my-plugin
```

**Q: 팀원에게 플러그인을 공유하고 싶어요**

A: Project scope로 설치하면 `.claude/settings.json`에 저장되어 git으로 공유됩니다:
```bash
/plugin install plugin-name@marketplace --scope project
git add .claude/settings.json
git commit -m "Add plugin configuration"
```

**Q: 특정 프로젝트에서만 플러그인을 사용하고 싶어요**

A: Local scope 사용:
```bash
/plugin install plugin-name@marketplace --scope local
# .claude/settings.local.json에 저장 (git 무시됨)
```

### 도움 받기

- **Claude Code 문서**: https://docs.claude.com/en/docs/claude-code/plugins
- **플러그인 개발 문의**: plugin-dev 스킬 사용
- **버그 리포트**: GitHub Issues

---

## 부록: 빠른 참조 카드

### 핵심 명령어

```bash
# 플러그인 관리 UI
/plugin

# 마켓플레이스
/plugin marketplace add <url>
/plugin marketplace list
/plugin marketplace remove <name>

# 플러그인 설치/삭제
/plugin install <plugin>@<marketplace> [--scope user|project|local]
/plugin uninstall <plugin>@<marketplace>

# 활성화/비활성화
/plugin enable <plugin>@<marketplace>
/plugin disable <plugin>@<marketplace>
```

### Scope 선택 기준

| 사용 목적 | Scope |
|----------|-------|
| 개인용, 모든 프로젝트 | User |
| 팀 공유, 이 프로젝트 | Project |
| 개인용, 이 프로젝트만 | Local |

### 플러그인 구조 요약

```
plugin/
├── .claude-plugin/plugin.json    # 필수
├── commands/*.md                  # 슬래시 명령어
├── agents/*.md                    # 에이전트
├── skills/*/SKILL.md             # 스킬
├── hooks/hooks.json              # 훅
└── .mcp.json                     # MCP 서버
```

---
