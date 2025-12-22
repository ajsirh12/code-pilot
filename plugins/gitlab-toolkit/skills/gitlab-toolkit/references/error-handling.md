# GitLab API 에러 처리

## HTTP 상태 코드

| 코드 | 의미 | 대응 |
|------|------|------|
| 200 | 성공 | - |
| 201 | 생성 성공 | - |
| 204 | 삭제 성공 | - |
| 400 | 잘못된 요청 | 파라미터 확인 |
| 401 | 인증 실패 | 토큰 확인 |
| 403 | 권한 없음 | 권한/스코프 확인 |
| 404 | 리소스 없음 | ID/경로 확인 |
| 409 | 충돌 | 중복 여부 확인 |
| 422 | 유효성 실패 | 필수 필드 확인 |
| 429 | Rate Limit | 잠시 대기 후 재시도 |
| 500 | 서버 오류 | GitLab 상태 확인 |

---

## 에러 응답 처리

```bash
response=$(curl -s -w "\n%{http_code}" --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues")

http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -ne 200 ]; then
  echo "Error: $http_code"
  echo "$body" | jq '.message'
  exit 1
fi
```

---

## 일반적인 에러와 해결책

### 401 Unauthorized

```bash
# 토큰 유효성 확인
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/user"
```

### 403 Forbidden

- 토큰 스코프 확인 (api 스코프 필요)
- 프로젝트 멤버십 확인
- Protected Branch 권한 확인

### 404 Not Found

- Project ID 확인
- 리소스 존재 여부 확인
- URL 인코딩 확인 (브랜치명에 `/` 포함 시)

### 422 Unprocessable Entity

- 필수 필드 누락
- 잘못된 값 형식
- 유효성 검사 실패
