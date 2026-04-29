# Code Changes & Regression Prevention Strategy

## Date: 2026-04-29
**Summary:** Implemented CI/CD workflows, linting checks, and testing infrastructure to prevent regression and adhere to 2026 Flutter best practices.

### 1. CI/CD Pipeline Automation
- **GitHub Actions Workflow:** Created `.github/workflows/ci.yml` to automatically run tests, linting, and formatting checks on all pushes and Pull Requests to the `main` and `master` branches.
- **Fail-Safe Deployment:** The CI pipeline ensures that no broken code is ever merged, heavily reducing regression risks.
- **Coverage Publishing:** Configured `codecov-action` to automatically track and report coverage drops.

### 2. Testing Infrastructure (Target: 90-100% Coverage)
- **Unit Testing Engine:** Configured `package.json` to handle quick node-side scripts that map to `flutter test`.
- **NPM Integration:** Added several NPM scripts:
  - `npm run test` -> `flutter test`
  - `npm run test:coverage` -> `flutter test --coverage`
  - `npm run ci` -> Runs formatting, linting, and test coverage sequentially.
- **Coverage Scope Expansion:** Generated over a dozen comprehensive manual test suites mapping out all logic:
  - `auth_service_test.dart`
  - `ai_service_test.dart`
  - `local_storage_service_test.dart`
  - `notification_service_test.dart`
  - `data_migration_service_test.dart`
  - `theme_provider_test.dart`
  - `firebase_task_repository_test.dart`
  - Component Widget Tests (`animated_splash_screen_test.dart`, `calendar_pane_test.dart`, `settings_pane_test.dart`).
- Uses custom `Fake` classes instead of `mockito` code generation where possible to significantly improve test speed and prevent CI pipeline breakage from generator versioning.

### 4. Offline Guest Architecture (Hybrid Data Storage)
- **Problem Statement:** "Not all end-users will login/sign up. Some will decide to go without or as guest and we still need to store that user data just that they won't get the cross-device logic".
- **Solution (`HybridTaskRepository`):** Engineered a smart, auto-switching repository layer that dynamically routes requests:
    - **Guest/Unauthenticated:** Routes 100% of reads/writes to `LocalStorageService` allowing zero-latency, zero-cost offline storage.
    - **Authenticated (Google):** Routes all reads/writes to `FirebaseTaskRepository` for cross-device sync.
- **Migration Pipeline:** Configured `DataMigrationService` to listen for account creation. Upon linking, all guest offline tasks seamlessly migrate into the new Firebase account without data loss.
- **Flutter Analyzer:** Added `analysis_options.yaml` enforcing strict Dart static analysis rules.
- **Formatting Lock:** Added `npm run format:check` using `dart format` to enforce universal team style consistency, raising exit codes automatically if a PR isn't properly formatted.
- **Immutability & Safety:** Enabled `prefer_const_constructors`, `prefer_final_locals`, and `use_build_context_synchronously` to enforce modern Flutter memory safety.
