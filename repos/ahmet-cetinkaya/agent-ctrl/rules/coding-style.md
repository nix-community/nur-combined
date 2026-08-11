## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate existing ones:

```
// Pseudocode
WRONG:  modify(original, field, value) → changes original in-place
CORRECT: update(original, field, value) → returns new copy with change
```

Rationale: Immutable data prevents hidden side effects, makes debugging easier, and enables safe concurrency.

## Core Principles

### KISS (Keep It Simple)

- Prefer the simplest solution that actually works
- Avoid premature optimization
- Optimize for clarity over cleverness

### DRY (Don't Repeat Yourself)

- Extract repeated logic into shared functions or utilities
- Avoid copy-paste implementation drift
- Introduce abstractions when repetition is real, not speculative

### YAGNI (You Aren't Gonna Need It)

- Do not build features or abstractions before they are needed
- Avoid speculative generality
- Start simple, then refactor when the pressure is real

### Minimal Engineering

- Walk `rules/minimal-engineering.md` in order: skip, reuse, stdlib, native, installed dependency, one line, minimum custom code.
- Prefer deletion over addition and boring over clever; use the shortest diff only when it is placed at the correct layer.

## Functions

- **Do one thing** at one level of abstraction; a function should only call functions one level below it.
- **Small:** target <50 lines; split large functions into focused pieces with clear responsibilities.
- **Few arguments:** 0-2 is a useful default. Group arguments only when they form a real
  domain concept; do not create a parameter object solely to satisfy a count.
- **No output arguments:** arguments are inputs. Return new values instead of mutating a passed-in argument.
- **No flag arguments:** a boolean/enum that selects behavior means the function does more than one thing. Split into explicit functions (`renderSingle()` / `renderSuite()`).
- **Remove dead functions:** delete methods never invoked — do not comment them out.

## Naming

Reveal intent first, then follow casing conventions.

- **Intent-revealing:** rename generic names (`data`, `info`, `item`) to specific ones (`customerRecord`). If you must read the body to know what a name does, rename it.
- **Honest names:** the name must match the implementation, including side effects — if `getAccount()` creates on miss, call it `getOrCreateAccount()`.
- **No encodings:** no Hungarian notation (`strName`, `iCount`), no member prefixes (`m_name`), no interface prefixes (`IShape`).
- **Casing:** variables/functions `camelCase`; booleans prefer `is`/`has`/`should`/`can`; interfaces, types, components `PascalCase`; constants `UPPER_SNAKE_CASE`; custom hooks `use` prefix.

## Comments

Comments explain **why**, never **what** or **when**.

- Keep only comments that justify *why* code exists; delete ones that restate the code (`i++; // increment i`).
- **No commented-out code** — Git remembers past code.
- **No change annotations** (`// Added`, `// Fixed`, `// Updated`) — change history belongs in Git commit history.
- Delete obsolete comments immediately; a wrong comment is worse than none.

## Abstraction & Coupling

- **Law of Demeter:** talk only to immediate collaborators; avoid transitive chains (`a.getB().getC().doSomething()`).
- **Polymorphism over type-switching:** replace `switch`/`if-else` chains on a type code with polymorphism (Strategy/State).
- **Depend on abstractions:** high-level modules must not depend on low-level details; base classes know nothing about their derivatives.
- **Explicit dependencies:** pass dependencies via constructor or arguments, not hidden globals or statics.

## File Organization

- Prefer high cohesion and low coupling over arbitrary file-size targets.
- Split a file only when doing so creates a clear ownership or responsibility boundary.
- Extract utilities when reuse is real, not to move a few lines elsewhere.
- Organize by feature/domain, not by type.

## Error Handling

Handle errors comprehensively at the layer that can add context or recover:
- Do not add catch-and-rethrow wrappers at every level.
- Provide user-friendly error messages in UI-facing code
- Log detailed error context on the server side
- Never silently swallow errors; never suppress warnings or disable failing tests to hide a problem

## Input Validation

ALWAYS validate at system boundaries:
- Validate all user input before processing
- Use schema-based validation where available
- Fail fast with clear error messages
- Never trust external data (API responses, user input, file content)

## Conditionals & Boundaries

- **Guard clauses:** handle boundary conditions (`null`, `0`, empty, max values) up front with early returns.
- **Prefer early returns** over nested conditionals once logic starts stacking.
- **Encapsulate conditionals:** extract complex boolean expressions into named predicates (`if (shouldStop())`).
- **Prefer positive conditionals** — avoid double negatives like `if (!isNotReady)`.
- **Centralize boundary math** (`+1`/`-1`) instead of scattering it.

## Magic Numbers & Strings

Replace repeated or domain-significant values with named constants that reveal intent
(`SECONDS_PER_DAY`, `MAX_RETRIES`, `STATUS_ACTIVE`, `ROLE_ADMIN`). Keep obvious local
literals inline when a name would add indirection without meaning.

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and intent-revealing
- [ ] Functions do one thing, are small (<50 lines), and take ≤2 arguments
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling; no swallowed errors
- [ ] No hardcoded values (use constants or config)
- [ ] No mutation (immutable patterns used)
- [ ] No commented-out code or change-annotation comments
- [ ] Minimal engineering ladder walked; no existing/stdlib/native solution or unrequested abstraction was missed
