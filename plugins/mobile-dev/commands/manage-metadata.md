---
name: manage-metadata
description: App Store/Play Store 메타데이터 관리
argument-hint: "[init|sync|update] [--locale ko,en,ja]"
allowed-tools: ["Read", "Glob", "Grep", "Write", "Bash"]
---

# 스토어 메타데이터 관리 명령어

App Store와 Play Store의 앱 메타데이터를 관리한다.

## 실행 단계

1. **메타데이터 구조 초기화** (`init`)
   ```
   fastlane/metadata/
   ├── android/
   │   ├── ko-KR/
   │   │   ├── title.txt
   │   │   ├── short_description.txt
   │   │   ├── full_description.txt
   │   │   └── changelogs/
   │   │       └── default.txt
   │   └── en-US/
   │       └── ...
   └── ios/
       ├── ko/
       │   ├── name.txt
       │   ├── subtitle.txt
       │   ├── description.txt
       │   ├── keywords.txt
       │   ├── promotional_text.txt
       │   └── release_notes.txt
       └── en-US/
           └── ...
   ```

2. **메타데이터 동기화** (`sync`)
   ```bash
   # App Store에서 다운로드
   fastlane deliver download_metadata

   # Play Store에서 다운로드
   fastlane supply init
   ```

3. **스크린샷 관리**
   ```
   fastlane/screenshots/
   ├── android/
   │   ├── phoneScreenshots/
   │   ├── sevenInchScreenshots/
   │   └── tenInchScreenshots/
   └── ios/
       ├── iPhone 6.5" Display/
       ├── iPhone 5.5" Display/
       └── iPad Pro 12.9"/
   ```

   ```bash
   # 자동 스크린샷 생성
   fastlane snapshot
   fastlane screengrab
   ```

4. **메타데이터 업데이트** (`update`)
   ```bash
   # App Store 업로드
   fastlane deliver --skip_binary_upload

   # Play Store 업로드
   fastlane supply --skip_upload_apk
   ```

5. **다국어 지원**
   - 지원 로케일 목록 관리
   - 번역 템플릿 생성
   - 번역 상태 체크

6. **출력**
   - 메타데이터 파일 목록
   - 누락된 필드 알림
   - 스토어 가이드라인 체크
