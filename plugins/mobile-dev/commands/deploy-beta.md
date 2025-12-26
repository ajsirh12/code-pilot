---
name: deploy-beta
description: 베타 버전 배포 (TestFlight, Firebase App Distribution, Play Internal)
argument-hint: "[ios|android|both] [--groups testers]"
allowed-tools: ["Read", "Glob", "Grep", "Write", "Bash"]
---

# 베타 배포 명령어

TestFlight, Firebase App Distribution, Play Store 내부 테스트로 베타 버전을 배포한다.

## 실행 단계

### iOS - TestFlight

1. **Fastlane 배포**
   ```bash
   fastlane pilot upload
   ```

   **Fastfile:**
   ```ruby
   lane :beta do
     build_app(scheme: "App")
     upload_to_testflight(
       skip_waiting_for_build_processing: true,
       groups: ["Internal Testers", "External Testers"]
     )
   end
   ```

2. **테스터 관리**
   ```bash
   # 테스터 추가
   fastlane pilot add email@test.com -g "External Testers"

   # 테스터 목록
   fastlane pilot list
   ```

### Android - Play Store Internal

1. **Fastlane 배포**
   ```bash
   fastlane supply --track internal
   ```

   **Fastfile:**
   ```ruby
   lane :beta do
     gradle(task: "bundleRelease")
     upload_to_play_store(
       track: "internal",
       release_status: "draft"
     )
   end
   ```

### Firebase App Distribution

1. **설정**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **iOS 배포**
   ```bash
   firebase appdistribution:distribute app.ipa \
     --app 1:123456789:ios:abcdef \
     --groups "testers"
   ```

3. **Android 배포**
   ```bash
   firebase appdistribution:distribute app.apk \
     --app 1:123456789:android:abcdef \
     --groups "testers"
   ```

   **Fastfile 통합:**
   ```ruby
   lane :firebase_beta do
     build_app
     firebase_app_distribution(
       app: "1:123456789:ios:abcdef",
       groups: "testers",
       release_notes: "Bug fixes and improvements"
     )
   end
   ```

### 릴리스 노트

```ruby
lane :beta do
   # Git 커밋 기반 릴리스 노트
   changelog = changelog_from_git_commits(
     commits_count: 10,
     merge_commit_filtering: "exclude_merges"
   )

   upload_to_testflight(
     changelog: changelog
   )
 end
```

### 출력

- 배포 URL
- 설치 QR 코드
- 테스터 알림 상태
- 빌드 처리 상태
