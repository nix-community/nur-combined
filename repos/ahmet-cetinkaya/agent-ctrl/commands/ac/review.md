---
name: ac:review
description: "Central code-review hub. With no area argument, asks (multi-select) which review areas to run, then applies the matching review lenses and consolidates one severity-ordered report."
---

# `/ac:review` — Central Code Review Hub

This command is the **single entry point** for all code review. It does not review code itself — it selects a **target**, resolves which **review areas** to run, applies the matching lenses from the `risk-review` skill, and consolidates their output into one report.

Read-only on project files: findings are reported, never auto-fixed. The only writes are the review record, its ledger event, and the work item's `state.json` under `.agents/work/` (step 5).

## Usage

```bash
/ac:review [target] [--area <area1> <area2> ...]
```

### Target

- **`pr`**: review the changes on the active Pull Request.
- **`git`**: review uncommitted/staged/untracked `git diff` changes (default).
- **`[path]`**: review files under a path (e.g., `.`, `src/auth`).
- If no target is given → default to `git` changes; if there are none → target `.`.

## Review Areas

Each area is a lens defined in [`risk-review`](../../skills/risk-review/SKILL.md); load only the selected ones.

| Area | Focus | Partitioned? |
| --- | --- | --- |
| **correctness** | Logic errors, edge cases, broken invariants, concurrency, regressions | — (always active) |
| **clean-code** | Readability, naming, structure, duplication, dead code — the write-time `clean-code` rule, checked | — |
| **security** | Trust boundaries, authn/authz, injection, secrets, sensitive data | — |
| **performance** | Demonstrated hot paths, algorithmic growth, queries, allocations, contention | — |
| **architecture** | Ownership, coupling, public contracts, layering, reversibility | — |
| **errors** | Propagation, recovery, partial state, observability, user-safe messages | — |
| **types** | Contract accuracy, unsafe assertions, nullability, serialization | — |
| **simplify** | Complexity and over-engineering: delete/stdlib/native/yagni/duplicate/shrink | — |
| **tests** | Suite effectiveness: correctness, false positives, missing edge/error cases, flakiness risk, meaningful coverage | — |

## Flow

Run the [legacy check](../../skills/plan-execution/references/run-state.md#migrating-from-the-legacy-layout) before any plan or run-state access.

### 1. Resolve target

Collect the files in scope from the target (PR / git diff / path), per the rules above. Include untracked files when reviewing working-tree changes — new files are where defects hide.

### 2. Resolve areas

- **If `--area` is passed:** use those areas directly — do **not** ask.
- **If no area is passed:** ask with a **multi-select** question, listing the areas above with their one-line descriptions. The user picks any subset (selecting all = full review).
- Inspect what the files do and what changed, and mark every area the content warrants as recommended in the same question, with a one-line reason each (`errors` for new failure paths, `tests` when test files changed, `security` for auth or input handling).

**Ask through the runtime's own question tool, not through chat text.** Use the native interactive prompt the agent runtime provides (in Claude Code: `AskUserQuestion` with `multiSelect: true`), so the areas render as selectable options rather than a list the user has to retype. One option per review area, each carrying its one-line description as the option label/description. If the tool is not in your tool list it may be deferred: load it first (Claude Code: `ToolSearch` with `select:AskUserQuestion`). Fall back to a plain numbered list in chat only after loading was attempted and the runtime still exposes no question tool, and say that you fell back.

- **Correctness is always included**, whether or not it was selected.
- When the diff crosses a risk boundary (auth, persistent or sensitive data, schema or migration, shared API, CI), add `security` and route an independent pass to `advisor` even if it was not selected. State that you did so.

### 3. Apply the lenses

`clean-code` covers test code too (naming, structure, duplication); the top-level `tests` area covers whether tests catch real bugs. Selecting both is valid.

For each selected area, apply its lens to the target files. Run independent areas in parallel where possible. Use `explorer` to establish surrounding context — callers, contracts, and tests — so findings rest on how the code is actually used rather than on the diff in isolation.

Reviewers may use **`serena`** for symbol-level navigation and **`codegraph`** for call paths and blast-radius analysis on the changed symbols. For the top-level `tests` area, include production code plus its corresponding tests in context and review from a risk-based testing perspective.

### 4. Consolidate

Compile every lens's findings into a single, structured **Code Review Report**, grouped by area with the highest-severity findings first.

### 5. Record the findings

Write the consolidated report under the run state's `reports/` directory — `.agents/work/<slug>/` when the reviewed changes implement a plan, `.agents/work/<YYYYMMDD>-<scope-slug>/` otherwise; an archived plan is reviewed into a new plan-less item — as `reports/<stamp>-code-review.md`, following the [run-state contract](../../skills/plan-execution/references/run-state.md). Keep the report's verdict, areas, findings, and evidence gaps; add the target and the reviewed revision (commit, PR head, or `working tree`). Append one `code_review` ledger event carrying the verdict and the record path. Redact secrets before writing; a finding whose evidence cannot be redacted reliably is summarized, not copied.

## Finding discipline

Report only findings satisfying the [finding contract](../../skills/risk-review/references/finding-contract.md) — every one needs a stable `file:line` pointer, severity and impact, a concrete failure scenario, reproduction or evidence, and a remedy at the owning layer. Suspicions without evidence belong under "Evidence gaps", never as findings.

## Output

```text
Verdict: <approve | approve-with-nits | request-changes>
Confidence: <HIGH | MEDIUM | LOW>
Areas reviewed: <list, noting any auto-added by risk>

Findings (by severity):
  [CRITICAL|MAJOR|MINOR|NITPICK] <area> file:line
    Issue / scenario / evidence / remedy

Evidence gaps: <what could not be verified and why>
Record: <path to the review record>
```

## Apply Findings

`/ac:review` reports findings; to act on them, hand off:

- **`/ac:fix`** — repair a defect the review surfaced, root-cause first.
- **`/ac:plan`** — plan a larger refactor or architectural change the findings justify.
- **`/ac:verify`** — run the readiness gate when findings need runtime evidence or post-fix confirmation.

## Next Step

Close the turn by mapping the verdict to one command:

- `request-changes` with a concrete defect → `/ac:fix <finding>`
- `request-changes` needing a larger refactor → `/ac:plan <request>`
- `approve-with-nits` → name the optional follow-ups and let the user choose
- `approve` on a branch ready to ship → `/ac:verify`, then `/ac:pr`
- Findings need runtime evidence → `/ac:verify`

Name exactly one primary recommendation. Never apply fixes from this command.

## Boundaries

- This command **only** orchestrates and reports. It does not modify project files; it writes only its review record, ledger event, and the work item's `state.json` under `.agents/work/`.
- Never skip the area question when no `--area` is supplied — area selection is the point of the hub.
- Do not apply a lens that was not selected, except the always-on correctness lens and risk-triggered security escalation.
- Do not soften severity to avoid friction, or invent findings to appear thorough. Security, auth, and data-handling findings are never downgraded without evidence.
