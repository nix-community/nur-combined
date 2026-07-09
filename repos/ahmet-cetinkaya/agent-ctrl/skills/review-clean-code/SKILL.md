---
name: review-clean-code
description: Comprehensive Clean Code audit across eight rule families (comments C1-C5, environments E1-E2, functions F1-F4, naming N1-N7, architecture G1-G10, hygiene G11-G20, logic G21-G36, tests T1-T9). Partitioned — run all aspects or a chosen subset. Invoked by /ac:review.
metadata:
  origin: ECC
---

# Clean Code Review

A comprehensive Clean Code audit based on Robert C. Martin's heuristics. This skill is
**partitioned** into eight aspects; each lives in its own part file and can be run
independently or together.

> Reference: `rules/clean-code.md` for the full catalog of rules.

## Aspects

| Aspect | Part file | Rules | Focus |
|--------|-----------|-------|-------|
| **comments** | `comments.md` | C1-C5 | Comment quality and accuracy |
| **environments** | `environments.md` | E1-E2 | Build and test automation |
| **functions** | `functions.md` | F1-F4 | Function design (args, output, flags) |
| **naming** | `naming.md` | N1-N7 | Naming conventions |
| **architecture** | `architecture.md` | G1-G10 | Code structure & macro architecture |
| **hygiene** | `hygiene.md` | G11-G20 | Code hygiene & clarity |
| **logic** | `logic.md` | G21-G36 | Logic & design decisions |
| **tests** | `tests.md` | T1-T9 | Test coverage & quality |

## How to Run

1. Determine which aspects to run. When invoked by `/ac:review`, the requested aspect list
   is passed in (the hub asks the user "all or which parts?"). When invoked directly with
   no aspect specified, default to **all eight**.
2. For each selected aspect, **load only that part file** (`skills/review-clean-code/<aspect>.md`)
   and apply its rules to the target files. Loading parts on demand keeps context lean.
3. Each aspect cites specific Rule IDs and produces **Refactored Code**.
4. Aggregate all aspect outputs into a single **Clean Code Audit Report**, then return it
   (to `/ac:review` for consolidation, or directly to the user).

## Output

One unified report grouped by aspect. For each finding: the violated Rule ID, the affected
region, and the refactored code (or test code, for the `tests` aspect).
