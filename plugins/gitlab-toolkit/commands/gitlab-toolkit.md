---
description: Guided GitLab project setup and management workflow
argument-hint: "Optional: project setup, protect branches, ci/cd setup"
allowed-tools: Bash(curl:*), Bash(git:*), Read, Write, AskUserQuestion, Task, TodoWrite
---

# GitLab Toolkit - Intelligent Workflow

You are helping a developer set up and manage their GitLab project. Follow a systematic approach: verify environment, understand project needs, configure settings, and validate results.

## Core Principles

- **Verify before acting**: Always check environment variables and current state first
- **Ask clarifying questions**: Identify project type, team size, and workflow preferences
- **Explain decisions**: Tell user why each setting is recommended
- **Validate results**: Confirm each step succeeded before moving on
- **Use TodoWrite**: Track all progress throughout

---

## Phase 1: Environment Verification

**Goal**: Ensure GitLab connection is properly configured

**Actions**:
1. Create todo list with all phases
2. Check environment variables:
   ```bash
   echo "GITLAB_URL: ${GITLAB_URL:-NOT SET}"
   echo "GITLAB_TOKEN: ${GITLAB_TOKEN:+SET (hidden)}"
   echo "GITLAB_PROJECT_ID: ${GITLAB_PROJECT_ID:-NOT SET}"
   ```
3. If any variable is missing, **STOP and ask user to set them**:
   ```
   Missing environment variables. Please set:
   export GITLAB_URL="https://gitlab.tepseg.com"
   export GITLAB_TOKEN="glpat-xxxxxxxxxxxx"
   export GITLAB_PROJECT_ID="your-project-id"
   ```
4. Test API connection:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/user" | jq '{username, name}'
   ```
5. Get project info and confirm with user

**환경변수 누락 시 분기 처리**:

| 누락된 변수 | 액션 |
|------------|------|
| GITLAB_URL / GITLAB_TOKEN | 사용자에게 설정 요청 후 대기 |
| GITLAB_PROJECT_ID만 누락 | **반드시 아래 질문 수행** |

**GITLAB_PROJECT_ID가 없을 때 반드시 물어볼 것**:
```
GitLab 프로젝트 ID가 설정되지 않았습니다.

옵션:
1. 🆕 새 프로젝트 생성 (그룹/서브그룹 선택 포함)
2. 🔗 기존 프로젝트 연결
3. ❌ 취소

선택: [번호]
```

- **옵션 1 선택 시**: 즉시 `/gl-bootstrap` 워크플로우로 전환. 절대로 개인 네임스페이스에 직접 생성하지 말 것!
- **옵션 2 선택 시**: 프로젝트 검색 후 GITLAB_PROJECT_ID 설정
- **옵션 3 선택 시**: 종료

**CRITICAL**: 새 프로젝트 생성이 필요한 경우, 이 명령어에서 직접 프로젝트를 생성하지 말고 반드시 `/gl-bootstrap` 워크플로우의 Phase 2를 따라야 합니다. 이는 그룹 선택, 서브그룹 선택, 멤버 초대 단계를 포함합니다.

**DO NOT PROCEED if environment is not configured.**

---

## Phase 2: Project Discovery

**Goal**: Understand what kind of project this is and what needs to be configured

Initial request: $ARGUMENTS

**Actions**:
1. Get current project state:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" | jq '{
       name, visibility, default_branch,
       container_registry_enabled, packages_enabled,
       merge_method, only_allow_merge_if_pipeline_succeeds
     }'
   ```
2. Check existing configuration:
   - Protected branches
   - Labels
   - Milestones
   - CI/CD variables
3. **Ask user about their needs**:
   - Project type? (Web app, API, Library, Microservice)
   - Team size? (Solo, Small team, Large team)
   - Branching strategy? (Git Flow, GitHub Flow, Trunk-based)
   - CI/CD requirements? (Build, Test, Deploy)
4. Summarize findings and confirm understanding

