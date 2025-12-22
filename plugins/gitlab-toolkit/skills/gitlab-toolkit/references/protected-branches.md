# Protected Branches 설정

## main 브랜치 직접 푸시 금지 (권장)

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "main",
    "push_access_level": 0,
    "merge_access_level": 40,
    "allow_force_push": false,
    "code_owner_approval_required": true
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_branches"
```

### 설정 설명

| 옵션 | 값 | 설명 |
|------|-----|------|
| `push_access_level` | 0 | 아무도 직접 푸시 불가 |
| `merge_access_level` | 40 | Maintainer만 MR 머지 가능 |
| `allow_force_push` | false | Force push 금지 |
| `code_owner_approval_required` | true | CODEOWNERS 승인 필요 |

---

## develop 브랜치 (Developer 이상)

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "develop",
    "push_access_level": 30,
    "merge_access_level": 30,
    "allow_force_push": false
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_branches"
```

---

## release/* 브랜치 (Maintainer)

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "release/*",
    "push_access_level": 40,
    "merge_access_level": 40,
    "allow_force_push": false
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_branches"
```

---

## Protected Tags

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "v*",
    "create_access_level": 40
  }' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_tags"
```

---

## Access Levels

| Level | 이름 | Push | Merge |
|-------|------|------|-------|
| 0 | No access | 불가 | 불가 |
| 30 | Developer | 가능 | 가능 |
| 40 | Maintainer | 가능 | 가능 |
| 60 | Admin | 가능 | 가능 |
