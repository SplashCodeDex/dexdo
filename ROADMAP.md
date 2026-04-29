# DexDo 2026 Product Roadmap

## Vision
To be the ultimate local-first, AI-enhanced task management application that feels native, performs flawlessly, and scales with the user's life across all platforms.

---

## Phase 1: Foundation Solidification (Next 2-4 Weeks)
**Goal:** Establish a world-class architecture and codebase that supports rapid feature development.

- [ ] **Architecture Realignment:** 
    - Migrate to a **Feature-First Modular Architecture**.
    - Separate code into `core/`, `features/`, and `shared/`.
- [ ] **State Management Modernization:**
    - Transition from `provider` (Legacy) to **Riverpod 3.x with Generators**.
    - Standardize reactive updates for local/remote sync.
- [ ] **Database & Persistence:**
    - Solidify **Isar** or **PowerSync** for ultra-fast local storage.
    - Implement robust Offline-First sync logic with Firestore.
- [ ] **CI/CD & Automation:**
    - Setup GitHub Actions for automated linting, testing, and distribution (Play Store/App Store/Web).
    - Integrate **Shorebird** for production code-push (OTA updates).

## Phase 2: User Experience & Design (Months 2-3)
**Goal:** Polished, accessible, and high-performance UI.

- [ ] **Design System:**
    - Implement a full tokens-based Design System.
    - Setup **Widgetbook** for component-driven development and testing.
- [ ] **Performance Tuning:**
    - Optimize for **Impeller** (Shader-precompilation-free rendering).
    - Implement lazy loading and prioritized list rendering for 1000+ tasks.
- [ ] **Accessibility (A11y):**
    - 100% Screen Reader compliance.
    - Dynamic Type support (font scaling).
    - High contrast / Color-blind modes.

## Phase 3: AI & Smart Features (Months 4-5)
**Goal:** Levering local and cloud AI for cognitive offloading.

- [ ] **On-Device AI (Gemini Nano):**
    - Private task categorization and summarization.
    - Smart due-date extraction from natural language.
- [ ] **Context-Aware Reminders:**
    - Geofenced tasks (remind when at "Grocery Store").
    - Smart rescheduling based on historical habits.

## Phase 4: Ecosystem & Integration (Month 6+)
**Goal:** Playing well with others.

- [ ] **Calendar Interop:**
    - Two-way sync with Google Calendar/Outlook.
- [ ] **Public API / Webhooks:**
    - Allow users to automate tasks via Zapier/IFTTT.
- [ ] **Collaboration Platform:**
    - Shared lists with real-time presence indicators.
