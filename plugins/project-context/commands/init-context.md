---
name: init-context
description: Initialize CLAUDE.md with project context template
allowed-tools: ["Read", "Write", "Bash", "Glob", "AskUserQuestion"]
argument-hint: "[template-type]"
---

# Initialize Project Context

CLAUDE.md 템플릿을 생성하여 프로젝트 컨텍스트 관리 시작.

## Workflow

### 1. Check Existing CLAUDE.md

```bash
# 기존 파일 확인
if [ -f "CLAUDE.md" ]; then
  echo "CLAUDE.md already exists"
fi
```

기존 파일이 있으면 사용자에게 확인:
- 덮어쓰기
- 백업 후 생성
- 취소

### 2. Determine Template Type

인자로 템플릿 타입이 제공되었는지 확인:
- `base` - 범용 기본
- `webapp` - 프론트엔드/풀스택
- `api` - 백엔드 API
- `library` - 라이브러리/패키지

인자가 없으면 AskUserQuestion으로 선택 요청.

### 3. Detect Project Info

가능하면 자동 감지:

```bash
# package.json에서 이름 추출
if [ -f "package.json" ]; then
  PROJECT_NAME=$(grep -o '"name": *"[^"]*"' package.json | cut -d'"' -f4)
fi

# Git remote에서 프로젝트명 추출
if [ -d ".git" ]; then
  REMOTE_URL=$(git remote get-url origin 2>/dev/null)
fi
```

### 4. Generate CLAUDE.md

템플릿 파일 읽기:
```
${CLAUDE_PLUGIN_ROOT}/skills/project-context/templates/{type}.md
```

템플릿의 플레이스홀더를 실제 값으로 대체:
- `[프로젝트명]` → 감지된 프로젝트명 또는 사용자 입력
- `[날짜]` → 현재 날짜 (YYYY-MM 형식)

### 5. Write and Confirm

CLAUDE.md 파일 생성 후 내용 표시.

사용자에게 다음 단계 안내:
- Context 섹션 채우기
- 첫 Focus 설정
- 프로젝트 시작!

## Template Locations

```
${CLAUDE_PLUGIN_ROOT}/skills/project-context/templates/
├── base.md
├── webapp.md
├── api.md
└── library.md
```

## Examples

```bash
/init-context           # 타입 선택 후 생성
/init-context webapp    # 웹앱 템플릿으로 바로 생성
/init-context api       # API 템플릿으로 바로 생성
```

## Output Format

생성 완료 후 표시:

```
CLAUDE.md created with [type] template.

Next steps:
1. Fill in the Context section with your project details
2. Set your current Focus in Status
3. Start building!

Tip: Update Status at the end of each session to maintain context.
```
