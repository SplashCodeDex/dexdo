# Stack Architecture (Mid-2026)

This project has been forcibly upgraded to the absolute bleeding edge of the Android ecosystem to ensure future-proofing.

## Core Framework
- **Flutter**: `3.44.2` (Stable)
- **Dart**: `3.x` Ecosystem

## Android Build Environment
- **Gradle**: `9.5.1` (Strict mode)
- **Android Gradle Plugin (AGP)**: `8.1.0`+ (Or native Gradle 9)
- **Kotlin Compiler**: `2.3.20`+ (Android Built-In Kotlin ecosystem)

## Critical Modifications & Hacks
With Flutter 3.44+ and Gradle 9, Android strictly enforces the use of **Built-in Kotlin**, deprecating the old `kotlin-android` Gradle plugin.

1. `id("kotlin-android")` and `kotlinOptions` blocks were removed from `android/app/build.gradle.kts`.
2. All experimental API usages (e.g., Android Jetpack Credential Manager) now require strict `@kotlin.OptIn` compilation directives, as the Kotlin 2 compiler evaluates warnings as hard errors.
3. Removed deprecated Flutter `CupertinoPageTransitionsBuilder` from `app_theme.dart` in favor of standard Material 3 page transitions.
