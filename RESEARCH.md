Based on my research into latest 2026 Flutter best practices and a deep dive into the current DeXDo codebase, I have identified the key areas we must address to solidify this application.
The goal here is to move DeXDo from a "standard prototype" to a "high-performance, production-grade" codebase that is easy to maintain, scale, and test.
📊 Research Summary: 2026 Flutter Best Practices
Architecture (Feature-First Clean Architecture): Moving away from "Layer-based" folders (e.g., all models in one folder) to "Feature-based" folders (e.g., features/tasks/domain, features/tasks/data). This prevents the "God Folder" problem.
State Management (Reactivity 3.0): Transitioning to Riverpod 3.0+ with Code Generation or Signals. These provide fine-grained reactivity and better compile-time safety than legacy Provider.
Data Integrity (Immutable Models): Using Freezed and JsonSerializable for all models to ensure state cannot be accidentally mutated, which is the #1 cause of UI bugs.
Error Handling (Functional Approach): Using the Result pattern (similar to Rust/Swift) to handle errors as data rather than throwing exceptions that crash the app.
Storage Engine: Moving to Drift (Type-safe SQL) or Isar for high-performance local caching, especially for offline-first apps.
Performance (Impeller & WASM): Ensuring the app is optimized for Flutter's Impeller engine (no shader jank) and ready for WASM deployment for Web.
Testing (Automation): Implementing Patrol for native integration testing (interacting with system dialogs) and Alchemist/Golden Toolkit for pixel-perfect UI verification.
Code Maintenance (Strict Linting): Strengthening analysis_options.yaml to enforce strict type safety and architectural boundaries.
AI Integration: Utilizing Embeddings for semantic task search and organization rather than just simple text matching.
Deployment (Hot-Fix Ready): Setting up Shorebird for code-push capabilities, allowing us to fix critical bugs without waiting for App Store/Play Store review.
🛠️ Proposed Solidification Roadmap
Next steps to harden the DeXDo codebase:
1. Architectural Reorganization (The "Clean" Shift)
Current structure is "Flat". We will adopt a Feature-Driven structure:
lib/core/ (Services, theme, utils)
lib/features/tasks/ (Dashboard, editor, models, logic)
lib/features/calendar/
lib/features/auth/
2. Modernize State & Service Layer
Migrate to Riverpod: Introduce ref.watch and generated providers. This will decouple logic from the UI tree, making it testable in isolation.
Service Decoupling: Ensure FirebaseTaskRepository and LocalStorageService are truly independent and swappable (Dependency Injection).
3. Model Hardening
Implement freezed for the Task model. This allows for easy copies (task.copyWith(...)) and prevents state corruption.
4. Linting & Code Quality
Upgrade analysis_options.yaml to include custom 2026 rules (enforcing const, final, and avoiding BuildContext issues).
5. Entry Point Refactor
main.dart is currently 600+ lines. We need to split this into:
app.dart (Router & Theme configuration)
bootstrap.dart (Firebase and Service initialization)
Feature-specific widgets moved to their respective folders.