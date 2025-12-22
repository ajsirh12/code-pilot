# GitLab API 호출 패턴

## 기본 형식

```bash
# GET (조회)
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues"

# POST (생성)
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{"title": "New Issue"}' \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues"

# PUT (수정)
curl --request PUT \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --data "state_event=close" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/:iid"

# DELETE (삭제)
curl --request DELETE \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues/:iid"
```

---

## Pagination

```bash
# 기본 페이지네이션
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues?per_page=100&page=1"

# 응답 헤더
# x-page: 현재 페이지
# x-per-page: 페이지당 항목 수
# x-total: 전체 항목 수
# x-total-pages: 전체 페이지 수

# 전체 목록 가져오기
page=1
while true; do
  result=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$GITLAB_PROJECT_ID/issues?per_page=100&page=$page")

  [ "$(echo "$result" | jq 'length')" -eq 0 ] && break
  echo "$result"
  ((page++))
done
```

---

## jq 유틸리티

```bash
# ID만 추출
curl ... | jq '.[].id'

# 특정 필드만
curl ... | jq '.[] | {id, title, state}'

# 필터링
curl ... | jq '.[] | select(.state == "opened")'

# 카운트
curl ... | jq 'length'

# 첫 번째 항목
curl ... | jq '.[0]'

# 정렬
curl ... | jq 'sort_by(.created_at) | reverse'
```

---

## Rate Limiting

```bash
# 응답 헤더 확인
# RateLimit-Limit: 분당 요청 제한
# RateLimit-Remaining: 남은 요청 수
# RateLimit-Reset: 리셋 시간

# Rate Limit 대응
if [ "$http_code" -eq 429 ]; then
  echo "Rate limited. Waiting 60 seconds..."
  sleep 60
  # 재시도
fi
```
