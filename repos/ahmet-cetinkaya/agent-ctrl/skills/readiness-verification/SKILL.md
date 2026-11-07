---
name: readiness-verification
description: Produce a fail-closed readiness verdict from requirement fit, project-defined checks, and real-surface evidence. Use after implementation or before delivery; do not use to edit code, review style, or declare readiness from missing evidence.
---

# Readiness Verification

## Trigger

Use when work claims to be complete, before delivery, or when the user explicitly requests verification.

## Non-trigger

Do not activate to implement fixes, conduct an open-ended review, invent project requirements, or replace a missing execution environment with optimism.

## Gate

1. Confirm the target, intended outcome, scope, and acceptance criteria before running expensive checks. When a spec is linked, its `FR-###`, `SC-###`, and `PB-<n>` entries are the acceptance criteria; each needs its own evidence row, except a struck-through descoped entry, whose row cites its move and the decision under the spec's Deviations.
2. Discover commands from project instructions, manifests, CI, and neighboring workflows.
3. Apply relevant [gates](references/gates.md): diagnostics, build, type, lint, tests, security, diff, and hands-on QA on user-facing or operational surfaces.
4. Record each gate as `PASS`, `FAIL`, `BLOCKED`, or `NOT_APPLICABLE`, with command/tool, scope, and observable.
5. Capture each gate's real output and write the evidence record as the `plan-execution` run-state reference defines, redacting secrets.
6. Return exactly one overall verdict: `READY`, `NOT_READY`, or `INCONCLUSIVE`, with the evidence record's path.

Any applicable failure makes the result `NOT_READY`. Missing, stale, ambiguous, or blocked evidence makes it `INCONCLUSIVE` unless another known failure already makes it `NOT_READY`. For security, authentication, persistent or sensitive data, schema or migration, shared API, CI, or critical user-facing changes, readiness also requires an independent advisor review and the applicable `secure-engineering` gate. Never modify project files while verifying; the evidence record and its ledger events are the only writes.
