# DexDo: Next-Gen Migration Tracker 🚀

As requested, here is the structured execution plan. I am currently running **Phase 1** live in the background.

## Phase 1: Architecture & State Management Consolidation (EXECUTING ⏳)
- [ ] Create `lib/services/storage_service.dart` (Abstracts Data Handling)
- [ ] Create `lib/services/local_storage_service.dart` (Implements `SharedPreferences` securely)
- [ ] Refactor `TaskProvider` to utilize structured Service injected classes.
- [ ] Prepare dependencies in `pubspec.yaml`.

## Phase 2: Local Notifications & Reminders (PENDING NATIVE CONFIG)
- [ ] Create `lib/services/notification_service.dart` using `flutter_local_notifications`
- [ ] Integrate Task Due Dates to trigger OS-level alarms.
- [ ] **USER ACTION BLOCKER**: You will need to request iOS/Android notification permissions in `AppDelegate.swift` and `AndroidManifest.xml` via your IDE.

## Phase 3: Firebase Auth & Cloud Sync (PENDING NATIVE CONFIG)
- [ ] Create `lib/services/firebase_storage_service.dart` (Firestore alternative handler)
- [ ] Implement Firebase Auth for Multi-device sync.
- [ ] **USER ACTION BLOCKER**: You will need to generate a Firebase Project online, run `flutterfire configure`, and bind the `google-services.json` manually in Android Studio.
