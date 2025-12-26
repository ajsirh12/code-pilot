---
name: build-app
description: iOS/Android 앱 빌드 자동화 설정 및 실행
argument-hint: "[ios|android|both] [--release]"
allowed-tools: ["Read", "Glob", "Grep", "Write", "Bash"]
---

# 앱 빌드 명령어

iOS 및 Android 앱 빌드를 자동화한다.

## 실행 단계

1. **프로젝트 분석**
   - 프레임워크 감지 (React Native, Flutter, Native)
   - 기존 빌드 설정 확인
   - Fastlane 설정 여부

2. **React Native 빌드**

   **iOS:**
   ```bash
   # 개발 빌드
   cd ios && pod install
   npx react-native run-ios

   # 릴리스 빌드
   cd ios
   xcodebuild -workspace App.xcworkspace \
     -scheme App \
     -configuration Release \
     -archivePath build/App.xcarchive \
     archive

   xcodebuild -exportArchive \
     -archivePath build/App.xcarchive \
     -exportPath build \
     -exportOptionsPlist ExportOptions.plist
   ```

   **Android:**
   ```bash
   # 개발 빌드
   npx react-native run-android

   # 릴리스 APK
   cd android
   ./gradlew assembleRelease

   # 릴리스 AAB (Play Store용)
   ./gradlew bundleRelease
   ```

3. **Flutter 빌드**

   **iOS:**
   ```bash
   flutter build ios --release
   flutter build ipa
   ```

   **Android:**
   ```bash
   flutter build apk --release
   flutter build appbundle
   ```

4. **Fastlane 설정**
   ```ruby
   # ios/fastlane/Fastfile
   default_platform(:ios)

   platform :ios do
     lane :beta do
       build_app(scheme: "App")
       upload_to_testflight
     end

     lane :release do
       build_app(scheme: "App")
       upload_to_app_store
     end
   end
   ```

   ```ruby
   # android/fastlane/Fastfile
   default_platform(:android)

   platform :android do
     lane :beta do
       gradle(task: "bundleRelease")
       upload_to_play_store(track: "internal")
     end
   end
   ```

5. **CI/CD 통합**
   - GitHub Actions 워크플로우
   - Bitrise 설정
   - App Center 연동

6. **출력**
   - 빌드 결과물 경로
   - 빌드 로그 요약
   - 다음 단계 안내
