---
name: ac:spec-tasks
description: "Spec-driven task stage. Generates an ordered tasks.md via speckit:tasks, then cross-checks spec/plan/tasks consistency via speckit:analyze."
category: workflow
complexity: advanced
mcp-servers: []
personas: [system-architect, quality-engineer]
---

# `/ac:spec-tasks` - Tasks & Analyze

Minimal hub for the **task-breakdown** stage. Generates the dependency-ordered task list from
the design artifacts, then runs a non-destructive consistency analysis across
`spec.md` / `plan.md` / `tasks.md` — chaining **`speckit:tasks`** → **`speckit:analyze`**.

## Usage

```bash
/ac:spec-tasks
```

## Prerequisite

A `plan.md` with design artifacts must exist for the current feature (produced by
**`/ac:spec-plan`**).

## Workflow

1. **Tasks** — run **`speckit:tasks`** (scaffolds `tasks.md` via
   `scripts/bash/setup-tasks.sh`, then derives dependency-ordered, actionable tasks from the
   design artifacts).
2. **Analyze** — run **`speckit:analyze`** for a read-only cross-artifact consistency and
   quality check across `spec.md`, `plan.md`, and `tasks.md`. Surfaces gaps/contradictions
   before implementation; fixes are applied by re-running the relevant stage, not here.
3. **To issues** *(optional)* — to track the work on GitHub instead of implementing locally,
   run **`speckit:taskstoissues`** to convert `tasks.md` into dependency-ordered GitHub
   issues for the feature.

## Delegation

- Runs **`speckit:tasks`** then **`speckit:analyze`**; optionally
  **`speckit:taskstoissues`** (from `commands/speckit/`).
- **Previous:** **`/ac:spec-plan`**.
- **Next step:** **`/ac:spec-implement`** to execute the tasks.

## Output

`tasks.md` plus a consistency report (and, optionally, GitHub issues). Resolve any flagged
issues before implementing.
