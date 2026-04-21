# Workflow: Context-Driven Development

## CDD Lifecycle
We follow the **Spec → Plan → Implement → Review** protocol for all features and bug fixes.

1.  **Specification**: Define the requirements and scope in a `spec.md` file within the track directory.
2.  **Planning**: Create a granular task list in `plan.md`.
3.  **Implementation**: Execute tasks sequentially, following the plan as the "Single Source of Truth."
4.  **Review**: Verify code against the spec, ensuring high quality and adherence to standards.

## Git Protocol
-   **Branching**: All work happens on feature branches (e.g., `feature/xyz` or `track/xyz`).
-   **Commits**: Descriptive commit messages tied to specific tasks in the plan.
-   **Merging**: Code review required before merging to the main branch.

## Tooling
-   **Gemini CLI**: Used as the primary agent for implementation and review.
-   **Conductor**: Manages the persistent context and track lifecycle.
