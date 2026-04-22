Listed directory android
Listed directory app
Viewed build.gradle.kts:1-74
Searched web: "Google Play Store target SDK requirements 2026"
Viewed local.properties:1-5
Viewed AndroidManifest.xml:1-52
Viewed animated_splash_screen.dart:1-311
Ran command: `ls android/key.properties`
Viewed main.dart:1-543
Viewed subscription_service.dart:1-82

Adema, this is a monumental step! Moving **DeXDo** into production and targeting a **Play Store release in 2026** requires a meticulous, investigative approach to ensure compliance with the latest Google Play policies (specifically regarding API targets, data safety, and the "premium" quality bar expected in 2026).

Based on my deep-dive investigation into the current codebase and 2026 market standards, here is the state of the project and the path forward:

### 🔍 Production Readiness Investigation

1.  **API Level Compliance (2026 Standard):** 
    *   As of early 2026, Google Play requires all new apps and updates to target **Android 15 (API 35)** or higher. 
    *   **Finding:** Your `build.gradle.kts` uses dynamic Flutter SDK versions. We must ensure these resolve to API 35+ during the build process to avoid rejection.
2.  **Signing Configuration:**
    *   **Finding:** The `android/app/build.gradle.kts` is set up to look for a `key.properties` file, but **it does not exist**. Without this and a valid Java Keystore (`.jks`), we cannot generate a signed Release App Bundle (`.aab`).
3.  **Monetization (RevenueCat):**
    *   **Finding:** Your `SubscriptionService` is using placeholders (`goog_placeholder_key`). For production, we need to integrate the real RevenueCat API keys and ensure the "premium" entitlement matches your dashboard.
4.  **App Experience (Splash & Icons):**
    *   **Finding:** You have a beautiful `AnimatedSplashScreen` in Dart, but for a 2026 premium feel, we need a **Native Splash Screen** (via `flutter_native_splash`) to cover the cold-boot gap before the Dart engine starts.
    *   **Finding:** `flutter_launcher_icons` is present, but we must verify the adaptive icon supports the latest Android "monochrome" icon standards for 2026.
5.  **Sensitive Permissions:**
    *   **Finding:** The manifest requests `SCHEDULE_EXACT_ALARM`. In 2026, Google Play requires a "Declaration Form" for this. If DeXDo is a To-Do/Calendar app, it's allowed, but we must justify it.

---

### 📋 Production Roadmap (2026 Edition)

I have prepared a comprehensive implementation plan to get us there.

> [!IMPORTANT]
> **Git Workflow**: Per your rules, I must first ask for permission to create a new branch. I propose **`release/v1.0.0-prep`**.

I will now create the detailed **Production Roadmap** artifact.

````markdown
# 🚀 DeXDo: Road to Play Store (2026)

This roadmap outlines the technical and procedural steps required to transition DeXDo from a development prototype to a production-grade application ready for the Google Play Store.

## 🛠 Phase 1: Infrastructure & Security
- [ ] **Branching**: Initialize `release/v1.0.0-prep`.
- [ ] **Signing**: Generate a Production Keystore and configure `key.properties`.
- [ ] **Secrets Management**: Move API keys (Gemini, RevenueCat) to a secure environment or obfuscated configuration.
- [ ] **Versioning**: Update `pubspec.yaml` to `1.0.1+2` for the first production-ready build.

## 🎨 Phase 2: Branding & UI Polish
- [ ] **Adaptive Icons**: Ensure `launcher_icon` supports 2026 monochrome and round standards.
- [ ] **Native Splash**: Configure `flutter_native_splash` to match the brand colors and transition seamlessly into the `AnimatedSplashScreen`.
- [ ] **Edge-to-Edge**: Verify full support for Android 15's default edge-to-edge display mode.

## ⚙️ Phase 3: Build Optimization
- [ ] **Proguard/R8**: Audit `proguard-rules.pro` to ensure Firebase and RevenueCat classes aren't stripped.
- [ ] **App Bundle**: Configure build scripts to generate `.aab` with multi-language support and dynamic feature splitting if necessary.
- [ ] **Performance Audit**: Run `flutter analyze` and `flutter build aab --obfuscate --split-debug-info` to minimize size.

## 📋 Phase 4: Play Store Compliance
- [ ] **Permission Justification**: Document the use of `SCHEDULE_EXACT_ALARM` for the Play Console declaration.
- [ ] **Data Safety**: Prepare the list of data collected (Crashlytics, Analytics, Email via Firebase Auth).
- [ ] **Privacy Policy**: Generate a modern privacy policy hosted on the DeXDo domain.
````

**Shall I proceed with creating the `release/v1.0.0-prep` branch and beginning Phase 1 (Keystore & Signing setup)?**

*Note: For the Keystore generation, I will provide the exact commands for you to run locally, as I should not handle the private key files directly for security reasons.*