# dependency-check

프로젝트 의존성 분석, 취약점 확인, 업데이트 권장 플러그인.

## 기능

- **취약점 스캔**: npm audit, pip-audit 등 활용
- **업데이트 확인**: 최신 버전 대비 현재 버전 분석
- **위험도 평가**: Critical/High/Moderate/Low 분류
- **수정 가이드**: 실행 가능한 명령어 제공

## 지원 패키지 매니저

| 언어 | 매니저 |
|------|--------|
| Node.js | npm, yarn, pnpm |
| Python | pip, poetry, pipenv |
| Rust | cargo |
| Go | go mod |
| Ruby | bundler |
| PHP | composer |

## 사용법

### 명령어

```bash
/check-deps           # 전체 분석 (취약점 + 업데이트)
/check-deps audit     # 취약점만 확인
/check-deps outdated  # 업데이트 가능한 것만
```

### 에이전트

`dependency-analyzer` - 심층 분석이 필요할 때:
- 의존성 트리 분석
- 위험도 점수 산정
- 업그레이드 영향도 평가

## 출력 예시

```
⚠️ 취약점 발견: 3개

Critical:
- lodash@4.17.15: Prototype Pollution → 4.17.21로 업데이트

📦 업데이트 가능: 5개

Major (Breaking Changes 주의):
- react: 17.0.2 → 18.2.0

💡 수정 명령어:
npm audit fix
npm update
```

## 관련 플러그인

| 플러그인 | 역할 |
|---------|------|
| dependency-check | 의존성 분석/취약점 |
| security-guidance | 코드 패턴 보안 |
| code-quality | 코드 리뷰 |
