---
name: ac:spec-implement
description: "Spec-driven implementation stage. Executes tasks.md phase by phase via speckit:implement, then hands off to /ac:verify."
category: workflow
complexity: advanced
mcp-servers: []
personas: [system-architect]
---

# `/ac:spec-implement` - Implement from Tasks

Minimal hub for the **implementation** stage. Executes the tasks defined in `tasks.md`,
phase by phase, respecting dependencies — delegates to **`speckit:implement`**.

## Usage

```bash
/ac:spec-implement
```

## Prerequisite

A `tasks.md` must exist and be consistency-checked for the current feature (produced by
**`/ac:spec-tasks`**).

## Workflow

1. **Implement** — run **`speckit:implement`** to process `tasks.md` in phases, executing
   each task in dependency order and marking progress.
2. **Converge** *(optional, for resumed/partial work)* — run **`speckit:converge`** to assess
   the current codebase against `spec.md`/`plan.md`/`tasks.md` and append any remaining
   unbuilt work as new tasks to `tasks.md`. Re-run step 1 to complete them. Repeat until
   converge finds no gap — useful when picking up an interrupted feature or verifying full
   spec coverage.

## Delegation

- Runs **`speckit:implement`**; optionally **`speckit:converge`** (from `commands/speckit/`).
- **Previous:** **`/ac:spec-tasks`**.
- **Next step:** **`/ac:verify`** (build·type·lint·test·security·diff gate), then
  **`/ac:review`** and **`/ac:pr`**.

## Output

Working code implementing the feature, ready for the verification gate.
