# Figma MCP Server

Figma MCP 서버를 통해 Figma 디자인 파일에서 AI 에이전트가 코드를 생성할 수 있습니다.

> **Rate Limits**
> - Starter/View/Collab 플랜: 월 6회 tool call 제한
> - Dev/Full 시트 (Professional 이상): Tier 1 REST API와 동일한 분당 제한

## 설치

플러그인 설치 시 MCP 서버가 자동 설정됩니다.

```bash
/plugin install figma
```

| 서버 | URL | 설명 |
|------|-----|------|
| `figma` | `https://mcp.figma.com/mcp` | Remote 서버 (별도 설정 없음) |
| `figma-desktop` | `http://127.0.0.1:3845/mcp` | Desktop 서버 (Figma 앱 필요) |

### Desktop 서버 활성화

1. [Figma 데스크톱 앱](https://www.figma.com/downloads/)을 최신 버전으로 업데이트
2. Figma Design 파일 열기
3. Dev Mode 전환 (`Shift+D`)
4. Inspect 패널에서 **Enable desktop MCP server** 클릭

## 사용법

### 링크 기반
```
"이 Figma 디자인 구현해줘: https://figma.com/design/.../...?node-id=42-15"
```

### 선택 기반 (Desktop 전용)
Figma 앱에서 프레임/레이어를 선택한 후:
```
"현재 선택한 디자인 구현해줘"
```

## Skills

| Skill | 설명 |
|-------|------|
| `/implement-design` | Figma 디자인을 pixel-perfect 코드로 변환 |
| `/create-design-system-rules` | 프로젝트별 디자인 시스템 규칙 생성 |
| `/code-connect-components` | Figma 컴포넌트와 코드 컴포넌트 연결 |

---

## MCP 도구 및 사용법

### `get_design_context`

**지원 파일:** Figma Design, Figma Make

Figma 선택 영역의 디자인 컨텍스트를 가져옵니다. 기본 출력은 **React + Tailwind**이며, 프롬프트로 커스터마이즈 가능합니다.

**프레임워크 변경:**
```
"Vue로 생성해줘"
"HTML + CSS로 생성해줘"
"iOS SwiftUI로 생성해줘"
```

**컴포넌트 활용:**
```
"src/components/ui 컴포넌트를 사용해서 생성해줘"
"Chakra UI로 이 레이아웃 만들어줘"
```

> 선택 기반 프롬프트는 Desktop MCP 서버에서만 동작합니다. Remote 서버는 링크가 필요합니다.

---

### `get_variable_defs`

**지원 파일:** Figma Design

선택 영역에서 사용된 변수와 스타일(색상, 간격, 타이포그래피)을 반환합니다.

**예시:**
```
"이 Figma 선택 영역에서 사용된 변수 가져와줘"
"어떤 색상과 간격 변수가 사용됐어?"
"변수 이름과 값을 리스트로 보여줘"
```

---

### `get_code_connect_map`

**지원 파일:** Figma Design

Figma 노드 ID와 코드베이스의 컴포넌트 간 매핑을 가져옵니다.

반환 값:
- `codeConnectSrc`: 코드베이스 내 컴포넌트 위치 (파일 경로 또는 URL)
- `codeConnectName`: 코드베이스 내 컴포넌트 이름

디자인-코드 워크플로우에서 올바른 컴포넌트를 사용하도록 보장합니다.

---

### `get_screenshot`

**지원 파일:** Figma Design, FigJam

선택 영역의 스크린샷을 캡처합니다. 레이아웃 정확도 검증에 사용됩니다.

---

### `create_design_system_rules`

**지원 파일:** 파일 컨텍스트 불필요

에이전트가 고품질 프론트엔드 코드를 생성하는 데 필요한 규칙 파일을 생성합니다. 디자인 시스템 및 기술 스택에 맞춘 출력을 보장합니다.

생성 후 `rules/` 또는 `CLAUDE.md`에 저장하여 코드 생성 시 자동 적용되도록 합니다.

---

### `get_metadata`

**지원 파일:** Figma Design

선택 영역의 XML 표현을 반환합니다 (레이어 ID, 이름, 타입, 위치, 크기).

**사용 케이스:**
- 대규모 디자인에서 `get_design_context` 출력이 너무 큰 경우
- 여러 선택 영역 또는 전체 페이지 처리

---

### `get_figjam`

**지원 파일:** FigJam

FigJam 다이어그램의 메타데이터를 XML 형식으로 반환합니다. `get_metadata`와 유사하지만 노드 스크린샷도 포함됩니다.

---

### `whoami` (Remote 전용)

**지원 파일:** 파일 컨텍스트 불필요

인증된 Figma 사용자 정보를 반환합니다:
- 이메일 주소
- 소속 플랜
- 시트 타입

---

## Desktop 서버 설정

Figma 환경설정에서 추가 옵션을 설정할 수 있습니다.

**이미지 설정:**
- **Use local image server**: 로컬 서버에서 이미지 호스팅 (`http://localhost:3845/assets/...`)
- **Download**: 이미지를 디스크에 직접 저장

**Enable Code Connect:**
Code Connect 매핑을 응답에 포함하여 연결된 코드베이스의 컴포넌트를 재사용합니다.

---

## 참고 자료

- [Figma MCP Server 공식 문서](https://developers.figma.com/docs/figma-mcp-server/)
- [Code Connect 설정 가이드](https://help.figma.com/hc/en-us/articles/23920389749655-Code-Connect)
- [Figma 변수 및 디자인 토큰](https://help.figma.com/hc/en-us/articles/15339657135383-Guide-to-variables-in-Figma)
