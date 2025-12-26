---
name: setup-signing
description: 앱 서명 인증서 및 프로비저닝 설정
argument-hint: "[ios|android] [--type development|distribution]"
allowed-tools: ["Read", "Glob", "Write", "Bash"]
---

# 앱 서명 설정 명령어

iOS와 Android 앱 서명에 필요한 인증서와 키를 설정한다.

## 실행 단계

### iOS 서명

1. **인증서 관리 (Fastlane Match)**
   ```bash
   # 초기 설정
   fastlane match init

   # 개발 인증서
   fastlane match development

   # 배포 인증서
   fastlane match appstore
   ```

   **Matchfile:**
   ```ruby
   git_url("https://github.com/org/certificates")
   storage_mode("git")
   type("appstore")
   app_identifier(["com.company.app"])
   username("your@email.com")
   ```

2. **수동 설정**
   ```bash
   # 인증서 생성
   # Keychain Access > Certificate Assistant > Request a Certificate

   # Apple Developer에서 다운로드
   # Certificates, Identifiers & Profiles

   # Xcode 설정
   # Signing & Capabilities > Team 선택
   ```

3. **CI/CD 환경**
   ```yaml
   # GitHub Actions
   - name: Install certificates
     env:
       P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
       KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
     run: |
       security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
       security import certificate.p12 -k build.keychain -P "$P12_PASSWORD"
   ```

### Android 서명

1. **Keystore 생성**
   ```bash
   keytool -genkey -v \
     -keystore release.keystore \
     -alias app \
     -keyalg RSA \
     -keysize 2048 \
     -validity 10000
   ```

2. **Gradle 설정**
   ```groovy
   // android/app/build.gradle
   android {
       signingConfigs {
           release {
               storeFile file('release.keystore')
               storePassword System.getenv("KEYSTORE_PASSWORD")
               keyAlias 'app'
               keyPassword System.getenv("KEY_PASSWORD")
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

3. **Play App Signing**
   ```bash
   # Google Play Console에서 앱 서명 키 관리
   # 업로드 키와 앱 서명 키 분리
   ```

### 보안 권장사항

- Keystore/인증서는 Git에 커밋하지 않음
- 환경 변수 또는 시크릿 매니저 사용
- CI/CD에서 임시 키체인 사용
- 정기적인 인증서 갱신 알림 설정
