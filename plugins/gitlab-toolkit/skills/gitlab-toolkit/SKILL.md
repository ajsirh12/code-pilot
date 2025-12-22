---
name: gitlab-toolkit
description: GitLab 워크플로우 자동화 도구. 이슈/MR 관리, CI/CD, 코드리뷰 등 GitLab 작업 시 사용. 트리거: "이슈 만들어", "MR 생성", "파이프라인 확인", "리뷰해줘", "머지해", "릴리즈", "GitLab" 언급 시.
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
- "멤버 추가" → `/gl-members`
- "브랜치 보호" → `/gl-project`
- "릴리즈" → `/gl-release`

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

### 5. 프로젝트 초기 설정 플로우

새 프로젝트 설정 시:

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

## Agents

| 에이전트 | 용도 | 트리거 |
|---------|------|--------|
| `project-initializer` | 프로젝트 초기 설정 | "새 프로젝트", "설정해줘" |
| `mr-reviewer` | MR 자동 리뷰 | "리뷰해줘", "코드 확인" |
| `pipeline-debugger` | 파이프라인 디버깅 | "파이프라인 실패", "왜 안돼" |

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
| **이슈** | `/gl-issue`, `/gl-inbox`, `/gl-search` |
| **MR** | `/gl-mr`, `/gl-draft`, `/gl-auto-merge`, `/gl-conflicts` |
| **CI/CD** | `/gl-pipeline`, `/gl-variables`, `/gl-runners`, `/gl-environments`, `/gl-coverage` |
| **저장소** | `/gl-files`, `/gl-blame`, `/gl-compare`, `/gl-revert`, `/gl-cherry-pick`, `/gl-tags` |
| **설정** | `/gl-project`, `/gl-settings`, `/gl-members`, `/gl-webhook`, `/gl-template`, `/gl-notify` |
| **기타** | `/gl-milestone`, `/gl-labels`, `/gl-release`, `/gl-wiki`, `/gl-snippet`, `/gl-board`, `/gl-stats`, `/gl-activity`, `/gl-fork`, `/gl-cleanup` |
