---
name: gitlab-toolkit
description: This skill should be used when the user asks to "create GitLab issue", "create MR", "merge request", "check pipeline", "run pipeline", "review MR", "merge", "release", "GitLab project setup", "branch protection", "labels", "milestone", "deploy", "CI/CD", "create group", "create subgroup", "create repository", "invite members", "bootstrap project", "connect to GitLab", "transfer project", "archive project", "CI/CD template", "access audit", "permission check", or mentions GitLab-related workflows. Also triggered by Korean phrases like "이슈 만들어", "MR 생성", "파이프라인", "리뷰", "머지", "릴리즈", "그룹 만들어", "프로젝트 만들어", "GitLab 연결", "팀원 초대", "프로젝트 이전", "아카이브", "권한 감사".
---

# GitLab Toolkit

GitLab 작업을 위한 지능형 워크플로우 자동화 도구.

## Workflow Decision Tree

사용자 요청에 따라 적절한 워크플로우 선택:

### 이슈/작업 관리
- "이슈 만들어/생성" → `/gl-issue create`
- "내 할일/리뷰 대기" → `/gl-inbox`
- "이슈 검색/찾아" → `/gl-search`

### MR/코드 리뷰
- "MR 만들어/생성" → `/gl-mr create`
- "리뷰어 지정" → `/gl-mr review`
- "승인해/approve" → `/gl-mr approve`
- "머지해" → `/gl-mr merge` 또는 `/gl-auto-merge`
- "코멘트 확인" → `/gl-mr comments`

### CI/CD
- "파이프라인 확인/실행" → `/gl-pipeline`
- "파이프라인 실패" → pipeline-debugger 에이전트
- "변수 설정" → `/gl-variables`

### 저장소 작업
- "브랜치 비교" → `/gl-compare`
- "파일 보기/수정" → `/gl-files`
- "히스토리/blame" → `/gl-blame`
- "되돌려/revert" → `/gl-revert`
- "체리픽" → `/gl-cherry-pick`

### 프로젝트 설정
- "새 프로젝트 설정" → `/gitlab-toolkit` (7단계 가이드)
- "프로젝트 만들어/생성" → `/gl-bootstrap` (그룹/서브그룹/프로젝트 생성)
- "GitLab 연결" → `/gl-bootstrap` (.git 감지 후 연동)
- "그룹/서브그룹 관리" → `/gl-group`
- "프로젝트 이전/아카이브" → `/gl-transfer`
- "멤버 초대/추가" → `/gl-members` 또는 `/gl-group members`
- "브랜치 보호" → `/gl-project`
- "릴리즈" → `/gl-release`

### CI/CD 템플릿
- "CI/CD 템플릿" → `/gl-templates` (프로젝트 타입별 자동 생성)
- "Node.js 파이프라인" → `/gl-templates nodejs`
- "Docker 빌드" → `/gl-templates docker`

### 보안 감사
- "권한 감사/확인" → `/gl-audit`
- "접근 권한 조회" → `/gl-audit access`
- "토큰 점검" → `/gl-audit tokens`

---

## Common Workflows

### 1. 기능 개발 플로우

사용자가 새 기능 개발을 시작할 때:

```
1. /gl-issue create
   → 기능 이슈 생성, 라벨/마일스톤 설정

2. 브랜치 생성 & 개발
   → git checkout -b feature/xxx

3. /gl-mr create
   → MR 생성 (Closes #이슈번호 포함)
   → Draft 상태로 시작 권장

4. /gl-mr review @reviewer
   → 리뷰어 지정

5. /gl-pipeline
   → 파이프라인 상태 확인

6. /gl-auto-merge
   → 파이프라인 성공 시 자동 머지 설정
```

### 2. 버그 수정 플로우

긴급 버그 수정 시:

```
1. /gl-issue 또는 /gl-search
   → 버그 이슈 확인

2. /gl-mr create
   → 핫픽스 MR 생성 (Fixes #이슈번호)

3. /gl-pipeline
   → 파이프라인 확인

4. /gl-mr merge
   → 리뷰 후 즉시 머지
```

### 3. 코드 리뷰 플로우

리뷰어로서 MR 검토 시:

```
1. /gl-inbox
   → 내 리뷰 대기 목록 확인

2. /gl-mr comments !id
   → 기존 코멘트 확인

3. /gl-compare
   → 변경사항 비교

4. /gl-mr comments !id add
   → 코멘트 작성

5. /gl-mr approve !id
   → 승인 또는 변경 요청
```

### 4. 릴리즈 플로우

버전 릴리즈 시:

```
1. /gl-milestone
   → 마일스톤 완료 확인

2. /gl-tags create v1.0.0
   → 태그 생성

3. /gl-release create v1.0.0
   → 릴리즈 노트 작성

4. /gl-pipeline
   → 릴리즈 파이프라인 확인
```

### 5. 프로젝트 부트스트랩 플로우 (NEW)

