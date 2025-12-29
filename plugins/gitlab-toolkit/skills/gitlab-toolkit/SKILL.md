---
name: gitlab-toolkit
description: |
  This skill should be used when the user asks to "create GitLab issue", "create MR", "merge request", "check pipeline", "run pipeline", "review MR", "merge", "release", "GitLab project setup", "branch protection", "labels", "milestone", "deploy", "CI/CD", "create group", "create subgroup", "create repository", "invite members", "bootstrap project", "connect to GitLab", "transfer project", "archive project", "CI/CD template", "access audit", "permission check", "wiki", "snippet", "board", "stats", "activity", "fork", "runner", "environment", "coverage", "cleanup", "notify", or mentions GitLab-related workflows. Also triggered by Korean phrases like "이슈 만들어", "MR 생성", "파이프라인", "리뷰", "머지", "릴리즈", "그룹 만들어", "프로젝트 만들어", "GitLab 연결", "팀원 초대", "프로젝트 이전", "아카이브", "권한 감사", "위키", "스니펫", "보드", "통계", "활동", "포크", "러너", "환경", "커버리지", "정리".

  **PROACTIVE WORKFLOW**: 이 스킬은 다른 플러그인 작업의 **시작 전(Pre-work)**과 **완료 후(Post-work)** 모두에서 자동으로 개입해야 합니다.

  - **Pre-work**: 기능 개발, 버그 수정, 리팩토링 등의 작업 시작 전에 이슈 생성/확인 및 브랜치 설정을 제안합니다.
  - **Post-work**: 코드 수정 완료 후 커밋/MR 워크플로우를 제안합니다.
---

# GitLab Toolkit

GitLab 작업을 위한 지능형 워크플로우 자동화 도구.

---

## ⚡ Proactive Workflow Integration

**중요**: 이 스킬은 사용자의 명시적 요청뿐만 아니라, 다른 플러그인 작업의 **시작 전(Pre-work)**과 **완료 후(Post-work)** 모두에서 자동으로 개입해야 합니다.

---

### 🔵 Pre-work: 작업 시작 전 개입

**파일 산출물이 있는 작업**을 시작하기 **전에** gitlab-toolkit이 먼저 개입하여 이슈 생성/확인 및 브랜치 설정을 제안합니다.

#### 코드/개발 관련
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **feature-dev 시작 전** | "기능 추가해줘", "구현해줘" | "관련 이슈가 있나요?" → `/gl-issue create` → 브랜치 생성 |
| **debug-helper 시작 전** | "버그 수정해줘", "에러 고쳐줘" | "버그 이슈를 확인/생성할까요?" → `/gl-issue create --label bug` |
| **refactoring 시작 전** | "리팩토링 해줘", "정리해줘" | "리팩토링 이슈를 생성할까요?" → `/gl-issue create --label refactor` |
| **dependency-check 시작 전** | "의존성 업데이트" | "업데이트 이슈를 생성할까요?" → `/gl-issue create --label dependencies` |

#### 디자인/UI 관련
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **frontend-design 시작 전** | "UI 만들어줘", "컴포넌트 디자인" | "디자인 이슈를 생성할까요?" → `/gl-issue create --label design` |
| **canvas-design 시작 전** | "포스터 만들어줘", "디자인 작업" | "디자인 작업 이슈를 생성할까요?" |

#### 문서 관련
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **doc-coauthoring 시작 전** | "문서 작성해줘", "README 업데이트" | "문서 이슈를 생성할까요?" → `/gl-issue create --label docs` |
| **api-designer 시작 전** | "API 문서 작성", "스펙 정리" | "API 문서 이슈를 생성할까요?" → `/gl-issue create --label docs` |

#### GitLab 내부 산출물 (반복 워크플로우)
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **/gl-mr 시작 전** | "MR 만들어줘" | "관련 이슈를 연결할까요?" → `Closes #이슈번호` |
| **/gl-wiki 시작 전** | "위키 작성해줘", "문서화해줘" | "관련 이슈를 연결할까요?" → `/gl-search` |
| **/gl-snippet 시작 전** | "스니펫 만들어줘", "코드 공유" | "관련 이슈가 있나요?" |
| **/gl-release 시작 전** | "릴리즈 만들어줘", "버전 배포" | "보안 감사 먼저 실행" → `security-auditor` 에이전트 |
| **/gl-tags 시작 전** | "태그 만들어줘" | "릴리즈와 연결할까요?" |
| **프로덕션 배포 전** | "배포해줘", "deploy" | "보안 점검 먼저 실행할까요?" → `security-auditor` 에이전트 |

