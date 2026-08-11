---
name: ac:verify
description: "Reflect on task completion first (sc:reflect), then run the six-phase verification gate (build, type, lint, test, security, diff) last, and emit a READY/NOT READY report. Defers to the active profile's verification skill for exact toolchain commands; does not launch code reviews."
category: workflow
complexity: standard
mcp-servers: [serena]
personas: [quality-engineer]
---

# `/ac:verify` - Verification Gate

Applies the **`verification-loop`** skill. Run after **`/ac:implement`**, **`/ac:fix`**,
**`/ac:spec-implement`**, before a PR, or after refactoring. If a phase fails, STOP and fix
before continuing.

## Usage

```bash
/ac:verify [target]   # defaults to current git changes
```

## Order of Operations

1. **Reflection first** (primary focus) — validate the *task* was actually accomplished.
2. **Mechanical gate last** — confirm the code is *correct* (build → type → lint → test → security → diff).

Run reflection before the toolchain: there is no point burning build/test cycles on work that
does not satisfy the requirements. Reflection scopes what "correct" even means for this task.

## Reflection (primary focus — runs first)

Reflection confirms the *task* was actually accomplished. Reflection is this command's main job
beyond the toolchain — do not substitute code review for it.

Run **`/sc:reflect --type completion`** to validate task adherence and completion quality
(Serena reflection tools), surfacing unmet requirements, scope drift, or remaining work the
toolchain can't detect.

If reflection flags unmet requirements or scope drift, the verdict is **NOT READY** — stop and
address those gaps before spending cycles on the mechanical gate.

## Mechanical Gate (runs last)

Once reflection confirms the task is on-target, run the six-phase gate:

1. Build → 2. Type check → 3. Lint → 4. Test (meet the project's coverage target; default ≥80% when unset) → 5. Security (secrets, debug prints) → 6. Diff review.

Emit the `VERIFICATION REPORT` with an overall **READY / NOT READY** verdict. Even a passing
gate stays **NOT READY** if the earlier reflection step flagged unmet requirements.

## Stack Detection & Profile Delegation

Detect the stack and defer to the active project's **profile verification skill** for the
exact build/type/lint/test commands — this command stays stack-agnostic and never hard-codes
per-language toolchains.

If no profile skill matches, infer the toolchain from the project manifest (`package.json`
scripts, `pyproject.toml`/`Makefile`/`go.mod`/`Cargo.toml` targets) and run the equivalent
build/type/lint/test commands rather than skipping the phase.

## Delegation

- Common upstream callers: **`/ac:implement`**, **`/ac:fix`**, **`/ac:spec-implement`**, and refactor flows.
- Before applying any auto-fix that touches production state or runs destructive commands, apply the **`safety-guard`** skill to gate the operation.
- For hard-to-diagnose failures (build, test, or runtime), delegate to **`/sc:troubleshoot`** for root-cause analysis.
- This command does **not** launch code reviews. Deeper code-quality work is a separate step under **`/ac:review`**, invoked by the caller after the gate passes.
- For coverage gaps, use **`/sc:test`**.
