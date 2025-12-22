---
description: Bootstrap GitLab project - detect .git, create groups/subgroups/repos, invite members
argument-hint: "[group] [subgroup] [project-name]"
allowed-tools: Bash(git:*), Bash(curl:*), Bash(test:*), Bash(ls:*), Bash(mkdir:*), AskUserQuestion, TodoWrite
---

# GitLab Project Bootstrap

프로젝트를 GitLab과 연동하기 위한 부트스트랩 워크플로우. `.git` 디렉토리 유무를 감지하여 적절한 워크플로우를 제안한다.

## Core Principles

- **자동 감지**: .git 디렉토리 존재 여부로 현재 상태 파악
- **대화형 선택**: Group, Subgroup, Project를 동적으로 선택
- **단계별 진행**: 각 단계에서 사용자 확인 후 진행
- **환경변수 자동 설정**: GITLAB_PROJECT_ID 등 필요한 변수 설정

---

## Phase 1: Environment Detection

**Step 1.1: Check .git Directory**

```bash
# .git 존재 확인
if [ -d ".git" ]; then
  echo "GIT_STATUS=EXISTS"
  git remote -v 2>/dev/null || echo "NO_REMOTE"
else
  echo "GIT_STATUS=NOT_FOUND"
fi
```

**Step 1.2: Check GitLab Environment**

```bash
echo "GITLAB_URL: ${GITLAB_URL:-NOT SET}"
echo "GITLAB_TOKEN: ${GITLAB_TOKEN:+SET}"
echo "GITLAB_PROJECT_ID: ${GITLAB_PROJECT_ID:-NOT SET}"
```

**Step 1.3: Determine Workflow**

| .git | Remote | GITLAB_PROJECT_ID | 워크플로우 |
|------|--------|-------------------|-----------|
| ❌ | - | - | **New Project** (Phase 2) |
| ✅ | ❌ | - | **Connect Existing** (Phase 3) |
| ✅ | ✅ (GitLab) | ❌ | **Auto-detect** (Phase 4) |
| ✅ | ✅ (GitLab) | ✅ | **Ready** (Phase 5) |
| ✅ | ✅ (Other) | - | **Mirror/Import** (Phase 6) |

---

## Phase 2: New Project Workflow (No .git)

**Step 2.1: Fetch Available Groups**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups?min_access_level=30&per_page=100" | \
  jq -r '.[] | "\(.id)|\(.full_path)|\(.name)"'
```

**Step 2.2: Interactive Group Selection**

Display numbered list:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 사용 가능한 Groups
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Group Path              Name
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   ai                      AI Team
 2   backend                 Backend Team
 3   frontend                Frontend Team
 4   devops                  DevOps Team
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

선택: [번호] 또는 'new' (새 그룹 생성)
```

**Step 2.3: Subgroup Selection (if exists)**

```bash
# 선택한 그룹의 서브그룹 조회
GROUP_ID="<selected>"
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups/$GROUP_ID/subgroups?per_page=100" | \
  jq -r '.[] | "\(.id)|\(.path)|\(.name)"'
```

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📂 Subgroups in "ai"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Path                    Name
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 0   (root)                  ai 그룹 직속
 1   research                Research
 2   products                Products
 3   infrastructure          Infrastructure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

선택: [번호] 또는 'new' (새 서브그룹 생성)
```

**Step 2.4: Project Name Input**

```
📦 프로젝트 정보 입력
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

프로젝트 경로: ai/research/[project-name]

프로젝트 이름: _______
설명 (선택): _______
가시성:
  1. private (기본)
  2. internal
  3. public
```

**Step 2.5: Create Project**

```bash
NAMESPACE_ID="<group_or_subgroup_id>"
PROJECT_NAME="<user_input>"
DESCRIPTION="<user_input>"
VISIBILITY="private"

curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data "{
    \"name\": \"$PROJECT_NAME\",
    \"path\": \"$PROJECT_NAME\",
    \"namespace_id\": $NAMESPACE_ID,
    \"description\": \"$DESCRIPTION\",
    \"visibility\": \"$VISIBILITY\",
    \"initialize_with_readme\": false
  }" \
  "$GITLAB_URL/api/v4/projects"
```

**Step 2.6: Initialize Local Git**

```bash
git init
git remote add origin "git@gitlab.tepseg.com:ai/research/$PROJECT_NAME.git"
echo "# $PROJECT_NAME" > README.md
git add README.md
git commit -m "Initial commit"
git push -u origin main
```

**Step 2.7: Set Environment**

```
✅ 프로젝트 생성 완료!

export GITLAB_PROJECT_ID="<new_id>"

다음 단계:
1. /gl-members invite - 팀원 초대
2. /gl-project protect - 브랜치 보호 설정
3. /gl-labels - 라벨 생성
```

---

## Phase 3: Connect Existing (.git exists, no remote)

**Step 3.1: Options**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📂 Git 저장소 감지됨 (remote 없음)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

옵션:
 1. 🆕 새 GitLab 프로젝트 생성 후 연결
 2. 🔗 기존 GitLab 프로젝트에 연결
 3. 📋 프로젝트 목록 검색

선택: [번호]
```

**Option 1**: Phase 2 workflow (skip git init)

**Option 2**: Search and connect
```bash
# 프로젝트 검색
SEARCH_TERM="<user_input>"
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects?search=$SEARCH_TERM&membership=true" | \
  jq '.[] | {id, path_with_namespace, name}'
```

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 검색 결과: "my-app"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   ID    Path                      Name
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   206   ai/products/my-app        My App
 2   198   backend/my-app-api        My App API
 3   212   frontend/my-app-web       My App Web
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

