# Codebase Investigation & Context Log

## Current State Analysis (2026-04-29)

### 1. State Management
- **Current:** Using `provider` package.
- **Files:** `lib/providers/task_provider.dart`, `lib/providers/theme_provider.dart`.
- **Finding:** Simple `ChangeNotifier` approach. Scaling issues might arise with complex dependencies.

### 2. Data Persistence
- **Current:** Firestore + `shared_preferences`.
- **Files:** `lib/repositories/firebase_task_repository.dart`, `lib/services/local_storage_service.dart`.
- **Finding:** `localStorageService` uses `shared_preferences` for JSON-serialized tasks. This is NOT recommended for 2026 scale. Need to move to `Isar`.

### 3. Architecture
- **Current:** Folder-by-Layer (mostly).
- **Finding:** Widgets are in a flat `widgets/` folder. Logic is scattered. Needs the Feature-First modularization planned in `TASKS.md`.

### 4. AI Integration
- **Current:** Using `google_generative_ai`.
- **Files:** `lib/services/ai_service.dart`.
- **Finding:** Basic integration. We can enhance this with "Agentic" capabilities (tasks creating other sub-tasks).

### 5. Desktop/Web Readiness
- **Current:** `main.dart` has a `NavigationRail` for large screens.
- **Finding:** Good start on responsive design. Needs better keyboard shortcut support (some exist in `main.dart`).

---

## Conflict Avoidance Notes
- **Deduplication:** Ensure `AuthService` and `AuthNotifier` don't coexist in the final build.
- **Migration Path:** Keep `provider` until `Riverpod` is 100% verified to avoid a broken app state.
