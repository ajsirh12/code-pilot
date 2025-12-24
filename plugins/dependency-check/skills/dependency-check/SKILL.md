---
name: dependency-check
description: This skill should be used when the user asks about "dependency vulnerabilities", "package updates", "npm audit", "outdated packages", "security vulnerabilities in dependencies", "update dependencies", or mentions checking/analyzing project dependencies. Also triggered by Korean phrases like "의존성 취약점", "패키지 업데이트", "라이브러리 보안", "npm audit", "pip audit".
---

# Dependency Management Guide

프로젝트 의존성 분석, 취약점 확인, 업데이트 관리 가이드.

## Package Managers

### Node.js

| 매니저 | Lock 파일 | 취약점 확인 | 업데이트 확인 |
|--------|-----------|-------------|---------------|
| npm | package-lock.json | `npm audit` | `npm outdated` |
| yarn | yarn.lock | `yarn audit` | `yarn outdated` |
| pnpm | pnpm-lock.yaml | `pnpm audit` | `pnpm outdated` |

### Python

| 매니저 | 설정 파일 | 취약점 확인 | 업데이트 확인 |
|--------|-----------|-------------|---------------|
| pip | requirements.txt | `pip-audit` | `pip list --outdated` |
| poetry | pyproject.toml | `poetry audit` | `poetry show --outdated` |
| pipenv | Pipfile | `pipenv check` | `pipenv update --dry-run` |

### Other Languages

| 언어 | 매니저 | 취약점 확인 | 업데이트 확인 |
|------|--------|-------------|---------------|
| Rust | cargo | `cargo audit` | `cargo outdated` |
| Go | go mod | `govulncheck` | `go list -m -u all` |
| Ruby | bundler | `bundle audit` | `bundle outdated` |
| PHP | composer | `composer audit` | `composer outdated` |

---

## Vulnerability Severity

| Level | 설명 | 조치 |
|-------|------|------|
| **Critical** | 원격 코드 실행, 인증 우회 | 즉시 수정 |
| **High** | 데이터 노출, 권한 상승 | 빠른 수정 |
| **Moderate** | 제한된 영향 | 계획된 수정 |
| **Low** | 최소 영향 | 다음 업데이트 시 |

---

## Update Strategies

### Semantic Versioning

```
MAJOR.MINOR.PATCH (예: 2.1.3)

MAJOR: 하위 호환 안 됨 (Breaking Changes)
MINOR: 하위 호환, 새 기능
PATCH: 버그 수정
```

### 안전한 업데이트

```bash
# Patch만 업데이트 (가장 안전)
npm update

# Minor까지 업데이트
npx npm-check-updates -u --target minor
npm install

# Major 업데이트 (주의 필요)
npx npm-check-updates -u
npm install
```

### Breaking Changes 확인

Major 업데이트 전:
1. CHANGELOG.md 확인
2. Migration Guide 확인
3. 테스트 환경에서 먼저 적용
4. 테스트 실행

---

## Common Vulnerabilities

### Prototype Pollution
- 영향: lodash, jQuery 등
- 해결: 최신 버전 업데이트

### ReDoS (Regular Expression DoS)
- 영향: 정규식 사용 라이브러리
- 해결: 패치 버전 적용

### Path Traversal
- 영향: 파일 처리 라이브러리
- 해결: 입력 검증 + 업데이트

---

## Best Practices

### 정기 점검
```bash
# 주간 자동화 권장
npm audit
npm outdated
```

### Lock 파일 관리
- Lock 파일 **반드시 커밋**
- CI에서 `npm ci` 사용 (npm install 대신)

### 의존성 최소화
- 사용하지 않는 패키지 제거
- 대안 검토 (번들 크기, 유지보수 상태)

### 자동화
```yaml
# GitHub Actions 예시
- name: Security Audit
  run: npm audit --audit-level=high
```

---

## Quick Reference

```bash
# 전체 분석
/check-deps

# 취약점만
/check-deps audit

# 업데이트만
/check-deps outdated
```

### 수동 명령어

```bash
# npm
npm audit fix              # 자동 수정
npm audit fix --force      # 강제 수정 (breaking 포함)
npm update [package]       # 특정 패키지 업데이트

# yarn
yarn upgrade-interactive   # 대화형 업데이트

# pip
pip install --upgrade [package]
pip-audit --fix           # 자동 수정
```
