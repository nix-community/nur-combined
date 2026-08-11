---
name: ac:fix
description: "Root-cause-driven bug, regression, failing-test, build-failure, and runtime-error fix flow. Diagnose first, reproduce when possible, apply the minimal repair, then verify."
category: workflow
complexity: standard
mcp-servers: [serena]
personas: [root-cause-analyst, quality-engineer]
---

# `/ac:fix` - Fix a Bug or Regression

Root-cause fix hub. Use this when behavior is broken: a bug, regression, failing test,
build failure, runtime error, or issue report. It diagnoses first, proves the failure when
possible, applies the smallest fix, then runs the verification gate.

For feature work where the desired change is already known, use **`/ac:implement`**. For Pull
Request review comments, use **`/ac:pr-address`**.

## Usage

```bash
/ac:fix [issue | error | failing test | broken behavior]
/ac:fix [issue] --type bug|regression|test|runtime|build
/ac:fix [issue] --diagnose-only
/ac:fix [issue] --with-review
```

## Workflow

### 1. Triage

Classify the problem: bug, regression, failing test, runtime error, or build failure.

Route out of scope early:

- PR review comments → **`/ac:pr-address`**.
- New feature/component/API/service → **`/ac:implement`** or **`/ac:ship`**.
- Broad refactor, cleanup, or quality pass → **`/ac:review`** for findings, then **`/sc:improve`** or **`/sc:cleanup`** to apply.

### 2. Diagnose first

Use **`/sc:troubleshoot`** for systematic root-cause analysis. Do not patch symptoms.

- Trace from trigger → symptom → first invalid state.
- State the causal chain before changing code.
- If the chain has an uncertain link, test a concrete prediction.
- Ask the user only when investigation is genuinely blocked by missing information.

With `--diagnose-only`, stop after the diagnosis and recommended fix plan.

### 3. Reproduce

Prefer existing evidence over new scaffolding:

1. Run the existing failing test or reported reproduction path when available.
2. If no test captures the bug, identify the smallest regression test that should fail first.
3. Follow the project's existing test conventions before adding or changing tests.

### 4. Fix minimally

Apply one semantic fix for the confirmed root cause.

- Change only the files needed for the bug.
- Avoid drive-by refactors, formatting, cleanup, or speculative hardening.
- Sweep callers of the function being changed and fix the shared owner/root once rather than patching each caller; patching only the reported path leaves sibling callers broken.
- Shortest diff wins only at the correct layer; see `rules/minimal-engineering.md`, because a wrong-layer minimal patch is another bug.
- If a fix attempt fails, invalidate that hypothesis explicitly before trying another.
- Before destructive or production-touching actions, apply the **`safety-guard`** skill.

### 5. Verify

First verify the specific reproduction or regression test. Then run **`/ac:verify`** for the
full build·type·lint·test·security·diff gate.

If verification reveals a new hard-to-diagnose build, test, or runtime failure, loop back to
**`/sc:troubleshoot`** instead of stacking patches.

### 6. Optional targeted review

Run targeted review when requested with `--with-review`, or when the fix touches risky logic:

- Error paths → **`/ac:review --area errors`**.
- Type-sensitive changes → **`/ac:review --area types`**.
- Trust boundaries, auth, input handling, secrets → **`/ac:review --area security`**.

Use `clean-code` or `simplify` only as a separate follow-up when the fix exposes cleanup work.

### 7. Commit strategy

After verification and any requested review improvements, apply the **Local Fixup Commits**
policy from the `git-workflow` skill. If the complete change belongs wholly to a related commit
that is provably unpushed, stage only the relevant files or hunks and use
`git commit --fixup <sha>` instead of a noisy standalone commit. Otherwise create a normal
semantic commit. Never rewrite published history without explicit authorization.

## Output

Emit a **`FIX REPORT`**:

```text
Problem: <what was broken>
Root Cause: <causal chain with file:line references>
Evidence/Reproduction: <test, command, log, or repro path>
Fix Applied: <minimal change, or "diagnosis only" if not applied>
Regression Test: <added/updated/existing test evidence>
Verification: <specific repro result + /ac:verify result>
Confidence: <High|Medium|Low>
Follow-ups: <separate cleanup/review/product tasks, if any>
```

## Boundaries

- Do not use this for feature work; use **`/ac:implement`** or **`/ac:ship`**.
- Do not use this for PR review comment handling; use **`/ac:pr-address`**.
- Do not apply code changes before root cause is understood.
- Do not bundle broad refactors or unrelated cleanup into the bug fix.
- Do not touch production state or destructive commands without explicit safety gating.
