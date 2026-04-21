# DexDo: Next-Gen Migration Tracker 🚀

As requested, here is the structured execution plan. I am currently running **Phase 1** live in the background.

## Phase 1: Architecture & State Management Consolidation (EXECUTING ⏳)
- [ ] Create `lib/services/storage_service.dart` (Abstracts Data Handling)
- [ ] Create `lib/services/local_storage_service.dart` (Implements `SharedPreferences` securely)
- [ ] Refactor `TaskProvider` to utilize structured Service injected classes.
- [ ] Prepare dependencies in `pubspec.yaml`.

## Phase 2: Local Notifications & Reminders (EXECUTED ✅)
- [x] Create `lib/services/notification_service.dart` using `flutter_local_notifications`
- [x] Integrate Task Due Dates to trigger OS-level alarms.
- [ ] **USER ACTION BLOCKER**: You will need to request iOS/Android notification permissions in `AppDelegate.swift` and `AndroidManifest.xml` via your IDE.

## Phase 3: Firebase Auth & Cloud Sync (EXECUTED ✅)
- [x] Create `lib/services/firebase_storage_service.dart` (Firestore alternative handler)
- [x] Implement `lib/services/auth_service.dart` for Multi-device sync tracking.
- [x] **USER ACTION**: Bound `google-services.json` and `firebase_options.dart`.

## Phase 4: Data Migration & Identity (EXECUTED ✅)
- [x] Migrate existing standard native `SharedPreferences` tasks -> `Firebase`.
- [x] Implement Sign-In/Auth state UI (Google/Apple login UI to bind accounts natively).
- [x] Implement Offline Persistence (Trivial with Firebase rules).

## Phase 6: Core Infrastructure & Identity (EXECUTED ✅)
- [x] Configure explicit OS notification perms in AndroidManifest.xml and Info.plist.
- [x] Link Google Sign-In identity to fuse Anonymous UID and preserve user data.
- [x] Enable Firestore Offline Persistence queue handling.

## Phase 7: Recurring Habits (EXECUTED ✅)
- [x] Extend `Task` model to support string recurrence types (Daily, Weekly, Monthly, Yearly).
- [x] Inject Recurrence Dropdown picker directly into `TaskEditorPane` metadata block.
- [x] Upgrade `TaskProvider`'s `toggleTask` logic to conditionally spawn a cloned advanced iteration if finished.

## Phase 8: Chrono-Timeline UX (EXECUTED ✅)
- [x] Revamp `CalendarPane` to sort daily hits by precise chronological due time.
- [x] Render a connected native vertical timeline tree visualizer instead of basic Cards list.
