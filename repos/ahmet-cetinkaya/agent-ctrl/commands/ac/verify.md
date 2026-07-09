---
name: ac:verify
description: "Run the six-phase verification gate (build, type, lint, test, security, diff) and emit a READY/NOT READY report. Defers to the active profile's verification skill for exact toolchain commands."
category: workflow
complexity: standard
mcp-servers: [serena]
personas: [code-reviewer, quality-engineer]
---

# `/ac:verify` - Verification Gate

Applies the **`verification-loop`** skill. Run after a feature/change, before a PR, or after refactoring.
If a phase fails, STOP and fix before continuing.

## Usage

```bash
/ac:verify [target]   # defaults to current git changes
```

## Phases

1. Build → 2. Type check → 3. Lint → 4. Test (coverage ≥80%) → 5. Security (secrets, debug prints) → 6. Diff review.

Emit the `VERIFICATION REPORT` with an overall **READY / NOT READY** verdict.

## Reflection (final step)

After the mechanical gate, run **`/sc:reflect --type completion`** to validate task
adherence and completion quality (Serena reflection tools). The gate confirms the code is
correct; reflection confirms the *task* was actually accomplished — surfacing unmet
requirements, scope drift, or remaining work the toolchain can't detect.

Fold its findings into the final verdict: even a READY gate becomes **NOT READY** if
reflection flags unmet requirements.

## Stack Detection & Profile Delegation

Detect the stack and defer to the matching **profile verification skill** for exact commands:

- `go.mod` → **`go-verification`** (profiles/go)
- `Cargo.toml` → **`rust-verification`** (profiles/rust)
- `project.godot` → **`godot-verification`** (profiles/godot)

## Delegation

- On build failures, hand off to the matching **`/ecc:*-build`** resolver (`ecc:go-build`, `ecc:rust-build`, etc.).
- For hard-to-diagnose failures (build, test, or runtime), delegate to **`/sc:troubleshoot`** for root-cause analysis.
- For deeper code-quality findings, hand off to **`/ac:review`**.
- For coverage gaps, use **`/ecc:test-coverage`** or **`/sc:test`**.
