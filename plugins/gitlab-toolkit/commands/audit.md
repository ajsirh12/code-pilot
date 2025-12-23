---
description: Audit project/group access, permissions, and security settings
argument-hint: "access|permissions|tokens|activity|security"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Access Audit

프로젝트/그룹의 접근 권한, 보안 설정, 활동 기록을 감사한다.

## Core Principles

- **전체 가시성**: 누가 어떤 권한으로 접근 가능한지 명확히
- **보안 경고**: 잠재적 보안 문제 식별 및 경고
- **이력 추적**: 권한 변경 이력 확인
- **리포트 생성**: 감사 결과를 문서화

---

## Action Detection

Parse from: $ARGUMENTS

**Supported audits**:
- `access` - 프로젝트/그룹 접근 권한 전체 조회
- `permissions` - 권한 수준별 분류
- `tokens` - 활성 토큰 (Deploy, Project Access)
- `activity` - 최근 권한 변경 활동
- `security` - 보안 설정 점검
- (empty) - 종합 감사 리포트

---

## Workflow: Comprehensive Audit

**Step 1: Gather All Data**

```bash
# Project info
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" | \
  jq '{name, visibility, archived}'

# Project members
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/all?per_page=100"

# Deploy tokens
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_tokens"

# Project access tokens
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens"

# Protected branches
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_branches"
```

**Step 2: Generate Comprehensive Report**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 GitLab 접근 권한 감사 리포트
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
프로젝트: ai/research/my-project
생성일: 2024-12-23
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 요약
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
총 접근 가능 인원:     15명
  👑 Owner:            2명
  🔧 Maintainer:       3명
  💻 Developer:        8명
  📖 Reporter:         1명
  👁️ Guest:            1명

활성 토큰:             3개
  Deploy Token:        2개
  Project Token:       1개

보호된 브랜치:         2개
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Workflow: Access Audit

**Step 1: Fetch All Members (including inherited)**

```bash
# Direct members
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members?per_page=100"

# All members (including inherited from group)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/members/all?per_page=100"
```

**Step 2: Display Access Report**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👥 접근 권한 상세
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👑 Owner (50) - 전체 관리 권한
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 User            Source          Expires
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 @admin          Direct          -
 @cto            Group: ai       -

🔧 Maintainer (40) - 설정 변경, 머지
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 @kim.lead       Direct          -
 @park.senior    Group: ai       -
 @tech.lead      Group: ai/res   -

💻 Developer (30) - 푸시, MR 생성
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 @dev1           Direct          -
 @dev2           Direct          2024-06-01 ⚠️ 곧 만료
 @dev3           Group: ai       -
 ...

📖 Reporter (20) - 코드 조회, 이슈 생성
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 @reporter1      Direct          -

👁️ Guest (10) - 이슈 조회만
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 @intern         Direct          2024-03-01 ⚠️ 곧 만료
```

---

## Workflow: Token Audit

**Step 1: Fetch All Tokens**

```bash
# Deploy tokens
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_tokens" | \
  jq '.[] | {id, name, username, scopes, expires_at, revoked}'

# Project access tokens
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/access_tokens" | \
  jq '.[] | {id, name, scopes, expires_at, active, revoked}'
```

**Step 2: Display Token Report**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔑 활성 토큰
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Deploy Tokens
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #  Name              Username                Scopes              Expires
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1  CI Deploy         gitlab+deploy-token-1   read_registry       2025-01-01
 2  CD Deploy         gitlab+deploy-token-2   write_registry      2025-06-01

🎫 Project Access Tokens
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 #  Name              Scopes                  Access Level   Expires
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1  API Token         api, read_repo          Developer      2024-12-31 ⚠️

⚠️ 경고:
 • 1개 토큰이 30일 내 만료 예정
 • 'API Token'의 'api' 스코프는 넓은 권한 - 필요 여부 확인 권장
```

---

## Workflow: Security Audit

**Step 1: Check Security Settings**

```bash
# Project settings
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" | \
  jq '{
    visibility,
    public_jobs,
    only_allow_merge_if_pipeline_succeeds,
    only_allow_merge_if_all_discussions_are_resolved,
    container_registry_access_level,
    security_and_compliance_access_level
  }'

# Protected branches
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_branches"
```

**Step 2: Security Report**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔒 보안 설정 점검
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

기본 설정
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 설정                              상태        권장
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 가시성                            🔒 private  ✅
 파이프라인 성공 필수              ✅ 활성     ✅
 모든 토론 해결 필수               ❌ 비활성   ⚠️ 권장
 Public Jobs                       ❌ 비활성   ✅

브랜치 보호
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 브랜치        Push            Merge           Force Push
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 main          ❌ 불가         Maintainers     ❌ 불가    ✅
 develop       Developers      Developers      ❌ 불가    ✅
 release/*     ❌ 미보호       ❌ 미보호       ❌ 미보호  ⚠️

⚠️ 보안 권장사항:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1. [중요] release/* 브랜치 보호 설정 필요
 2. [권장] 모든 토론 해결 필수 활성화
 3. [참고] 1개 토큰 만료 임박 - 갱신 필요
```

---

## Workflow: Activity Audit

**Step 1: Fetch Recent Events**

```bash
# Project events (permission changes)
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/events?action=updated&per_page=50" | \
  jq '.[] | select(.target_type == "User" or .action_name == "updated")'
```

**Step 2: Display Activity**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📜 최근 권한 변경 활동
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

2024-12-20
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 시간      작업자         대상            변경
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 14:30     @admin         @new.dev        ➕ Developer 추가
 11:15     @admin         @old.member     ➖ 제거됨
 09:00     @kim.lead      main 브랜치     🔒 보호 설정 변경

2024-12-19
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 16:45     @admin         Deploy Token    🔑 새 토큰 생성
 10:30     @park.senior   @intern         📝 Guest → Reporter

더 보기: /gl-activity --since 2024-12-01
```

---

## Export Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📤 리포트 내보내기
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

형식 선택:
 1. 📄 Markdown (.md)
 2. 📊 JSON (.json)
 3. 📋 CSV (.csv)

선택: [번호]
파일명: [기본: audit-report-2024-12-23]
```

---

## Error Handling

- **403 Forbidden**: 감사 권한 없음 (Maintainer+ 필요)
- **Empty Results**: 데이터 없음 → 필터 조정 안내
- **Rate Limit**: API 제한 → 재시도 안내

---

## Recommendations Engine

감사 결과 기반 자동 권장사항:

**높은 우선순위**:
- 보호되지 않은 main/master 브랜치
- 만료된 토큰
- 과도한 Owner 권한

**중간 우선순위**:
- 30일 내 만료 예정 토큰
- 'api' 스코프 토큰
- 보호되지 않은 release 브랜치

**낮은 우선순위**:
- 비활성 멤버
- 미사용 Deploy Token
