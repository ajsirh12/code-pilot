---
description: Manage GitLab groups and subgroups - create, list, members, settings
argument-hint: "create|list|members|subgroups|settings [group-path]"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Group Management

그룹 및 서브그룹을 관리한다. 그룹 생성, 멤버 관리, 설정 변경 등을 처리.

## Core Principles

- **권한 확인**: 그룹 생성/수정에는 적절한 권한 필요
- **대화형 선택**: 번호 기반 선택으로 그룹/멤버 지정
- **안전한 변경**: 삭제 작업은 반드시 확인 후 진행

---

## Action Detection

Parse from: $ARGUMENTS

**Supported actions**:
- `create` - 새 그룹/서브그룹 생성
- `list` - 내 그룹 목록 조회
- `members [group-path]` - 그룹 멤버 관리
- `subgroups [group-path]` - 서브그룹 관리
- `settings [group-path]` - 그룹 설정 확인/변경
- (empty) - 내 그룹 목록 표시 후 작업 선택

---

## Workflow: List Groups

**Step 1: Fetch My Groups**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups?min_access_level=10&per_page=50&order_by=name" | \
  jq -r '.[] | "\(.id)|\(.full_path)|\(.name)|\(.visibility)"'
```

**Step 2: Display Numbered List**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 내 GitLab 그룹
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Path                    Name              Visibility
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   ai                      AI Team           🔒 private
 2   ai/research             Research          🔒 private
 3   ai/products             Products          🔒 private
 4   backend                 Backend Team      🔒 private
 5   frontend                Frontend Team     🔓 internal
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

작업 선택:
 • 번호 입력 - 해당 그룹 상세 보기
 • 'create' - 새 그룹 생성
 • 'members [번호]' - 멤버 관리
```

---

## Workflow: Create Group

**Step 1: Determine Type**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🆕 그룹 생성
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

유형 선택:
 1. 📁 최상위 그룹 (Top-level Group)
 2. 📂 서브그룹 (기존 그룹 하위)

선택: [번호]
```

**Step 2: If Subgroup - Select Parent**

Fetch and display parent group options using numbered selection.

**Step 3: Group Details**

```
그룹 정보 입력:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
이름: _______
경로 (URL): _______ (자동: kebab-case)
설명: _______

가시성:
 1. 🔒 private (멤버만 접근)
 2. 🔓 internal (로그인 사용자)
 3. 🌐 public (누구나)

선택: [번호]
```

**Step 4: Create Group**

```bash
# Top-level group
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "GROUP_NAME",
    "path": "group-path",
    "description": "DESCRIPTION",
    "visibility": "private"
  }' \
  "$GITLAB_URL/api/v4/groups"
```

```bash
# Subgroup
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "SUBGROUP_NAME",
    "path": "subgroup-path",
    "parent_id": PARENT_ID,
    "visibility": "private"
  }' \
  "$GITLAB_URL/api/v4/groups"
```

**Step 5: Confirmation**

```
✅ 그룹 생성 완료!

이름: New Team
경로: ai/new-team
ID: 45
URL: https://gitlab.tepseg.com/ai/new-team

다음 단계:
 • /gl-group members ai/new-team - 멤버 추가
 • /gl-bootstrap - 프로젝트 생성
```

---

## Workflow: Group Members

**Step 1: Fetch Current Members**

```bash
GROUP_ID="<from_path_or_id>"
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups/$GROUP_ID/members?per_page=100" | \
  jq '.[] | {id, username, name, access_level, expires_at}'
```

**Step 2: Display Members**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👥 그룹 멤버: ai/research
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Username        Name              Role          Expires
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   @admin          Administrator     👑 Owner      -
 2   @kim.lead       Kim Lead          🔧 Maintainer -
 3   @park.dev       Park Developer    💻 Developer  -
 4   @lee.intern     Lee Intern        👁️ Guest      2024-03-01
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

작업:
 • 'add' - 멤버 추가
 • 'remove [번호]' - 멤버 제거
 • 'change [번호]' - 권한 변경
```

**Step 3: Add Member (Interactive)**

```bash
# Search users
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/users?search=KEYWORD&per_page=20"
```

Display numbered selection, then:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 접근 권한 선택
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   Guest (10)       이슈 조회만
 2   Reporter (20)    코드 조회, 이슈 생성
 3   Developer (30)   푸시, MR 생성
 4   Maintainer (40)  설정 변경, 머지
 5   Owner (50)       전체 관리
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

권한: [번호]
만료일 (선택, YYYY-MM-DD): _______
```

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "user_id=USER_ID&access_level=30&expires_at=2024-12-31" \
  "$GITLAB_URL/api/v4/groups/$GROUP_ID/members"
```

**Step 4: Remove Member**

```bash
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups/$GROUP_ID/members/$USER_ID"
```

---

## Workflow: Subgroups

**Step 1: Fetch Subgroups**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups/$GROUP_ID/subgroups?per_page=100" | \
  jq '.[] | {id, path, name, visibility}'
```

**Step 2: Display**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📂 서브그룹: ai
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Path              Name              Projects
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   ai/research       Research          5
 2   ai/products       Products          12
 3   ai/infrastructure Infrastructure    3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

작업:
 • 'create' - 새 서브그룹 생성
 • [번호] - 해당 서브그룹으로 이동
```

---

## Workflow: Group Settings

**Step 1: Fetch Settings**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups/$GROUP_ID" | \
  jq '{name, path, description, visibility,
       require_two_factor_authentication,
       project_creation_level, subgroup_creation_level}'
```

**Step 2: Display & Options**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ 그룹 설정: ai/research
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
이름:          Research
경로:          ai/research
설명:          AI Research Team
가시성:        🔒 private

보안:
 • 2FA 필수:              ❌ 비활성
 • 프로젝트 생성:         Maintainers
 • 서브그룹 생성:         Maintainers
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

변경할 설정:
 1. 이름/설명
 2. 가시성
 3. 2FA 필수 설정
 4. 프로젝트 생성 권한
 5. 서브그룹 생성 권한

선택: [번호] 또는 'done'
```

**Step 3: Update Settings**

```bash
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "require_two_factor_authentication": true,
    "project_creation_level": "maintainer"
  }' \
  "$GITLAB_URL/api/v4/groups/$GROUP_ID"
```

---

## Error Handling

- **403 Forbidden**: 그룹 생성 권한 없음 → 관리자 문의 안내
- **404 Not Found**: 그룹 없음 → 경로 확인
- **400 Bad Request**: 이미 존재하는 경로 → 다른 이름 제안

---

## Access Level Reference

| Level | Name | 권한 |
|-------|------|------|
| 10 | Guest | 이슈 조회 |
| 20 | Reporter | 코드 조회, 이슈 생성 |
| 30 | Developer | 푸시, MR 생성 |
| 40 | Maintainer | 설정 변경, 머지 |
| 50 | Owner | 전체 관리, 삭제 |
