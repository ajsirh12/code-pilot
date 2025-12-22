---
name: gitlab-toolkit
description: GitLab API reference, authentication, and best practices. Reference this skill when working with any GitLab API calls. Includes common patterns, error handling, pagination, and TePS'EG GitLab configuration.
---

# GitLab API Reference

이 스킬은 GitLab API 작업 시 참조하는 공통 가이드입니다.

## TePS'EG GitLab 설정

```bash
# 기본 설정 (고정)
GITLAB_URL="https://gitlab.tepseg.com"

# 프로젝트별 설정
GITLAB_TOKEN="glpat-xxxxxxxxxxxx"  # Personal Access Token
GITLAB_PROJECT_ID="206"            # 프로젝트 ID
```

### 환경변수 설정 방법

```bash
# Linux/macOS (.bashrc 또는 .zshrc)
export GITLAB_URL="https://gitlab.tepseg.com"
export GITLAB_TOKEN="your-token-here"
export GITLAB_PROJECT_ID="your-project-id"

# Windows PowerShell
$env:GITLAB_URL = "https://gitlab.tepseg.com"
$env:GITLAB_TOKEN = "your-token-here"
$env:GITLAB_PROJECT_ID = "your-project-id"

# .env 파일 (프로젝트별)
GITLAB_URL=https://gitlab.tepseg.com
GITLAB_TOKEN=glpat-xxxxxxxxxxxx
GITLAB_PROJECT_ID=206
```

---

## Authentication

### Personal Access Token (권장)

```bash
# Header 방식 (권장)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects"
```

### Token Scopes

| Scope | 설명 |
|-------|------|
| `api` | 전체 API 접근 |
| `read_api` | 읽기 전용 API |
| `read_repository` | 저장소 읽기 |
| `write_repository` | 저장소 쓰기 |
| `read_registry` | Container Registry 읽기 |
| `write_registry` | Container Registry 쓰기 |

---

## API Endpoints

### Core Resources

| 리소스 | Endpoint | 명령어 |
|--------|----------|--------|
| Projects | `/api/v4/projects/:id` | `/gl-settings` |
| Issues | `/api/v4/projects/:id/issues` | `/gl-issue` |
| Merge Requests | `/api/v4/projects/:id/merge_requests` | `/gl-mr` |
| Milestones | `/api/v4/projects/:id/milestones` | `/gl-milestone` |
| Labels | `/api/v4/projects/:id/labels` | `/gl-labels` |
| Releases | `/api/v4/projects/:id/releases` | `/gl-release` |
| Wiki | `/api/v4/projects/:id/wikis` | `/gl-wiki` |
| Snippets | `/api/v4/projects/:id/snippets` | `/gl-snippet` |
| Board | `/api/v4/projects/:id/boards` | `/gl-board` |

### CI/CD

| 리소스 | Endpoint | 명령어 |
|--------|----------|--------|
| Pipelines | `/api/v4/projects/:id/pipelines` | `/gl-pipeline` |
| Variables | `/api/v4/projects/:id/variables` | `/gl-variables` |
| Runners | `/api/v4/runners` | `/gl-runners` |
| Environments | `/api/v4/projects/:id/environments` | `/gl-environments` |

### Project Settings

| 리소스 | Endpoint | 명령어 |
|--------|----------|--------|
| Members | `/api/v4/projects/:id/members` | `/gl-members` |
| Webhooks | `/api/v4/projects/:id/hooks` | `/gl-webhook` |
| Protected Branches | `/api/v4/projects/:id/protected_branches` | `/gl-project` |
| Protected Tags | `/api/v4/projects/:id/protected_tags` | `/gl-tags` |
| Deploy Tokens | `/api/v4/projects/:id/deploy_tokens` | `/gl-project` |

### Repository Operations

| 리소스 | Endpoint | 명령어 |
|--------|----------|--------|
| Commits | `/api/v4/projects/:id/repository/commits` | `/gl-activity` |
| Compare | `/api/v4/projects/:id/repository/compare` | `/gl-compare` |
| Tags | `/api/v4/projects/:id/repository/tags` | `/gl-tags` |
| Files | `/api/v4/projects/:id/repository/files` | `/gl-files` |
| Blame | `/api/v4/projects/:id/repository/files/:path/blame` | `/gl-blame` |
| Tree | `/api/v4/projects/:id/repository/tree` | `/gl-files` |

### Search & Discovery

| 리소스 | Endpoint | 명령어 |
|--------|----------|--------|
| Search | `/api/v4/projects/:id/search` | `/gl-search` |
| Events | `/api/v4/projects/:id/events` | `/gl-activity` |
| Contributors | `/api/v4/projects/:id/repository/contributors` | `/gl-stats` |

### User & Notifications

