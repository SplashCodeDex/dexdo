# DexDo 2026 Coding Standards & Best Practices

## 1. Architecture: Modular Clean Architecture
Every feature must follow the standard structure:
```text
lib/
  core/           # Cross-cutting concerns (Network, DI, Logger)
  shared/         # Reusable widgets, themes, utils
  features/
    [feature_name]/
      presentation/
        providers/
        widgets/
        screens/
      domain/
        entities/
        repositories/
      data/
        models/
        data_sources/
```

## 2. State Management: Riverpod
- Use **Riverpod Generators** (`@riverpod`) exclusively.
- Avoid global mutable state.
- Keep UI "dumb" — use `ConsumerWidget` and `ref.watch`.

## 3. UI & Design
- **Material 3:** Always use `useMaterial3: true`.
- **Responsive:** Use `LayoutBuilder` or the `ResponsiveValue` pattern for Desktop/Tablet/Mobile.
- **Animations:** Use `motion` principles. Prefer `animations` package for implicit transitions.

## 4. Database & Persistence
- **Local-First:** Apps must function 100% offline.
- **Sync:** Firestore is a "remote mirror" of the local Isar database.
- **Data Safety:** Sensitive tokens stored in `flutter_secure_storage`.

## 5. Security
- **Firebase Rules:** Enforce strict identity-based access.
- **Input Sanitization:** Validate all user inputs using a standard validation layer.
- **Local Auth:** Biometric lock options for the app.

## 6. Testing
- **Unit Tests:** 80% coverage on Domain logic.
- **Widget Tests:** Test critical UI components in isolation.
- **Integration (Patrol):** End-to-end flows involving native interactions (e.g., notifications).

## 7. Performance
- Use `const` constructors everywhere possible.
- Avoid heavy computation in `build()` methods.
- Monitor with **Flutter DevTools** periodically.
- Target **WASM** for Web builds.

## 8. AI Guidelines
- **Privacy First:** Prefer on-device inference for task content.
- **Explainability:** AI-generated suggestions must be clearly marked.
