# skill-creator

Claude의 기능을 확장하는 스킬(Skill) 생성 가이드. 전문 지식, 워크플로우, 도구 통합을 제공하는 모듈형 패키지를 만들 수 있습니다.

## 스킬이란?

스킬은 Claude를 특정 도메인/작업에 특화된 에이전트로 변환하는 "온보딩 가이드"입니다:

- **전문 워크플로우** - 특정 도메인의 다단계 절차
- **도구 통합** - 특정 파일 형식이나 API 작업 지침
- **도메인 전문성** - 회사별 지식, 스키마, 비즈니스 로직
- **번들 리소스** - 스크립트, 참조 문서, 에셋

## 스킬 구조

```
skill-name/
├── SKILL.md              # 필수: YAML frontmatter + 마크다운 지침
└── Bundled Resources     # 선택
    ├── scripts/          # 실행 코드 (Python/Bash 등)
    ├── references/       # 필요시 로드되는 문서
    └── assets/           # 출력에 사용되는 파일 (템플릿, 이미지 등)
```

## 스크립트

| 스크립트 | 설명 |
|---------|------|
| `init_skill.py` | 새 스킬 템플릿 생성 |
| `quick_validate.py` | 스킬 구조 검증 |
| `package_skill.py` | .skill 배포 파일 생성 |

### 사용법

```bash
# 새 스킬 초기화
python scripts/init_skill.py my-skill --path ./skills

# 스킬 검증
python scripts/quick_validate.py ./skills/my-skill

# 스킬 패키징
python scripts/package_skill.py ./skills/my-skill
```

## 스킬 생성 6단계

1. **이해** - 구체적인 사용 예시로 스킬 파악
2. **계획** - 재사용 가능한 리소스 식별 (scripts, references, assets)
3. **초기화** - `init_skill.py` 실행
4. **편집** - 리소스 구현 및 SKILL.md 작성
5. **패키징** - `package_skill.py`로 배포 파일 생성
6. **반복** - 실제 사용 기반 개선

## 핵심 원칙

- **간결함이 핵심** - 컨텍스트 윈도우는 공유 자원. Claude가 이미 아는 건 추가하지 말 것
- **적절한 자유도** - 작업의 취약성에 따라 지침의 구체성 조절
- **점진적 공개** - 메타데이터 → SKILL.md → 번들 리소스 순으로 로드

## 참조 문서

- `references/workflows.md` - 순차적/조건부 워크플로우 패턴
- `references/output-patterns.md` - 템플릿 및 예시 패턴

---

*Derived from [Anthropic Skills](https://github.com/anthropics/skills) - Apache 2.0 License*