---

## Phase 3: Security Configuration

**Goal**: Set up branch protection and security settings

**CRITICAL**: This is essential for production projects. DO NOT SKIP.

**Actions**:
1. **Present protection options to user**:
   ```
   I recommend the following branch protection:

   main branch:
   - Direct push: DISABLED (MR only)
   - Force push: DISABLED
   - Merge: Maintainers only
   - Pipeline must succeed: YES

   develop branch (if using Git Flow):
   - Direct push: Developers+
   - Force push: DISABLED

   Do you want to apply these settings?
   ```

2. **Wait for user approval before applying**

3. Apply protected branches:
   ```bash
   curl --request POST \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --header "Content-Type: application/json" \
     --data '{
       "name": "main",
       "push_access_level": 0,
       "merge_access_level": 40,
       "allow_force_push": false
     }' \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_branches"
   ```

4. Verify settings were applied:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_branches" | jq '.'
   ```

5. Report results to user

---

## Phase 4: Labels & Organization

**Goal**: Set up label system for issue tracking

**Actions**:
1. **Present label scheme options**:
   ```
   I recommend a scoped label system:

   Type labels:
   - bug (red), feature (green), enhancement (blue), docs (yellow)

   Priority labels (scoped):
   - priority::critical, priority::high, priority::medium, priority::low

   Status labels (scoped):
   - status::todo, status::in-progress, status::review, status::done

   Do you want me to create these labels?
   ```

2. **Wait for user approval**

3. Create labels based on user choice

4. Optionally set up Issue Board with status columns

5. Report what was created

---

## Phase 5: CI/CD Configuration

**Goal**: Set up CI/CD variables and pipelines

**Actions**:
1. Check if .gitlab-ci.yml exists
2. **Ask about CI/CD needs**:
   - What environments? (dev, staging, production)
   - What secrets need to be stored?
   - Container registry needed?
   - Package registry needed?

3. **Present variable recommendations**:
   ```
   For your setup, I recommend these CI/CD variables:

   Protected & Masked:
   - DATABASE_URL (production)
   - API_KEY (production)

   Protected only:
   - DEPLOY_TOKEN

   Should I help you set these up?
   ```

4. **Wait for user to provide values**

5. Create variables with proper protection

6. Enable registries if needed

---

## Phase 6: Webhooks & Integrations

**Goal**: Set up external integrations

**Actions**:
1. **Ask about integrations**:
   - Slack notifications?
   - Discord notifications?
   - External CI triggers?

2. If user wants notifications:
   - Get webhook URL
   - Configure events (push, MR, pipeline)
   - Test webhook

3. Report integration status

---

## Phase 7: Validation & Summary

**Goal**: Verify all settings and document what was done

**Actions**:
1. Run validation checks:
   - Protected branches configured?
   - Labels created?
   - CI/CD variables set?
   - Webhooks working?

2. Mark all todos complete

3. **Present summary**:
   ```
   ✅ GitLab Project Setup Complete

   Security:
   - main branch protected (no direct push)
   - Force push disabled
   - MR required for all changes

   Organization:
   - 12 labels created (type, priority, status)
   - Issue board configured

   CI/CD:
   - 3 protected variables set
   - Container registry enabled

   Integrations:
   - Slack webhook configured

   Next steps:
   - Add team members with appropriate roles
   - Create first milestone
   - Set up pipeline schedules
   ```

4. **Ask if user wants to continue with additional setup**

---

## Error Handling

If any API call fails:
1. Check HTTP status code
2. Display error message to user
3. Suggest fixes:
   - 401: Token invalid or expired
   - 403: Insufficient permissions
   - 404: Project not found
   - 409: Resource already exists (often OK)
4. Ask user how to proceed

---

## Notes

- Always use `https://gitlab.tepseg.com` as GITLAB_URL
- Never store tokens in code or logs
- Prefer masked variables for secrets
- Always verify before and after changes