| 리소스 | Endpoint | 명령어 |
|--------|----------|--------|
| User | `/api/v4/user` | `/gl-inbox` |
| Todos | `/api/v4/todos` | `/gl-inbox` |
| Notification Settings | `/api/v4/notification_settings` | `/gl-notify` |

### Fork & Collaboration

| 리소스 | Endpoint | 명령어 |
|--------|----------|--------|
| Fork | `/api/v4/projects/:id/fork` | `/gl-fork` |
| Forks | `/api/v4/projects/:id/forks` | `/gl-fork` |

---

## Access Levels

| Level | 이름 | 설명 |
|-------|------|------|
| 0 | No access | 접근 불가 (직접 푸시 금지) |
| 10 | Guest | 이슈 조회/코멘트 |
| 20 | Reporter | 코드 조회, 이슈 관리 |
| 30 | Developer | 코드 푸시, MR 생성 |
| 40 | Maintainer | 브랜치 보호, 멤버 관리 |
| 50 | Owner | 모든 권한 |

---

## Available Commands (32)

### Main Workflow
| 명령어 | 설명 |
|--------|------|
| `/gitlab-toolkit` | 7단계 가이드 프로젝트 설정 |

### Core Management
| 명령어 | 설명 |
|--------|------|
| `/gl-issue` | Issue, Assignees, Links, Comments |
| `/gl-mr` | MR, Reviewers, Approvals, Discussions |
| `/gl-inbox` | 내 할일 대시보드 |
| `/gl-milestone` | Milestones |
| `/gl-labels` | Labels (Scoped) |
| `/gl-release` | Release & Tags |
| `/gl-wiki` | Wiki Pages |
| `/gl-snippet` | Code Snippets |
| `/gl-board` | Issue Board |

### CI/CD
| 명령어 | 설명 |
|--------|------|
| `/gl-pipeline` | Pipeline, Schedules |
| `/gl-variables` | CI/CD Variables |
| `/gl-runners` | Runners |
| `/gl-environments` | Deployment Environments |
| `/gl-coverage` | Test Coverage |

### Project Settings
| 명령어 | 설명 |
|--------|------|
| `/gl-project` | Protected Branches, Registry, Badges |
| `/gl-settings` | Project Settings |
| `/gl-members` | Members & Permissions |
| `/gl-webhook` | Webhooks |
| `/gl-cleanup` | Resource Cleanup |
| `/gl-template` | Issue/MR Templates |
| `/gl-notify` | Notification Settings |

### Repository Operations
| 명령어 | 설명 |
|--------|------|
| `/gl-files` | Browse, View, Edit Files |
| `/gl-blame` | Line-by-Line History |
| `/gl-tags` | Git Tags Management |
| `/gl-compare` | Branch Comparison |
| `/gl-revert` | Revert Commits/MRs |
| `/gl-cherry-pick` | Cherry-Pick Commits |
| `/gl-conflicts` | Conflict Resolution |
| `/gl-fork` | Fork Management |

### Workflow Helpers
| 명령어 | 설명 |
|--------|------|
| `/gl-search` | 통합 검색 |
| `/gl-activity` | 프로젝트 활동 피드 |
| `/gl-stats` | 프로젝트 통계 |
| `/gl-draft` | Draft/WIP MR |
| `/gl-auto-merge` | Pipeline 성공 시 자동 머지 |

---

## Quick Actions

Issue/MR 생성 시 사용 가능한 Quick Actions:

```markdown
/assign @user          # 담당자 지정
/label ~bug ~urgent    # 라벨 추가
/milestone %"v1.0"     # 마일스톤 설정
/due tomorrow          # 마감일 설정
/estimate 8h           # 시간 추정
/spend 4h              # 시간 기록
/confidential          # 비공개 설정
/close                 # 닫기
/reopen                # 다시 열기
```

---

## Pagination

```bash
# 페이지네이션 사용
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues?per_page=100&page=1"

# 응답 헤더에서 페이지 정보
# x-total: 전체 개수
# x-total-pages: 전체 페이지 수
# x-page: 현재 페이지
# x-per-page: 페이지당 개수
```

---

## 참고 자료

- **References**: `references/` 폴더 참조
  - `api-patterns.md`: API 호출 패턴
  - `error-handling.md`: 에러 처리
  - `protected-branches.md`: 브랜치 보호 설정
- **Examples**: `examples/` 폴더 참조
  - `project-init.sh`: 프로젝트 초기화 스크립트
  - `cleanup.sh`: 리소스 정리 스크립트
- **Scripts**: `scripts/` 폴더 참조
  - `check-env.sh`: 환경변수 확인

---

## 외부 문서

- [GitLab API Docs](https://docs.gitlab.com/ee/api/)
- [REST API Resources](https://docs.gitlab.com/ee/api/api_resources.html)
- [Quick Actions](https://docs.gitlab.com/ee/user/project/quick_actions.html)
