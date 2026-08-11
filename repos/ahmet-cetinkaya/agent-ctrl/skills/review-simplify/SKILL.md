---
name: review-simplify
description: Review code for simplification and over-engineering — reduce cyclomatic complexity, deep nesting, and boilerplate; delete reinvented stdlib, unneeded dependencies, and speculative abstractions. Use when code is hard to read, overly complex, or over-engineered. Invoked by /ac:review.
metadata:
  origin: ECC
---

# Code Simplification Review

Audit the provided files for **simplification, readability, and over-engineering**
opportunities. Two complementary lenses: *rewrite for clarity* (complexity) and *delete
what should not exist* (over-engineering). The best outcome of a diff is getting shorter.

**Role:** You are a code simplifier. Reduce complexity and cut over-engineering without
changing behavior.

## Lens 1 — Complexity & Readability (rewrite)

- **Complexity**: High cyclomatic complexity, deep nesting, overly long functions.
- **Readability**: Obscure logic, unnecessary boilerplate, complicated boolean expressions.
- **Modernization**: Opportunities to use newer, cleaner language features.
- **Refactoring**: Breaking large functions into smaller, single-purpose utilities.

## Lens 2 — Over-Engineering (delete)

Hunt what to remove, not just what to rewrite. Tag each finding and name its replacement:

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing the standard library ships. Name the function.
- `native:` dependency or code doing what the platform/framework already does. Name the feature.
- `yagni:` abstraction with one implementation, config nobody sets, a layer with one caller.
- Replacement order: `nothing > existing code > stdlib > native > installed dependency > fewer lines` per `rules/minimal-engineering.md`; choose the earliest viable replacement.
- `shrink:` same logic, fewer lines. Show the shorter form.

Format: `L<line>: <tag> <what>. <replacement>.` (or `<file>:L<line>: ...` for multi-file diffs).

Examples:

- `L12-38: stdlib: 27-line email validator class. "@" check in 1 line; real validation is the confirmation mail.`
- `L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`
- `repo.py:L88: yagni: AbstractRepository with one implementation. Inline it until a second exists.`
- `L52-71: delete: retry wrapper around an idempotent local call. Nothing replaces it.`
- `L30-44: shrink: manual loop builds a dict. dict(zip(keys, values)), 1 line.`

## Workflow

1. Receive the target files (from `/ac:review` or directly).
2. Apply both lenses: identify the most complex/obscure regions AND the over-engineered ones;
   highest-impact first.
3. Harvest `deferred:` markers and surface each shortcut whose ceiling or upgrade trigger is reached.
4. Produce **Findings** — for complexity, show the simplified refactored code; for
   over-engineering, one line per finding (location, what to cut, what replaces it).

## Boundaries

- Scope is complexity and over-engineering only. Correctness bugs, security holes, and
  performance belong to their own review areas — route them there, don't flag them here.
- Never flag trust-boundary validation, data-loss error handling, security controls, or
  accessibility affordances as bloat; they are the safety floor in
  `rules/minimal-engineering.md`.
- A single smoke test or `assert`-based self-check is the minimum, not bloat — never flag it
  for deletion.
- List findings; do not apply the fixes (that's `/sc:improve` / `/sc:cleanup`).

## Output

A structured findings list. End with the delete-lens scalar: **`net: -<N> lines possible.`**
If there is nothing to cut or simplify, say **`Lean already. Ship.`** and stop.
