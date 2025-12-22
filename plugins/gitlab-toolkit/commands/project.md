---
description: Configure GitLab project security and settings with guided workflow
argument-hint: "protect [branch] | registry | badges | deploy-tokens"
allowed-tools: Bash(curl:*), AskUserQuestion, TodoWrite
---

# GitLab Project Configuration

You are helping a developer configure GitLab project settings. Follow a systematic approach: verify current state, explain options, apply changes, and validate.

## Core Principles

- **Show current state first**: Display existing configuration
- **Explain implications**: Tell user what each setting does
- **Confirm destructive changes**: Always ask before modifying protection rules
- **Validate after changes**: Verify settings were applied correctly

---

## Action Detection

Parse the user's request from: $ARGUMENTS

**Supported actions**:
- `protect [branch]` - Set up branch protection
- `protect` - Interactive branch protection setup
- `registry` - Enable/configure Container Registry
- `badges` - Add project badges
- `deploy-tokens` - Create deploy tokens
- (empty) - Show current settings and ask what to configure

---

## Workflow: Branch Protection

**Phase 1: Current State Analysis**

1. Get current protected branches:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/protected_branches" | \
     jq '.[] | {name, push_access_levels, merge_access_levels, allow_force_push}'
   ```

2. Get all branches:
   ```bash
   curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/repository/branches?per_page=20" | \
     jq '.[].name'
   ```

3. **Present current state**:
   ```
   Current Branch Protection:

   ✅ main
      - Push: No one (MR only)
      - Merge: Maintainers
      - Force push: Disabled

   ❌ develop (not protected)
   ❌ release/* (not protected)

   Recommendations:
   - protect 'develop' (allow Developers to push)
   - protect 'release/*' (Maintainers only)
   ```

**Phase 2: Protection Options**

1. **Present protection levels**:
   ```
   Branch protection levels:

   🔒 Strict (Recommended for main)
      - No direct push (MR only)
      - Maintainers merge
      - Force push disabled
      - CODEOWNERS required

   🔐 Standard (For develop)
      - Developers can push
      - Developers can merge
      - Force push disabled

   🔓 Light (For feature branches)
      - Everyone can push
      - Everyone can merge
      - Force push disabled

   Which level for [branch]?
   ```

2. **Wait for user choice**

**Phase 3: Apply Protection**

1. If branch already protected, **ask to update or skip**

2. Apply protection:
   ```bash
   # Strict (main)
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

3. **Verify and report**:
   ```
   ✅ Branch 'main' protected!

   Settings applied:
   - Direct push: Disabled (MR required)
   - Merge: Maintainers only
   - Force push: Disabled
   - CODEOWNERS: Required

   ⚠️  Important: Team members can no longer push directly to main.
       All changes must go through Merge Requests.
   ```

---

## Workflow: Container Registry

**Phase 1: Check Current State**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID" | \
  jq '{container_registry_enabled, container_registry_access_level}'
```

**Phase 2: Configure Registry**

1. **Present options**:
   ```
   Container Registry Options:

   1. Enable (project members only)
   2. Enable (public read access)
   3. Disable

   Current: Disabled

   Which option?
   ```

2. Apply setting:
   ```bash
   curl --request PUT \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --data "container_registry_enabled=true" \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID"
   ```

3. **Show registry info**:
   ```
   ✅ Container Registry enabled!

   Registry URL: gitlab.tepseg.com:5050/group/project

   Push image:
   docker login gitlab.tepseg.com:5050
   docker build -t gitlab.tepseg.com:5050/group/project:latest .
   docker push gitlab.tepseg.com:5050/group/project:latest

   Pull image:
   docker pull gitlab.tepseg.com:5050/group/project:latest
   ```

---

## Workflow: Project Badges

**Phase 1: Current Badges**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/badges" | jq '.'
```

**Phase 2: Add Badges**

1. **Present badge options**:
   ```
   Available badges:

   1. ✅ Pipeline Status - Shows if CI is passing
   2. 📊 Code Coverage - Shows test coverage %
   3. 📦 Latest Release - Shows version number
   4. 📄 License - Shows project license

   Which badges to add? (comma-separated or 'all')
   ```

2. Create selected badges:
   ```bash
   # Pipeline badge
   curl --request POST \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --header "Content-Type: application/json" \
     --data '{
       "name": "Pipeline",
       "link_url": "https://gitlab.tepseg.com/%{project_path}/-/pipelines",
       "image_url": "https://gitlab.tepseg.com/%{project_path}/badges/%{default_branch}/pipeline.svg"
     }' \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/badges"
   ```

3. **Show badge markdown**:
   ```
   ✅ Badges added!

   Add to README.md:
   ![Pipeline](https://gitlab.tepseg.com/group/project/badges/main/pipeline.svg)
   ![Coverage](https://gitlab.tepseg.com/group/project/badges/main/coverage.svg)
   ```

---

## Workflow: Deploy Tokens

**Phase 1: Current Tokens**

```bash
curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_tokens" | \
  jq '.[] | {name, username, expires_at, scopes}'
```

**Phase 2: Create Token**

1. **Ask for token details**:
   ```
   Create Deploy Token:

   Name: (e.g., "CI Deploy Token")
   Scopes:
   - read_repository
   - read_registry
   - write_registry
   - read_package_registry
   - write_package_registry

   Expiry: (YYYY-MM-DD or 'never')
   ```

2. Create token:
   ```bash
   curl --request POST \
     --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
     --header "Content-Type: application/json" \
     --data '{
       "name": "CI Deploy Token",
       "scopes": ["read_repository", "read_registry", "write_registry"],
       "expires_at": "2026-01-01"
     }' \
     "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/deploy_tokens"
   ```

3. **Show token (ONCE!)**:
   ```
   ✅ Deploy Token created!

   ⚠️  SAVE THIS NOW - Token will not be shown again!

   Name: CI Deploy Token
   Username: gitlab+deploy-token-123
   Token: gldt-xxxxxxxxxxxxxxxxxxxx
   Expires: 2026-01-01

   Usage in .gitlab-ci.yml:
   docker login -u $CI_DEPLOY_USER -p $CI_DEPLOY_PASSWORD $CI_REGISTRY
   ```

---

## Quick Status Command

If no arguments, show project status:

```
📊 Project Status: my-project

Security:
✅ main - protected (MR only)
❌ develop - not protected
❌ Force push - allowed on unprotected

Features:
✅ Container Registry - enabled
✅ Package Registry - enabled
❌ Wiki - disabled

Badges:
✅ Pipeline status
❌ Coverage (not configured)

Deploy Tokens: 2 active

Recommendations:
1. Protect 'develop' branch
2. Add coverage badge
3. Enable wiki for documentation

What would you like to configure?
```

---

## Error Handling

- **Branch already protected**: Offer to update settings
- **Token limit reached**: Show existing tokens, offer to revoke old ones
- **Permission denied**: Check if user is Maintainer+
