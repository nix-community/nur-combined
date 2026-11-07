# Task Contract

Every delegated implementation task includes:

- **Goal** — the exact outcome, inherited verbatim when it comes from a plan.
- **Scope** — files or boundaries the worker may change, its declared write set, and explicit exclusions. Treat lockfiles, manifests, generated outputs, settings, plans, and any file shared by multiple tasks as exclusive write surfaces.
- **Context** — relevant paths, symbols, conventions, constraints, decisions already made, and the conventions and gotchas earlier tasks discovered.
- **Dependencies** — completed prerequisites and outputs the task may rely on.
- **Acceptance criteria** — observable conditions the parent will verify.
- **Verification** — expected diagnostics, tests, build checks, and hands-on QA.
- **Safety** — operations not authorized, unrelated work to preserve, and risk gates.
- **Return** — changed files, evidence, assumptions, blockers, remaining risks, and conventions or gotchas a later task should know.

A leaf worker does not delegate, redesign the plan, expand scope, or treat its own completion claim as proof. The parent reads changed state and validates the evidence before marking the task complete.
