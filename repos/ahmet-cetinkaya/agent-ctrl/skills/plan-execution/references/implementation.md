# Implementation Guidance

Use this decision ladder at the correct ownership layer:

1. Confirm the requested behavior is needed.
2. Reuse or extend an established local pattern.
3. Prefer the language standard library or native platform behavior.
4. Prefer a suitable already-installed dependency.
5. Add the smallest custom implementation that satisfies the acceptance criteria.

Do not add speculative abstractions, dependencies, options, files, cleanup, or broad refactors. Trace inputs, consumers, error paths, and affected callers before modifying shared behavior. Preserve unrelated edits and generated-file conventions.