연결할 프로젝트: [번호]
```

```bash
# Connect
PROJECT_PATH="<selected_path>"
git remote add origin "git@gitlab.tepseg.com:$PROJECT_PATH.git"
git fetch origin
git branch --set-upstream-to=origin/main main
```

---

## Phase 4: Auto-detect Project ID (.git with GitLab remote)

```bash
# Remote URL에서 프로젝트 경로 추출
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
PROJECT_PATH=$(echo "$REMOTE_URL" | sed -E 's|.*[:/]([^/]+/[^/]+)\.git$|\1|')

# API로 프로젝트 ID 조회
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$(echo $PROJECT_PATH | sed 's/\//%2F/g')" | \
  jq '{id, name, path_with_namespace}'
```

```
✅ GitLab 프로젝트 감지됨!

프로젝트: ai/research/code-pilot
ID: 206

환경변수 설정:
export GITLAB_PROJECT_ID="206"

/gl-project 으로 설정을 확인하시겠습니까? [y/n]
```

---

## Phase 5: Ready State

```
✅ GitLab 연동 완료 상태

프로젝트: ai/research/code-pilot
ID: 206
URL: https://gitlab.tepseg.com/ai/research/code-pilot

현재 브랜치: main
Remote: origin → git@gitlab.tepseg.com:ai/research/code-pilot.git

가능한 작업:
• /gl-members - 팀원 관리
• /gl-project - 설정 확인
• /gl-issue - 이슈 관리
• /gl-mr - MR 관리
```

---

## Phase 6: Mirror/Import (Other Git Host)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  다른 Git 호스트 감지됨
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

현재 Remote: github.com/user/repo

옵션:
 1. 🔄 GitLab으로 Import (히스토리 포함)
 2. 🪞 GitLab Mirror 설정 (양방향 동기화)
 3. ➕ GitLab Remote 추가 (origin 유지)

선택: [번호]
```

**Option 1: Import**
```bash
# GitLab Import API
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "url": "https://github.com/user/repo.git",
    "path": "imported-repo",
    "namespace": "<namespace_id>"
  }' \
  "$GITLAB_URL/api/v4/projects"
```

**Option 3: Add GitLab as secondary remote**
```bash
git remote add gitlab "git@gitlab.tepseg.com:ai/research/repo.git"
git push gitlab main
```

---

## Workflow: Create New Group

**When user selects 'new' for group**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🆕 새 그룹 생성
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

그룹 이름: _______
경로 (URL): _______  (자동: kebab-case 변환)
설명: _______
가시성:
  1. private (기본)
  2. internal
  3. public
```

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "New Team",
    "path": "new-team",
    "description": "New team workspace",
    "visibility": "private"
  }' \
  "$GITLAB_URL/api/v4/groups"
```

---

## Workflow: Create New Subgroup

**When user selects 'new' for subgroup**:

```bash
PARENT_GROUP_ID="<parent_id>"
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "New Subgroup",
    "path": "new-subgroup",
    "parent_id": '"$PARENT_GROUP_ID"',
    "visibility": "private"
  }' \
  "$GITLAB_URL/api/v4/groups"
```

---

## Workflow: Invite Members (Interactive)

**Step 1: Fetch available users to invite**

```bash
# 검색으로 사용자 찾기
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/users?search=<keyword>&per_page=20" | \
  jq '.[] | {id, username, name, email}'
```

**Step 2: Display numbered list**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👥 초대할 멤버 검색: "kim"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Username        Name              Email
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   @kim.developer  Kim Developer     kim.dev@company.com
 2   @kim.designer   Kim Designer      kim.design@company.com
 3   @kimchi         Kimchi Master     kimchi@company.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

선택: 단일(2) | 다중(1,3) | 범위(1-3) | 검색(s) | 완료(done)
```

**Step 3: Select access level**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 접근 권한 선택
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Level          설명
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   Guest (10)     이슈 조회만 가능
 2   Reporter (20)  코드 조회, 이슈 생성
 3   Developer (30) 푸시, MR 생성 (권장)
 4   Maintainer (40) 설정 변경, 머지
 5   Owner (50)     전체 관리 권한
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

권한 레벨: [번호]
```

**Step 4: Add members**

```bash
for USER_ID in $SELECTED_USERS; do
  curl --request POST \
    --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    --data "user_id=$USER_ID&access_level=$ACCESS_LEVEL" \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members"
done
```

**Step 5: Confirmation**

```
✅ 멤버 초대 완료!

초대된 멤버:
 • @kim.developer (Developer)
 • @kim.designer (Developer)

초대 이메일이 발송되었습니다.
```

---

## Error Handling

- **403 Forbidden**: Group/Subgroup 생성 권한 없음 → 관리자 문의 안내
- **409 Conflict**: 이미 존재하는 이름 → 다른 이름 제안
- **404 Not Found**: Group/Project 없음 → 검색 재시도
- **No groups available**: 권한 있는 그룹 없음 → 새 그룹 생성 안내

---

## Output Summary

모든 단계 완료 후:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 GitLab 프로젝트 부트스트랩 완료!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 프로젝트 정보:
   이름: my-awesome-app
   경로: ai/products/my-awesome-app
   ID: 256
   URL: https://gitlab.tepseg.com/ai/products/my-awesome-app

🔗 Git Remote:
   origin → git@gitlab.tepseg.com:ai/products/my-awesome-app.git

👥 팀원:
   • @kim.developer (Developer)
   • @park.manager (Maintainer)

📋 환경변수:
   export GITLAB_PROJECT_ID="256"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

다음 단계 추천:
1. /gl-project protect - 브랜치 보호 설정
2. /gl-labels - 라벨 생성
3. /gitlab-toolkit - 전체 초기화 가이드
```