#### 코드 탐색/분석 (code-navigator)
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **debug-helper 시작 전** | "버그 고쳐줘" | "blame으로 원인 파악할까요?" → `code-navigator` 에이전트 |
| **/gl-mr create 시작 전** | "MR 만들어줘" | "변경사항을 compare로 확인할까요?" → `code-navigator` 에이전트 |

#### 레지스트리/배포 (registry-manager)
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **/gl-environments deploy 시작 전** | "배포해줘" | "배포할 이미지 태그를 확인할까요?" → `registry-manager` 에이전트 |
| **/gl-cleanup 시작 전** | "정리해줘" | "삭제할 이미지 목록을 확인할까요?" → `registry-manager` 에이전트 |

#### 기타
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **code-quality 리뷰 시작 전** | "코드 리뷰해줘" | "리뷰 대기 목록 확인" → `/gl-inbox` |
| **기타 산출물 플러그인** | 파일 생성/수정 예상 | "관련 이슈를 생성할까요?" |

#### Pre-work 워크플로우 체인

```
사용자: "로그인 기능 추가해줘"
        ↓
[1단계] gitlab-toolkit 개입 (Pre-work)
        ↓
    "관련 이슈가 있나요?"
        ├─ 있음 → 기존 이슈 연결 (#123)
        └─ 없음 → "이슈를 먼저 생성할까요?"
                    ↓
                /gl-issue create "로그인 기능 추가"
                    ↓
                "브랜치를 생성할까요?"
                    ↓
                git checkout -b feature/123-login
                    ↓
[2단계] feature-dev 작업 시작
        ↓
[3단계] gitlab-toolkit 개입 (Post-work)
        ↓
    커밋 → MR 생성
```

#### Pre-work 자동 제안 패턴

개발 작업 요청이 감지되면 다음과 같이 제안:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 개발 작업 시작 전 확인
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
요청: "로그인 기능 추가"

📋 관련 이슈 검색 중...
   → #123 로그인 기능 구현 (opened)
   → #125 인증 모듈 리팩토링 (opened)

