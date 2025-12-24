---
description: Analyze project dependencies, check vulnerabilities, and recommend updates
argument-hint: "[audit|outdated|all]"
allowed-tools: ["Read", "Bash", "Glob", "TodoWrite"]
---

# Check Dependencies

프로젝트 의존성을 분석하고 취약점/업데이트를 확인한다.

## Action Detection

Parse from: $ARGUMENTS

| 인자 | 동작 |
|------|------|
| `audit` | 취약점만 확인 |
| `outdated` | 업데이트 가능한 패키지만 |
| `all` 또는 빈값 | 전체 분석 |

---

## Workflow

### 1. Detect Package Manager

프로젝트 루트에서 패키지 매니저 감지:

```
package.json      → npm/yarn/pnpm (Node.js)
package-lock.json → npm
yarn.lock         → yarn
pnpm-lock.yaml    → pnpm
pyproject.toml    → pip/poetry (Python)
requirements.txt  → pip
Pipfile           → pipenv
Cargo.toml        → cargo (Rust)
go.mod            → go (Go)
composer.json     → composer (PHP)
Gemfile           → bundler (Ruby)
```

### 2. Run Dependency Analysis

#### Node.js (npm/yarn/pnpm)

```bash
# 취약점 확인
npm audit --json 2>/dev/null || npm audit 2>/dev/null

# 업데이트 가능 확인
npm outdated --json 2>/dev/null || npm outdated 2>/dev/null

# yarn인 경우
yarn audit --json 2>/dev/null
yarn outdated 2>/dev/null
```

#### Python (pip/poetry)

```bash
# pip-audit 사용 (설치 필요)
pip-audit 2>/dev/null || echo "pip-audit not installed"

# 업데이트 확인
pip list --outdated --format=json 2>/dev/null

# poetry인 경우
poetry show --outdated 2>/dev/null
```

#### Rust (cargo)

```bash
cargo audit 2>/dev/null || echo "cargo-audit not installed"
cargo outdated 2>/dev/null || echo "cargo-outdated not installed"
```

#### Go

```bash
go list -m -u all 2>/dev/null
```

### 3. Parse and Summarize Results

결과를 파싱하여 다음 형식으로 정리:

```markdown
## Dependency Analysis Report

### Summary
- Total packages: [N]
- Vulnerabilities: [N] (critical: X, high: Y, moderate: Z, low: W)
- Outdated: [N]

### Vulnerabilities (Critical/High)
| Package | Severity | Description | Fix |
|---------|----------|-------------|-----|
| lodash  | High     | Prototype Pollution | Upgrade to 4.17.21 |

### Outdated Packages
| Package | Current | Latest | Type |
|---------|---------|--------|------|
| react   | 17.0.2  | 18.2.0 | major |
| axios   | 0.21.0  | 1.6.0  | major |

### Recommendations
1. **Critical**: Fix [N] critical vulnerabilities immediately
2. **Major Updates**: Review breaking changes before updating
3. **Run**: `npm audit fix` or `npm update`
```

### 4. Provide Actionable Commands

상황에 맞는 수정 명령어 제안:

```bash
# 자동 수정 가능한 취약점
npm audit fix

# 강제 수정 (breaking changes 포함)
npm audit fix --force

# 특정 패키지 업데이트
npm update lodash

# 메이저 버전 업데이트 (수동)
npm install react@18
```

---

## Output Format

### 취약점 발견 시

```
⚠️ 취약점 발견: [N]개

Critical (즉시 수정 필요):
- [package]: [설명] → [해결책]

High:
- [package]: [설명] → [해결책]

💡 수정 명령어:
npm audit fix
```

### 업데이트 가능 시

```
📦 업데이트 가능: [N]개

Major (Breaking Changes 주의):
- [package]: [current] → [latest]

Minor/Patch (안전):
- [package]: [current] → [latest]

💡 업데이트 명령어:
npm update
```

### 문제 없을 시

```
✅ 의존성 상태 양호

- 취약점: 0개
- 모든 패키지 최신 상태
```

---

## Examples

```bash
/check-deps           # 전체 분석
/check-deps audit     # 취약점만 확인
/check-deps outdated  # 업데이트 가능한 것만
```
