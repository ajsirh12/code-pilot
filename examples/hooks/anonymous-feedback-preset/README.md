# Anonymous Feedback Preset Hooks

익명 피드백/직원 참여 플랫폼 개발을 위한 Claude Code 훅 프리셋입니다.

## 포함된 훅

| 훅 | 타입 | 트리거 | 설명 |
|---|------|--------|------|
| `anonymity-guard.py` | PreToolUse | Write/Edit | 익명성 침해 코드 패턴 감지 |
| `security-check.py` | PreToolUse | Bash | 위험한 명령어 차단 |
| `pii-scanner.py` | PostToolUse | Write/Edit | 개인정보(PII) 스캔 |
| `checklist-reminder.py` | Stop | 작업 완료 | 익명성/보안 체크리스트 알림 |

## 설치 방법

### 1. 프로젝트에 훅 복사

```bash
# 새 프로젝트 디렉토리에서
mkdir -p .claude/hooks

# 훅 파일 복사
cp -r /path/to/code-pilot/examples/hooks/anonymous-feedback-preset/hooks/* .claude/hooks/
```

### 2. settings.json 설정

프로젝트의 `.claude/settings.json` 파일을 생성하고 다음 내용 추가:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/anonymity-guard.py"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/security-check.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/pii-scanner.py"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/checklist-reminder.py"
          }
        ]
      }
    ]
  }
}
```

## 훅 상세 설명

### anonymity-guard.py (익명성 가드)

코드 작성 전 익명성을 침해할 수 있는 패턴을 감지합니다.

**감지 패턴:**
- `user.email`, `user.name` - 직접적인 사용자 정보 접근
- `req.ip`, `client.ip` - IP 주소 로깅
- `console.log.*user` - 사용자 정보 콘솔 출력
- `tracking`, `analytics.*user` - 사용자 추적

**권장 대안:**
- `anonymousId` 사용
- `hashedUserId` 사용
- `crypto.randomUUID()` 사용

### security-check.py (보안 검사)

위험한 bash 명령어를 차단합니다.

**차단 명령어:**
- `rm -rf /` - 루트 삭제
- `curl | sh` - 원격 스크립트 실행
- `chmod -R 777` - 과도한 권한 부여

**경고 명령어:**
- `echo $TOKEN` - 토큰 노출
- `cat .env` - 환경변수 파일 노출

### pii-scanner.py (PII 스캐너)

작성된 코드에서 개인정보를 스캔합니다.

**감지 항목:**
- 이메일 주소
- 전화번호 (한국/미국 형식)
- 주민등록번호 패턴
- 신용카드 번호 패턴
- 하드코딩된 비밀번호/API 키

### checklist-reminder.py (체크리스트 알림)

작업 완료 시 익명성/보안 체크리스트를 표시합니다.

## 커스터마이징

각 훅 파일의 상단에 있는 패턴 목록을 수정하여 프로젝트에 맞게 커스터마이징할 수 있습니다.

```python
# anonymity-guard.py 예시
DANGEROUS_PATTERNS = [
    (r'user\.email', 'Direct email access'),
    # 여기에 프로젝트 특화 패턴 추가
    (r'employee\.department', 'Department info could identify user'),
]
```

## 요구 사항

- Python 3.7+
- Claude Code

## 라이선스

MIT License - 자유롭게 수정 및 사용 가능