🔄 다음 단계:
   1. 기존 이슈 연결 (#123)
   2. 새 이슈 생성
   3. 이슈 없이 진행
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 🟢 Post-work: 작업 완료 후 개입

**파일 산출물이 생성/수정된 후** gitlab-toolkit이 커밋/MR 워크플로우를 제안합니다.

#### 일반 규칙
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **Edit/Write 도구 사용 후** | 파일 수정 완료 | "변경사항을 커밋할까요?" → `/gl-commit` |
| **Task 에이전트 완료 후** | 산출물 생성 완료 | "변경사항을 커밋할까요?" → `/gl-commit` |

#### 코드/개발 관련
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **feature-dev 완료 후** | 기능 구현 완료 | "MR을 생성할까요?" → `/gl-mr create` |
| **refactoring 완료 후** | 리팩토링 완료 | "변경사항을 커밋할까요?" → `/gl-commit` |
| **debug-helper 완료 후** | 버그 수정 완료 | "핫픽스 MR을 생성할까요?" → `/gl-mr create` |
| **dependency-check 완료 후** | 의존성 업데이트 완료 | "변경사항을 커밋할까요?" → `/gl-commit` |
| **code-quality 리뷰 통과** | 리뷰 완료 | "MR을 업데이트할까요?" |

#### 디자인/UI 관련
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **frontend-design 완료 후** | UI 컴포넌트 생성 완료 | "디자인 변경사항을 커밋할까요?" → `/gl-commit` |
| **canvas-design 완료 후** | 디자인 파일 생성 완료 | "디자인 파일을 커밋할까요?" → `/gl-commit` |
| **algorithmic-art 완료 후** | 아트 산출물 생성 완료 | "산출물을 커밋할까요?" → `/gl-commit` |

#### 문서 관련
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **doc-coauthoring 완료 후** | 문서 작성 완료 | "문서 변경사항을 커밋할까요?" → `/gl-commit` |
| **api-designer 완료 후** | API 문서 생성 완료 | "API 문서를 커밋할까요?" → `/gl-commit` |

#### GitLab 내부 산출물 (반복 워크플로우)
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **/gl-issue 완료 후** | 이슈 생성 완료 | "브랜치를 생성할까요?" → `git checkout -b feature/#issue` |
| **/gl-mr 완료 후** | MR 생성 완료 | "자동 머지를 설정할까요?" → `/gl-auto-merge` |
| **/gl-wiki 완료 후** | 위키 페이지 생성 완료 | "관련 이슈를 업데이트할까요?" → 이슈에 위키 링크 추가 |
| **/gl-snippet 완료 후** | 스니펫 생성 완료 | "관련 이슈에 스니펫 링크를 추가할까요?" |
| **/gl-tags 완료 후** | 태그 생성 완료 | "릴리즈를 생성할까요?" → `/gl-release create` |
| **/gl-release 완료 후** | 릴리즈 생성 완료 | "마일스톤을 닫을까요?" → `/gl-milestone close` |
| **/gl-milestone 완료 후** | 마일스톤 생성 완료 | "이슈를 마일스톤에 할당할까요?" |

#### 파이프라인 모니터링
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **/gl-commit 후 파이프라인 실패** | CI 빌드 실패 | "파이프라인 디버깅을 도와드릴까요?" → `pipeline-debugger` 에이전트 |
| **/gl-mr 후 파이프라인 실패** | MR 파이프라인 실패 | "실패 원인을 분석해드릴까요?" → `pipeline-debugger` 에이전트 |
| **push 후 파이프라인 실패** | CI 실패 감지 | "파이프라인 로그를 분석할까요?" → `pipeline-debugger` 에이전트 |

#### 코드 탐색/분석 (code-navigator)
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **핫픽스 커밋 완료 후** | main 브랜치에서 버그 수정 | "다른 브랜치에도 cherry-pick 할까요?" → `code-navigator` 에이전트 |
| **/gl-release 완료 후** | 릴리즈 생성 완료 | "릴리즈 태그를 생성할까요?" → `code-navigator` 에이전트 |

#### 레지스트리/배포 (registry-manager)
| 트리거 | 감지 방법 | 제안 액션 |
|--------|----------|----------|
| **Docker 빌드 완료 후** | 파이프라인 빌드 성공 | "이미지 태그를 확인할까요?" → `registry-manager` 에이전트 |
| **/gl-release 완료 후** | 릴리즈 생성 완료 | "오래된 이미지를 정리할까요?" → `registry-manager` 에이전트 |

#### 범용 규칙
**파일 산출물이 있는 모든 플러그인**이 작업을 완료하면:
1. `git status` 확인
2. 변경사항이 있으면 커밋 제안
3. 기능 완료 시 MR 생성 제안

### 자동 제안 패턴

코드 변경이 감지되면 다음과 같이 제안:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 변경된 파일이 있습니다:
   M src/components/Auth.tsx
   M src/hooks/useAuth.ts
   A src/utils/validation.ts

🔄 다음 단계:
   1. /gl-commit     - 변경사항 커밋
   2. /gl-mr create  - MR 생성 (커밋 후)
   3. 계속 작업      - 나중에 커밋
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 연동되는 플러그인

- **feature-dev**: 기능 개발 완료 → MR 생성 제안
- **refactoring**: 리팩토링 완료 → 커밋 제안
- **code-quality**: 리뷰 완료 → 커밋/MR 업데이트 제안
- **debug-helper**: 버그 수정 완료 → 핫픽스 커밋 제안
- **dependency-check**: 의존성 업데이트 → 커밋 제안
- **frontend-design**: UI 작업 완료 → 커밋 제안
- **canvas-design**: 디자인 완료 → 커밋 제안
- **doc-coauthoring**: 문서 작성 완료 → 커밋 제안
- **api-designer**: API 문서 완료 → 커밋 제안

### 워크플로우 체인

```
다른 플러그인 작업 완료
        ↓
git status 확인 (자동)
        ↓
변경사항 있음?
    ├─ Yes → 커밋 제안 (/gl-commit)
    │           ↓
    │       MR 필요?
    │           ├─ Yes → MR 생성 (/gl-mr create)
    │           └─ No → 완료
    └─ No → 완료
```

---

### 🔧 One-time Setup (초기 설정)

다음 명령어들은 **프로젝트 초기 설정** 시 1회만 실행되며, Pre-work/Post-work 워크플로우가 필요하지 않습니다.

| 명령어 | 용도 | 실행 시점 |
|--------|------|----------|
| `/gl-bootstrap` | 프로젝트/그룹 생성 | 프로젝트 시작 시 1회 |
| `/gl-group` | 그룹/서브그룹 생성 | 조직 구성 시 1회 |
| `/gl-labels` | 라벨 스킴 설정 | 프로젝트 초기화 시 1회 |
| `/gl-board` | 이슈 보드 설정 | 프로젝트 초기화 시 1회 |
| `/gl-template` | 이슈/MR 템플릿 | 프로젝트 초기화 시 1회 |
| `/gl-templates` | CI/CD 템플릿 생성 | CI/CD 설정 시 1회 |
| `/gl-webhook` | 웹훅 설정 | 통합 설정 시 1회 |
| `/gl-variables` | CI/CD 변수 설정 | CI/CD 설정 시 1회 |
| `/gl-environments` | 환경 설정 | 배포 설정 시 1회 |
| `/gl-runners` | 러너 등록 | CI/CD 설정 시 1회 |
| `/gl-deploy-keys` | 배포 키 설정 | 배포 설정 시 1회 |
| `/gl-tokens` | 토큰 생성 | 필요 시 |
| `/gl-members` | 멤버 초대 | 팀 구성 시 |

**참고**: 이 명령어들은 `/gitlab-toolkit` 가이드 워크플로우에서 순차적으로 안내됩니다.

---

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

### 문서화/협업
- "위키 작성/관리" → `/gl-wiki`
- "스니펫 공유" → `/gl-snippet`
- "이슈 보드" → `/gl-board`

### 프로젝트 분석
- "통계/현황" → `/gl-stats`
- "활동 피드" → `/gl-activity`
- "포크 관리" → `/gl-fork`

### DevOps/운영
- "Runner 관리" → `/gl-runners`
- "환경/배포" → `/gl-environments`
- "테스트 커버리지" → `/gl-coverage`
- "정리/cleanup" → `/gl-cleanup`
- "알림 설정" → `/gl-notify`

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

### 7. CI/CD 환경 관리 플로우

Runner, 환경, 배포 관리:

```
1. /gl-runners
   → Runner 상태 확인, 등록

2. /gl-environments
   → 환경별 배포 현황

3. /gl-coverage
   → 테스트 커버리지 확인

4. /gl-cleanup
   → 오래된 이미지/아티팩트 정리
```

### 8. 보안 감사 플로우

프로젝트 보안 점검:

```
1. /gl-audit access
   → 접근 권한 전체 조회

2. /gl-audit tokens
   → 활성 토큰 점검

3. /gl-audit security
   → 보안 설정 점검

4. /gl-audit
   → 종합 감사 리포트 생성
```

### 9. 문서화/협업 플로우

팀 문서 및 협업 도구:

```
1. /gl-wiki
   → 프로젝트 위키 관리

2. /gl-snippet
   → 코드 스니펫 공유

3. /gl-board
   → 이슈 보드 설정
```

### 10. 프로젝트 분석 플로우

프로젝트 현황 파악:

```
1. /gl-stats
   → 이슈, MR, 기여자 통계

2. /gl-activity
   → 최근 활동 피드

3. /gl-fork
   → 포크 관리, 업스트림 동기화
```

### 11. 코드 히스토리 플로우

변경 이력 추적 및 복구:

```
1. /gl-blame
   → 라인별 커밋 이력 확인

2. /gl-files
   → 파일 브라우징/수정

3. /gl-cherry-pick
   → 특정 커밋 다른 브랜치로

4. /gl-revert
   → 커밋/MR 되돌리기
```

### 12. 프로젝트 라이프사이클 플로우

프로젝트 이전/정리:

```
1. /gl-transfer
   → 프로젝트 그룹 이전

2. /gl-transfer archive
   → 프로젝트 아카이브

3. /gl-cleanup
   → 레지스트리/아티팩트 정리

4. /gl-fork
   → 포크로 분리/기여
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

## Agents (8 Total) - 모두 PROACTIVE

| 에이전트 | 용도 | Proactive | 트리거 |
|---------|------|-----------|--------|
| `project-initializer` | 프로젝트 초기 설정 | 🔵 Pre-work | 새 프로젝트 작업 시작 전 |
| `issue-manager` | 이슈, 라벨, 마일스톤 | 🔵 Pre-work | 개발 작업 시작 전 |
| `security-auditor` | 보안 감사, 취약점 | 🔵 Pre-work | 릴리즈/배포 전 |
| `code-navigator` | 파일 히스토리, blame | 🔵🟢 양방향 | 버그 수정 전 blame, 핫픽스 후 cherry-pick |
| `registry-manager` | 레지스트리, 토큰 관리 | 🔵🟢 양방향 | 배포 전 이미지 확인, 릴리즈 후 정리 |
| `git-workflow` | Git 커밋, 브랜치 정리 | 🟢 Post-work | 파일 수정 완료 후 |
| `mr-workflow` | MR 생성/리뷰/머지 | 🟢 Post-work | 커밋 완료 후 |
| `pipeline-debugger` | 파이프라인 디버깅 | 🟢 Post-work | 파이프라인 실패 시 |

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