새 프로젝트를 처음부터 생성할 때:

```
/gl-bootstrap
→ .git 감지에 따른 분기:

[.git 없음]
  1. GITLAB_URL, TOKEN 확인
  2. Group 선택 (번호 선택)
  3. Subgroup 선택 (번호 선택)
  4. Project 이름/설명 입력
  5. Project 생성
  6. git init & remote 설정
  7. 팀원 초대 (검색 후 번호 선택)

[.git 있음, remote 없음]
  1. 새 GitLab 프로젝트 생성 or 기존 연결
  2. remote 설정
  3. push

[.git + GitLab remote]
  → /gl-project 로 설정 확인
```

### 6. 프로젝트 초기 설정 플로우

기존 프로젝트 설정 최적화:

```
/gitlab-toolkit
→ 7단계 가이드 실행:
  1. 환경변수 확인
  2. 브랜치 보호 설정
  3. 라벨 생성
  4. 마일스톤 설정
  5. 이슈/MR 템플릿
  6. CI/CD 변수
  7. 웹훅 설정
```

---

## Command Chaining

### 이슈 → MR → 머지 체인
```bash
# 이슈 생성
/gl-issue create "기능 제목" --labels feature

# MR 생성 (이슈 링크)
/gl-mr create --closes #123

# 리뷰어 지정 + 자동머지
/gl-mr review !45 @reviewer
/gl-auto-merge !45
```

### 파이프라인 디버깅 체인
```bash
# 실패 확인
/gl-pipeline status

# 로그 확인 (에이전트 사용)
→ pipeline-debugger 에이전트 호출

# 재시도
/gl-pipeline retry
```

### 충돌 해결 체인
```bash
# 충돌 확인
/gl-conflicts !45

# 비교
/gl-compare main...feature-branch

# 해결 후 머지
/gl-mr merge !45
```

---

## 환경 설정

```bash
# 필수 환경변수
export GITLAB_URL="https://gitlab.tepseg.com"
export GITLAB_TOKEN="glpat-xxxxxxxxxxxx"
export GITLAB_PROJECT_ID="206"
```

환경변수 확인: `scripts/check-env.sh`

---

## Quick Actions (MR/이슈 본문에서 사용)

```markdown
/assign @user          # 담당자
/label ~bug ~urgent    # 라벨
/milestone %"v1.0"     # 마일스톤
/due tomorrow          # 마감일
/estimate 8h           # 예상 시간
/spend 4h              # 작업 시간
/close                 # 닫기
```

---

## Agents (8 Total)

| 에이전트 | 용도 | 트리거 |
|---------|------|--------|
| `project-initializer` | 프로젝트 초기 설정 | "새 프로젝트 설정", "branch protection" |
| `pipeline-debugger` | 파이프라인 디버깅 | "파이프라인 실패", "CI 에러" |
| `git-workflow` | Git 커밋, 브랜치 정리 | "커밋해줘", "브랜치 정리" |
| `issue-manager` | 이슈, 라벨, 마일스톤 | "이슈 만들어", "라벨 설정" |
| `mr-workflow` | MR 생성/리뷰/머지 | "MR 만들어", "머지해줘" |
| `code-navigator` | 파일 히스토리, blame | "blame 확인", "태그 생성" |
| `registry-manager` | 레지스트리, 토큰 관리 | "이미지 정리", "토큰 생성" |
| `security-auditor` | 보안 감사, 취약점 | "보안 점검", "취약점 확인" |

---

## 참조 문서

상세 정보는 `references/` 참조:
- `api-patterns.md` - API 호출 패턴
- `error-handling.md` - 에러 처리
- `protected-branches.md` - 브랜치 보호

---

## 명령어 Quick Reference

| 카테고리 | 명령어 |
|---------|--------|
| **부트스트랩** | `/gl-bootstrap` (프로젝트 생성), `/gl-group` (그룹 관리) |
| **이슈** | `/gl-issue`, `/gl-inbox`, `/gl-search` |
| **MR** | `/gl-mr`, `/gl-draft`, `/gl-auto-merge`, `/gl-conflicts` |
| **CI/CD** | `/gl-pipeline`, `/gl-variables`, `/gl-runners`, `/gl-environments`, `/gl-coverage`, `/gl-templates` |
| **저장소** | `/gl-files`, `/gl-blame`, `/gl-compare`, `/gl-revert`, `/gl-cherry-pick`, `/gl-tags` |
| **설정** | `/gl-project`, `/gl-settings`, `/gl-members`, `/gl-webhook`, `/gl-template`, `/gl-notify` |
| **관리** | `/gl-transfer` (이전/아카이브), `/gl-audit` (권한 감사), `/gl-cleanup` |
| **기타** | `/gl-milestone`, `/gl-labels`, `/gl-release`, `/gl-wiki`, `/gl-snippet`, `/gl-board`, `/gl-stats`, `/gl-activity`, `/gl-fork` |
