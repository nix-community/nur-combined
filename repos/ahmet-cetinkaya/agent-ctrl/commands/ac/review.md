---
name: ac:review
description: "Central code-review hub. With no area argument, asks (multi-select) which review areas to run, then invokes the matching review skills and consolidates one report."
category: review
complexity: advanced
mcp-servers: [serena, codegraph]
personas: [code-reviewer, system-architect]
---

# `/ac:review` - Central Code Review Hub

This command is the **single entry point** for all code review. It does not review code
itself — it selects a **target**, asks which **review areas** to run, invokes the matching
**review skills**, and consolidates their output into one report.

## Usage

```bash
/ac:review [target] [--area <area1> <area2> ...]
```

### Target

- **`pr`**: review the changes on the active Pull Request.
- **`git`**: review uncommitted/staged `git diff` changes (default).
- **`[path]`**: review files under a path (e.g., `.`, `src/auth`).
- If no target is given → default to `git` changes; if there are none → target `.`.

## Review Areas → Skills

Each area maps to a review skill (loaded only when selected):

| Area | Skill | Partitioned? |
|------|-------|--------------|
| **clean-code** | `review-clean-code` | ✅ 8 aspects |
| **security** | `security-review` | — |
| **performance** | `review-performance` | — |
| **architecture** | `review-architecture` | — |
| **errors** | `review-errors` | — |
| **types** | `review-types` | — |
| **simplify** | `review-simplify` | — (complexity + over-engineering: delete/stdlib/native/yagni/shrink) |
| **tests** | `review-tests` | — (suite effectiveness: correctness, false positives, missing edge/error cases, flakiness risk, meaningful coverage) |

## Flow

### 1. Resolve target
Collect the files in scope from the target (PR / git diff / path), per the rules above.

### 2. Resolve areas

- **If `--area` is passed:** use those areas directly — do **not** ask.
- **If no area is passed:** ask with `AskUserQuestion` (**multi-select**), listing all
  eight areas above with their one-line descriptions. The user picks any subset (selecting
  all = full review).

### 3. Resolve clean-code aspects (only if `clean-code` was selected)

`clean-code` is partitioned into eight aspects. Ask a **second** `AskUserQuestion`
(**multi-select**): **all** of them, or a chosen subset:

`comments (C1-C5)`, `environments (E1-E2)`, `functions (F1-F4)`, `naming (N1-N7)`,
`architecture (G1-G10)`, `hygiene (G11-G20)`, `logic (G21-G36)`, `tests (T1-T9)`.

Clean-code `tests (T1-T9)` means test-code cleanliness (naming, structure, duplication,
readability). Top-level `tests` means suite effectiveness (whether tests catch real bugs).
Selecting both is valid and non-redundant.

Pass the chosen aspect list to the `review-clean-code` skill (it loads only those part
files). If `--area clean-code` was passed without an explicit aspect list, default to all
eight.

### 4. Invoke the review skills
For each selected area, invoke its skill (from the table) with the target files via the
Skill tool. Run independent areas in parallel where possible. For `clean-code`, pass the
selected aspect list. Reviewers may use **`serena`** for symbol-level navigation and
**`codegraph`** for call paths and impact analysis on the changed symbols. For the top-level `tests`
area, include production code plus corresponding tests in the target context, and invoke it
from a quality-engineer, risk-based testing perspective.

### 5. Consolidate
Compile every skill's findings into a single, structured **Code Review Report**, grouped by
area. Surface the highest-severity findings first.

## Apply Findings

`/ac:review` reports findings; to act on them, hand off:

- **`/sc:improve`** — apply systematic code-quality/performance/maintainability fixes from
  the findings.
- **`/sc:cleanup`** — remove dead code and tidy structure (pairs with the `simplify` area).
- **`/ecc:test-coverage`** — implement prioritized missing or weak tests from the `tests`
  findings.
- **`/sc:test`** — execute tests and measure coverage when findings need runtime evidence or
  post-fix verification.

## Boundaries

- This command **only** orchestrates. The review logic lives in the review skills.
- Never skip the area question when no `--area` is supplied — area selection is the point of
  the hub.
- Do not load a review skill (or a clean-code aspect part file) that was not selected.
