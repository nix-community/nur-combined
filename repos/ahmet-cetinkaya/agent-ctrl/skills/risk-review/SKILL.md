---
name: risk-review
description: Perform a read-only, evidence-based review with correctness always active and additional lenses selected by risk or explicit area. Use after changes or on an explicit review request; do not use to fix findings or replace verification.
---

# Risk Review

## Trigger

Use when the user requests review, when completed work crosses a meaningful risk boundary, or when an independent gate is required before readiness.

## Non-trigger

Do not activate as blanket ceremony for every trivial edit, to implement fixes, or as a substitute for running diagnostics, tests, and real-surface QA.

## Method

1. Resolve the target and intent, inspect the complete relevant diff plus surrounding code and call sites.
2. Always review correctness. Select additional lenses from [lenses](references/lenses.md) based on changed behavior; preserve explicit `--area` selections.
3. Trace concrete scenarios and verify suspected failures before reporting them.
4. Report only findings satisfying [the finding contract](references/finding-contract.md), ordered by severity. If none qualify, say so and state residual test or evidence gaps.

The review is read-only. Security, authentication, persistent data, migrations, shared APIs, CI, or critical user-facing changes normally require independent advisor review; low-risk scoped changes may rely on scoped verification.
