---
name: ac:fix
description: Root-cause-driven bug, regression, failing-test, build-failure, and runtime-error fix flow. Diagnose first, reproduce when possible, apply the minimal repair, then verify.
---

# `/ac:fix` — Fix a Defect

Root-cause fix flow. Use this when behavior is broken: a bug, regression, failing test, build failure, runtime error, or issue report. It diagnoses first, proves the failure when possible, applies the smallest fix, then runs the verification gate.

## Usage

```
/ac:fix <issue | error | failing test | broken behavior>
/ac:fix <issue> --diagnose-only
/ac:fix <issue> --with-review
```

## Workflow

Activate `systematic-debugging` and run its loop yourself, in this session: each hypothesis builds on the evidence of the last, so the loop keeps one context and no handoff. The skill owns the loop: reproduce, trace to the first invalid state, test competing hypotheses, fix at the owning layer, prove red → green, and escalate to `advisor` or stop with a blocker after repeated failed attempts. This command adds the entry gate, the flags, and the report around that loop. Delegate only work that needs little from the loop and returns one compact result: `explorer` for a broad code-path search, `researcher` for an external contract, and `advisor` for the escalation and the independent risk gate. Do not hand the diagnosis or the fix to `executor` or `worker`.

Run the [legacy check](../../skills/plan-execution/references/run-state.md#migrating-from-the-legacy-layout) before any plan or run-state access.

Before the first edit, create the run state under `.agents/work/<YYYYMMDD>-<scope-slug>/` with `branch` recorded at creation (initial `state.json` per the contract), following the [run-state contract](../../skills/plan-execution/references/run-state.md); this also applies with `--diagnose-only`. Capture the reproduction output and the red → green test logs under its `evidence/` directory, and append one `check` ledger event per check. Redact secrets before writing.

### 1. Triage

Classify the problem: bug, regression, failing test, runtime error, or build failure.

Route out of scope early:

- PR review comments → **`/ac:pr-address`**.
- New feature, component, API, or service → **`/ac:plan`** then **`/ac:run`**.
- Broad refactor, cleanup, or quality pass → **`/ac:review`** for findings, then a scoped plan or fix per finding.

### 2. Diagnose and fix

Run the skill's loop. Do not change code before the causal chain from trigger to first invalid state to symptom is stated. On top of the loop:

- With `--diagnose-only`, stop after the diagnosis and the recommended fix plan.
- Reproduce from existing evidence first: the failing test or the reported path. Add the smallest regression test, in the project's own test conventions, only when nothing captures the bug yet.
- Apply one semantic fix and change only the files the bug needs. Sweep callers of the changed function and fix the shared owner once; patching only the reported path leaves sibling callers broken.
- No drive-by refactors, formatting, cleanup, or speculative hardening.
- Ask the user only when investigation is genuinely blocked by missing information.

### 3. Verify

Verify the specific reproduction or regression test first, then activate `readiness-verification` for the affected scope. A new hard-to-diagnose failure loops back to diagnosis instead of stacking patches. When the fix touches security, auth, sensitive data, migrations, shared APIs, CI, or another high-risk boundary, apply the `secure-engineering` gate and an independent `advisor` pass.

### 4. Optional targeted review

With `--with-review`, or when the fix touches risky logic, run `/ac:review` scoped to the relevant lens (errors, types, security).

Cleanup the fix exposes is a separate follow-up (`/ac:review --area clean-code` or `--area simplify`), never bundled into the fix itself.

### 5. Commit strategy (only when separately authorized)

Committing is not part of the fix flow; it requires its own authorization. When the user does authorize it, apply the local-fixup policy from the `git-workflow` skill: if the complete change belongs wholly to a related commit that is provably unpushed, stage only the relevant files or hunks and use `git commit --fixup <sha>` instead of a noisy standalone commit. Otherwise create a normal semantic commit. Never rewrite published history without explicit authorization.

## Output

```text
Problem: <what was broken>
Root Cause: <causal chain with file:line references>
Evidence/Reproduction: <test, command, log, or repro path>
Fix Applied: <minimal change, or "diagnosis only">
Regression Test: <added/updated/existing test evidence>
Verification: <specific repro result + readiness verdict>
Confidence: <High|Medium|Low>
Follow-ups: <separate cleanup/review/product tasks, if any>
Run State: <path to the run-state directory>
```

## Next Step

Close the turn by mapping the fix outcome to one command:

- Fix verified and scoped → `/ac:verify` for the full readiness gate
- Fix touches risky logic and had no independent pass → `/ac:review --area <lens>`
- Root cause found but the repair is large or architectural → `/ac:plan <request>`
- Still unresolved after three materially different approaches → report the blocker and stop

Name exactly one recommendation. Committing remains a separate, authorized step.

## Boundaries

- Do not apply code changes before the root cause is understood.
- Do not bundle broad refactors, redesign, or unrelated cleanup into the fix.
- Do not commit or push — that is a separate, explicitly authorized step.
- For feature work or PR comment handling, use planning/execution flows instead.
