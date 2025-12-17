# Hook Presets

프로젝트 유형별 Claude Code 훅 프리셋 모음입니다.

## 사용 가능한 프리셋

| 프리셋 | 용도 | 설명 |
|-------|------|------|
| [anonymous-feedback-preset](./anonymous-feedback-preset/) | 익명 피드백 플랫폼 | 익명성 보호, PII 스캔, 보안 검사 |

## 훅이란?

Claude Code 훅은 특정 이벤트 발생 시 자동으로 실행되는 스크립트입니다.

### 훅 타입

| 타입 | 실행 시점 | 용도 |
|-----|----------|------|
| `PreToolUse` | 도구 사용 전 | 검증, 차단 |
| `PostToolUse` | 도구 사용 후 | 스캔, 포맷팅 |
| `Stop` | 작업 완료 시 | 체크리스트, 알림 |
| `SessionStart` | 세션 시작 시 | 컨텍스트 주입 |

### 훅 설정 위치

```
프로젝트/
└── .claude/
    ├── settings.json    # 훅 설정
    └── hooks/           # 훅 스크립트
```

## 새 프리셋 만들기

1. `examples/hooks/` 아래에 새 디렉토리 생성
2. `settings.json` 작성 (훅 설정)
3. `hooks/` 디렉토리에 스크립트 작성
4. `README.md` 작성 (사용법)

## 기여

새로운 훅 프리셋을 만들어 PR로 제출해주세요!
