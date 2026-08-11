---
name: ac:implement
description: "Implement a feature, component, API, or service when the desired change is already known. Minimal hub over /sc:implement; distinct from the root-cause /ac:fix flow and spec-driven /ac:spec-implement."
category: workflow
complexity: standard
mcp-servers: [serena, context7]
personas: [architect, backend-architect, frontend-architect]
---

# `/ac:implement` - Implement a Feature

Minimal hub. Delegates to **`/sc:implement`** for feature, component, API, or service
implementation with context-based persona activation and framework-aware patterns.

This is the **standalone** implement step — call it when you already know what to build.
For root-cause bug, regression, failing-test, build-failure, or runtime-error repair use
**`/ac:fix`**. For the full eval-driven flow (define done → research → implement → verify → review) use
**`/ac:ship`**; for spec-artifact-driven work (`tasks.md`) use **`/ac:spec-implement`**.

## Usage

```bash
/ac:implement [feature description] [--type component|api|service|feature] [--with-tests]
```

## Workflow

1. **Analyze** — examine requirements and detect the technology/framework context.
2. **Ladder check** — consult `rules/minimal-engineering.md` and prefer, in order: no code, existing code, stdlib, native/platform features, then installed dependencies before custom code. Do not introduce unrequested abstractions or dependencies.
3. **Implement** — generate code in 15-minute-sized units, following existing conventions.
4. **Validate** — apply security and quality checks inline as you build.

## Delegation

- Runs **`/sc:implement`** for the implementation.
- Gather context first with **`/ac:explore`**; confirm library/API specifics via the
  **Context7 MCP**.
- **Next step:** **`/ac:verify`** (build·type·lint·test·security·diff gate), then
  **`/ac:review`**.

## Output

Working code implementing the request, ready for the verification gate.
