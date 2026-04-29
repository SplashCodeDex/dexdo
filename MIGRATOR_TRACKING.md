# DexDo: Next-Gen Migration Tracker 🚀

As requested, here is the structured execution plan. I am currently running **Phase 1** live in the background.

## Phase 1: Architecture & State Management Consolidation (EXECUTED ✅)
- [x] Migrate state management from `provider` to `flutter_riverpod`.
- [x] Consolidate `TaskProvider` into `taskProvider` (Notifier).
- [x] Refactor `AuthService` and `SubscriptionService` to Riverpod.
- [x] Standardize directory structure (`features/`, `core/`, `shared/`).

## Phase 2: Data Layer & Persistence (EXECUTED ✅)
- [x] Implement Repository Pattern with `HybridTaskRepository`.
- [x] Integrate **Isar** for robust local storage.
- [x] Setup `LocalStorageService` (SharedPreferences) for legacy migration.

## Phase 3: Security & Stability (IN PROGRESS 🏗️)
- [x] Implement `flutter_secure_storage` for session data.
- [x] Setup Firebase Crashlytics for error logging.
- [ ] Audit Firestore security rules.

## Phase 4: UI/UX Polishing (EXECUTED ✅)
- [x] Standardize design tokens in `AppTheme`.
- [x] Implement high-quality micro-interactions with `flutter_animate`.
- [x] Revamp `CalendarPane` with vertical timeline.

## Phase 5: Testing & Quality Assurance (TODO ⏳)
- [ ] Implement full widget test suite for feature modularity.
- [ ] Verify Riverpod provider overrides in test mocks.
- [ ] Clean up all stale imports and unused dependencies.

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
