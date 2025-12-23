---
description: Transfer project to another group or archive/unarchive project
argument-hint: "move|archive|unarchive|export|import"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Project Transfer & Archive

프로젝트를 다른 그룹으로 이전하거나 아카이브/복원한다.

## Core Principles

- **확인 필수**: 이전/아카이브는 되돌리기 어려우므로 반드시 확인
- **권한 검증**: 양쪽 그룹에 적절한 권한 필요
- **URL 변경 안내**: 이전 시 URL이 변경됨을 명확히 안내

---

## Action Detection

Parse from: $ARGUMENTS

**Supported actions**:
- `move` - 다른 그룹으로 프로젝트 이전
- `archive` - 프로젝트 아카이브 (읽기 전용)
- `unarchive` - 아카이브 해제
- `export` - 프로젝트 내보내기 (.tar.gz)
- `import` - 프로젝트 가져오기
- (empty) - 현재 프로젝트 상태 확인 후 작업 선택

---

## Workflow: Transfer Project (Move)

**Step 1: Current Project Info**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" | \
  jq '{id, name, path_with_namespace, namespace}'
```

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚚 프로젝트 이전
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
현재 위치: ai/research/my-project
프로젝트명: my-project
ID: 206
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Step 2: Select Destination Group**

Fetch groups with Maintainer+ access:

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/groups?min_access_level=40&per_page=100" | \
  jq -r '.[] | "\(.id)|\(.full_path)|\(.name)"'
```

Display numbered selection:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 이전할 그룹 선택
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #   Path                    Name
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1   ai/products             Products
 2   backend                 Backend Team
 3   backend/services        Backend Services
 4   archive                 Archive
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

대상 그룹: [번호]
```

**Step 3: Confirmation**

```
⚠️ 프로젝트 이전 확인
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
이전 전: ai/research/my-project
이전 후: ai/products/my-project

변경사항:
 • URL이 변경됩니다
 • 기존 URL은 리다이렉트됩니다
 • Git remote URL 업데이트 필요

정말 이전하시겠습니까? [yes/no]
```

**Step 4: Execute Transfer**

```bash
NAMESPACE_ID="<selected_group_id>"
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data "{\"namespace\": $NAMESPACE_ID}" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/transfer"
```

**Step 5: Post-Transfer**

```
✅ 프로젝트 이전 완료!

새 위치: ai/products/my-project
새 URL: https://gitlab.tepseg.com/ai/products/my-project

⚠️ 필수 작업:
git remote set-url origin git@gitlab.tepseg.com:ai/products/my-project.git

또는:
git remote set-url origin https://gitlab.tepseg.com/ai/products/my-project.git
```

---

## Workflow: Archive Project

**Step 1: Current Status**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" | \
  jq '{name, path_with_namespace, archived, last_activity_at}'
```

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 프로젝트 아카이브
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
프로젝트: ai/research/old-project
마지막 활동: 2024-01-15
현재 상태: 🟢 활성
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Step 2: Confirmation**

```
⚠️ 아카이브 확인
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
아카이브 후:
 • 프로젝트가 읽기 전용이 됩니다
 • 새로운 이슈, MR, 커밋 불가
 • 검색 및 조회는 가능
 • 언제든 아카이브 해제 가능

정말 아카이브하시겠습니까? [yes/no]
```

**Step 3: Execute Archive**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/archive"
```

**Step 4: Confirmation**

```
✅ 프로젝트 아카이브 완료!

프로젝트: ai/research/old-project
상태: 📦 아카이브됨 (읽기 전용)

복원 명령:
/gl-transfer unarchive
```

---

## Workflow: Unarchive Project

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/unarchive"
```

```
✅ 아카이브 해제 완료!

프로젝트: ai/research/old-project
상태: 🟢 활성

이제 이슈, MR, 커밋이 가능합니다.
```

---

## Workflow: Export Project

**Step 1: Start Export**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/export"
```

```
📤 프로젝트 내보내기 시작됨

프로젝트: ai/research/my-project

내보내기에는 시간이 걸릴 수 있습니다.
상태 확인: /gl-transfer export status
```

**Step 2: Check Export Status**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/export" | jq '.'
```

**Step 3: Download When Ready**

```bash
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --output "project-export.tar.gz" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/export/download"
```

```
✅ 내보내기 완료!

파일: project-export.tar.gz
크기: 45.2 MB

포함 내용:
 • Git 저장소 (전체 히스토리)
 • 이슈 및 MR
 • 위키
 • 스니펫
 • CI/CD 변수 (비밀번호 제외)
```

---

## Workflow: Import Project

**Step 1: Upload File**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📥 프로젝트 가져오기
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
내보내기 파일 경로: _______
새 프로젝트 이름: _______
대상 그룹: [번호 선택]
```

**Step 2: Import**

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --form "path=new-project-path" \
  --form "namespace=$NAMESPACE_ID" \
  --form "file=@project-export.tar.gz" \
  "$GITLAB_URL/api/v4/projects/import"
```

**Step 3: Check Import Status**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$NEW_PROJECT_ID/import" | jq '.'
```

---

## Error Handling

- **403 Forbidden**: 이전/아카이브 권한 없음 (Maintainer+ 필요)
- **400 Bad Request**: 대상 그룹에 동일 이름 존재
- **404 Not Found**: 프로젝트 또는 그룹 없음
- **Export in progress**: 이미 내보내기 진행 중

---

## Output Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 작업 결과
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
작업: 프로젝트 이전
프로젝트: my-project
이전 경로: ai/research/my-project
새 경로: ai/products/my-project
상태: ✅ 완료
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
