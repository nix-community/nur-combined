# Readiness Gates

Evaluate only applicable gates, but never silently skip one.

| Gate | Evidence |
| --- | --- |
| Intent and acceptance fit | Requirement-to-change trace and unmet-item check; with a linked spec, a criterion ↔ evidence table covering every `FR-###`, `SC-###`, and `PB-<n>`, plus a drift note for code behavior no requirement asks for |
| Diagnostics and types | Project language-server or type command over changed scope |
| Build | Project-defined build or compile command |
| Lint and formatting | Existing configured command; do not introduce a new formatter policy |
| Tests | Focused regression tests, then broader suites justified by shared impact |
| Security | Risk-triggered secret, dependency, input, auth, data, migration, or CI checks |
| Diff and working state | Unintended-file, generated-output, conflict-marker, and unrelated-change inspection |
| Real-surface QA | Exact user action, CLI invocation, API request, sandbox apply, or data readback with observable result |

Use the project's own quality and coverage thresholds. A globally invented percentage, a check that never ran, or a dry run where actual behavior is required cannot support `READY`.

## Hands-on QA method

Brainstorm scenarios before touching the surface, then execute by priority:

1. List scenarios as one-liners with expected behavior: the golden path, edge and failure inputs, regression scenarios on features sharing the changed code paths, and — where applicable — environmental conditions (slow network, missing config, expired credentials) and UX states (layout, loading, error messages).
2. Ask what a hostile or careless user would do, add the resulting scenarios, and group by priority: P0 must pass, P1 should pass, P2 nice to pass.
3. Execute in priority order. Each result records the exact action, the expected observable, the actual observable, and PASS or FAIL with captured evidence on failure.
4. If the surface cannot even start, that is an immediate applicable failure; do not continue scripting around it.

Every reported PASS must correspond to an action actually performed with its real output; an unexecuted scenario is missing evidence, not a pass.
