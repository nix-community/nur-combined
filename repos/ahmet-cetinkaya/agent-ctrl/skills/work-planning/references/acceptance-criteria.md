# Acceptance Criteria

Write criteria as observable outcomes rather than implementation wishes.

Each criterion should identify:

- the starting state or input;
- the behavior or invariant being exercised;
- the binary observable that decides success;
- the evidence source: test, diagnostic, build, inspection, sandbox run, or real-surface QA;
- relevant negative, boundary, failure, compatibility, or recovery behavior.

Add risk-specific criteria only when applicable. Security or auth work should prove trust-boundary behavior; data or migration work should name integrity and rollback checks; shared APIs should cover affected callers; user-facing work should include hands-on QA on the actual surface.

A refactor — structural change with no observable behavior change — says so in the plan's Scope and proves it. Start from a baseline task showing the project's checks green before the first edit, adding characterization tests first where the affected area has none. The criteria are then the same tests passing with their assertions untouched; a test edit beyond a mechanical rename or moved import means behavior changed, so that piece is split into its own feature or fix rather than carried in the refactor. Performance-sensitive paths get a before/after measurement.

In phased delivery, phase criteria prove that phase's outcome on its baseline, with later phases absent; whole-feature criteria are proven only at final umbrella verification. Map each criterion to the gate that proves it.

Avoid vague words such as “works,” “robust,” or “secure” without an observable. Follow the project's own coverage target and conventions; do not invent a global percentage, mandatory language pattern, or fixed file-size rule.
