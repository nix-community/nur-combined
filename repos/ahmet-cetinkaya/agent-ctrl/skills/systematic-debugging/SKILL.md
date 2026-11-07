---
name: systematic-debugging
description: Diagnose and fix a reproducible defect through observed state and competing hypotheses. Use for bugs, regressions, crashes, failing tests, build failures, hangs, or wrong output; do not use for feature design, speculative cleanup, or ordinary implementation.
---

# Systematic Debugging

## Trigger

Use for broken behavior with a symptom that can be observed or bounded.

## Non-trigger

Do not activate for a new feature, broad refactor, read-only review, or a request whose expected behavior still needs product decisions.

## Loop

1. Define the expected and observed behavior and reproduce the smallest reliable failure.
2. Trace trigger to the first observed invalid state. Runtime or test evidence outranks a plausible reading of code.
3. Form competing hypotheses and write a distinct prediction for each.
4. Test one discriminating prediction at a time; invalidate failed hypotheses explicitly.
5. Apply the minimum root-cause fix at the layer that owns the invariant.
6. Show red/green regression evidence when practical, then run scoped readiness verification and clean up temporary diagnostics.

Use [the hypothesis loop](references/hypothesis-loop.md) for the evidence ledger. After two serious failed hypotheses, request read-only advisor help with attempts and evidence. After three materially different approaches fail, stop and report a blocker instead of stacking another speculative patch.

Route security, auth, sensitive data, migrations, or shared API changes through an independent risk gate.
