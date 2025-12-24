---
name: init-context
description: Initialize CLAUDE.md by analyzing project structure automatically
allowed-tools: ["Read", "Write", "Bash", "Glob", "AskUserQuestion"]
argument-hint: "[template-type] or empty for auto-detect"
---

# Initialize Project Context

프로젝트를 분석하여 CLAUDE.md를 자동 생성.

## Workflow

### 1. Check Existing CLAUDE.md

```bash
if [ -f "CLAUDE.md" ]; then
  echo "CLAUDE.md already exists"
fi
```

기존 파일이 있으면 사용자에게 확인:
- 덮어쓰기
- 백업 후 생성
- 취소

### 2. Determine Mode

**인자가 있으면**: 해당 템플릿 사용 (base, webapp, api, library)
**인자가 없으면**: 자동 분석 모드 (권장)

### 3. Auto-Detect Project (인자 없을 때)

#### 3.1 프로젝트 메타데이터 읽기

우선순위대로 확인:
```
package.json      → Node.js 프로젝트
pyproject.toml    → Python 프로젝트
Cargo.toml        → Rust 프로젝트
go.mod            → Go 프로젝트
pom.xml           → Java/Maven 프로젝트
build.gradle      → Java/Gradle 프로젝트
composer.json     → PHP 프로젝트
Gemfile           → Ruby 프로젝트
pubspec.yaml      → Dart/Flutter 프로젝트
```

각 파일에서 추출:
- 프로젝트 이름
- 버전
- 의존성 (주요 프레임워크)

#### 3.2 기술 스택 감지

**package.json 분석 예시**:
```javascript
dependencies: {
  "react" → React
  "next" → Next.js
  "express" → Express
  "nestjs" → NestJS
  "vue" → Vue.js
  "svelte" → Svelte
}
devDependencies: {
  "typescript" → TypeScript
  "vite" → Vite
  "webpack" → Webpack
  "jest" → Jest
  "vitest" → Vitest
}
```

**pyproject.toml 분석 예시**:
```toml
[project.dependencies]
fastapi → FastAPI
django → Django
flask → Flask
pytorch → PyTorch
```

#### 3.3 디렉토리 구조 파악

```bash
# 주요 디렉토리 확인
ls -d */ 2>/dev/null | head -10
```

공통 패턴 감지:
```
src/           → 소스 코드
app/           → 애플리케이션 코드
lib/           → 라이브러리 코드
components/    → UI 컴포넌트
pages/         → 페이지/라우트
api/           → API 엔드포인트
routes/        → 라우팅
controllers/   → 컨트롤러
services/      → 서비스 레이어
models/        → 데이터 모델
tests/         → 테스트
docs/          → 문서
scripts/       → 스크립트
```

#### 3.4 Git 정보 확인

```bash
# 프로젝트명 추출
git remote get-url origin 2>/dev/null

# 최근 커밋 스타일
git log -3 --oneline 2>/dev/null
```

#### 3.5 GitLab/GitHub 이슈 조회 (선택적)

Git remote가 GitLab/GitHub인 경우, 열린 이슈 조회:

**GitLab** (GITLAB_URL, GITLAB_TOKEN 필요):
```bash
# 프로젝트 ID 확인
ENCODED_PATH=$(echo "$PROJECT_PATH" | sed 's/\//%2F/g')

# 내게 할당된 이슈 조회
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$ENCODED_PATH/issues?assignee_id=@me&state=opened&per_page=10"
```

**GitHub** (GH_TOKEN 또는 gh CLI):
```bash
gh issue list --assignee @me --state open --limit 10
```

조회된 이슈 목록:
```
📋 열린 이슈 (내게 할당됨):
1. #45 토큰 갱신 로직 구현
2. #46 세션 만료 처리
3. #47 OAuth 연동
4. (없음 - 새로 시작)
```

### 4. Ask User for Purpose and Focus

자동 감지 후 사용자에게 질문:

**질문 1: 프로젝트 목적**
```
프로젝트 분석 완료:
- 스택: [감지된 스택]
- 구조: [감지된 구조]

프로젝트의 목적을 한 줄로 설명해주세요:
```

**질문 2: 현재 Focus (이슈 있을 때)**

이슈가 조회된 경우 AskUserQuestion으로 선택:
```
어떤 이슈로 시작할까요?

Options:
- #45 토큰 갱신 로직 구현
- #46 세션 만료 처리
- #47 OAuth 연동
- (직접 입력)
- (나중에 설정)
```

선택한 이슈를 Status.Focus에 자동 설정.

### 5. Generate CLAUDE.md

```markdown
# Project: [프로젝트명]

## Context
- 목적: [사용자 입력]
- 스택: [자동 감지]
- 구조:
  - [감지된 디렉토리 1]
  - [감지된 디렉토리 2]
  - ...

## Status
- Phase: Build
- Focus: [선택한 이슈 또는 -]
- Next: [다음 이슈 또는 -]
- Blocked: -

## Knowledge
- [현재 날짜]: 프로젝트 컨텍스트 초기화
```

**이슈 선택 시 예시**:
```markdown
## Status
- Phase: Build
- Focus: #45 토큰 갱신 로직 구현
- Next: #46 세션 만료 처리
- Blocked: -
```

### 6. Output and Next Steps

생성 완료 후 표시:

```
CLAUDE.md created successfully.

Detected:
- Stack: Node.js, React 18, TypeScript, Vite
- Structure: src/components/, src/pages/, src/hooks/

Next steps:
1. Review the Context section
2. Set your current Focus in Status
3. Start building!

Tip: Update Status at the end of each session.
```

## Template Mode (인자 있을 때)

```bash
/init-context base      # 기본 템플릿
/init-context webapp    # 웹앱 템플릿
/init-context api       # API 서버 템플릿
/init-context library   # 라이브러리 템플릿
```

템플릿 위치: `${CLAUDE_PLUGIN_ROOT}/skills/project-context/templates/`

## Examples

```bash
/init-context           # 자동 분석 (권장)
/init-context webapp    # 웹앱 템플릿 강제 사용
```
