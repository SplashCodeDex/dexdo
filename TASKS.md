# DexDo Solidification Tasks

## P0: Architecture & Structure
- [x] **T-ARCH-01:** Create modular directory structure (`core`/, `shared/`, `features/`).
- [x] **T-ARCH-02:** Move `auth_service.dart` to `features/auth/`.
- [x] **T-ARCH-03:** Move task-related logic to `features/tasks/`.
- [x] **T-ARCH-04:** Setup `core/` for logging, network, and basic DI.

## P1: State Management Refactor
- [x] **T-STATE-01:** Add `flutter_riverpod` and `riverpod_generator`.
- [x] **T-STATE-02:** Migrate `AuthService` (Provider) to `AuthNotifier` (Riverpod).
- [x] **T-STATE-03:** Migrate `TaskProvider` (Provider) to `TaskListNotifier` (Riverpod).
- [x] **T-STATE-04:** Remove `provider` package from dependencies.

## P2: Data Layer & Persistence
- [x] **T-DATA-01:** Integrate **Isar** for robust local storage.
- [x] **T-DATA-02:** Implement Repository Pattern to abstract between Isar and Firestore.
- [x] **T-DATA-03:** Setup Background Sync service for Firestore updates.

## P3: Security & Stability
- [ ] **T-SEC-01:** Audit all Firestore rules.
- [x] **T-SEC-02:** Implement `flutter_secure_storage` for session data.
- [x] **T-STAB-01:** Setup Sentry or move to advanced Crashlytics logging.
- [ ] **T-STAB-02:** Implement localized error messages for all UI actions.

## P4: UI/UX Polishing
- [ ] **T-UI-01:** Setup **Widgetbook** for component development.
- [x] **T-UI-02:** Standardize design tokens (colors, spacing, typography) in `ThemeProvider`.
- [x] **T-UI-03:** Add high-quality 2026 micro-interactions using `flutter_animate`.
