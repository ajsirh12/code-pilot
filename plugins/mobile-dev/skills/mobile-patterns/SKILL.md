---
name: Mobile Development Patterns
description: |
  모바일 앱 개발 패턴, Fastlane 설정, 스토어 배포에 대한 지식을 제공하는 스킬.
  사용자가 "모바일 앱", "iOS 빌드", "Android 빌드", "Fastlane",
  "TestFlight", "Play Store", "앱 서명", "인증서" 등을 언급할 때 이 스킬을 사용합니다.
version: 1.0.0
---

# 모바일 개발 패턴

## Fastlane 설정

### iOS 기본 설정
```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Push a new beta build to TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "App.xcodeproj")
    build_app(
      workspace: "App.xcworkspace",
      scheme: "App",
      export_method: "app-store"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Push a new release build to App Store"
  lane :release do
    build_app(
      workspace: "App.xcworkspace",
      scheme: "App"
    )
    upload_to_app_store(
      force: true,
      submit_for_review: true,
      automatic_release: true
    )
  end
end
```

### Android 기본 설정
```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Build and upload to Play Store internal track"
  lane :internal do
    gradle(
      task: "bundle",
      build_type: "Release"
    )
    upload_to_play_store(
      track: "internal",
      aab: "app/build/outputs/bundle/release/app-release.aab"
    )
  end

  desc "Promote internal to production"
  lane :promote do
    upload_to_play_store(
      track: "internal",
      track_promote_to: "production"
    )
  end
end
```

## 버전 관리

### iOS 버전 증가
```ruby
# 빌드 번호 자동 증가
increment_build_number

# 버전 번호 증가
increment_version_number(
  bump_type: "patch" # major, minor, patch
)

# 특정 값으로 설정
increment_build_number(
  build_number: ENV["CI_BUILD_NUMBER"]
)
```

### Android 버전 증가
```groovy
// android/app/build.gradle
def versionPropsFile = file('version.properties')
def versionProps = new Properties()
versionProps.load(new FileInputStream(versionPropsFile))

android {
    defaultConfig {
        versionCode versionProps['VERSION_CODE'].toInteger()
        versionName versionProps['VERSION_NAME']
    }
}
```

## 인증서 관리

### Fastlane Match (권장)
```bash
# 초기화
fastlane match init

# Git 저장소에 인증서 저장
fastlane match appstore
fastlane match development

# 새로 생성 (기존 폐기)
fastlane match nuke distribution
fastlane match appstore --force
```

```ruby
# Matchfile
git_url("git@github.com:org/certificates.git")
storage_mode("git")
type("appstore")
app_identifier(["com.company.app", "com.company.app.widget"])
```

### Android Keystore
```bash
# Keystore 생성
keytool -genkey -v \
  -keystore my-release-key.keystore \
  -alias my-key-alias \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# Keystore 정보 확인
keytool -list -v -keystore my-release-key.keystore
```

## CI/CD 통합

### GitHub Actions - iOS
```yaml
name: iOS Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true

      - name: Install dependencies
        run: |
          cd ios
          pod install

      - name: Build and upload
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: ${{ secrets.APP_SPECIFIC_PASSWORD }}
        run: |
          cd ios
          bundle exec fastlane beta
```

### GitHub Actions - Android
```yaml
name: Android Build

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Decode keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/release.keystore

      - name: Build and upload
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: |
          cd android
          bundle exec fastlane internal
```

## 스크린샷 자동화

### iOS (Snapshot)
```ruby
# Snapfile
devices([
  "iPhone 15 Pro Max",
  "iPhone 15",
  "iPad Pro (12.9-inch)"
])

languages(["ko", "en-US"])

scheme("AppUITests")
output_directory("./screenshots")
```

### Android (Screengrab)
```ruby
# Screengrabfile
locales(['ko-KR', 'en-US'])
app_package_name('com.company.app')
app_apk_path('app/build/outputs/apk/debug/app-debug.apk')
tests_apk_path('app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk')
```

## 일반적인 문제 해결

### iOS Code Signing
```bash
# 인증서 목록 확인
security find-identity -v -p codesigning

# 프로비저닝 프로파일 확인
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# Xcode 캐시 정리
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Android Gradle 문제
```bash
# Gradle 캐시 정리
cd android
./gradlew clean
./gradlew --stop

# 전체 캐시 삭제
rm -rf ~/.gradle/caches/
rm -rf android/.gradle/
```
