# DexDo

A visually stunning and highly robust To-Do List application built with Flutter & Firebase.

## Production Release Optimizations

DexDo has been optimized and prepared for releases with Android / iOS. The following best practices have been applied:

- **Enhanced Code Linting**: Strict lint rules have been enforced via `analysis_options.yaml` to ensure code stability and consistent quality before deploying.
- **R8 Minification (Android)**: ProGuard and R8 rules have been set up in `android/app/build.gradle.kts`. Running `flutter build apk` or `flutter build appbundle` will now automatically shrink unused resources and obfuscate code.
- **Firebase Performance Rules**: `proguard-rules.pro` has been configured to preserve Firebase dependencies during aggressive obfuscation.
- **App Icons**: App Icons are structured to be auto-built and mapped correctly for all device pixels. For any UI changes, use `dart run flutter_launcher_icons`.

## Getting Started For Development

To start contributing:
```bash
flutter pub get
# Generate boilerplate (Isar, Riverpod, etc.)
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Creating a Release Build

### Android
To create a standard `.aab` for the Play Store that benefits from dynamic delivery:
```bash
flutter build appbundle --release
```

### iOS
To create a release build for the Apple App Store, open the iOS folder in Xcode:
```bash
flutter build ipa
```

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/).
