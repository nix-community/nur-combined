---
name: ac:spec
description: "Spec-driven flow entry point. Turns a feature description into a clarified specification by chaining speckit:specify + speckit:clarify, then hands off to /ac:spec-plan."
category: workflow
complexity: advanced
mcp-servers: []
personas: [requirements-analyst, system-architect]
---

# `/ac:spec` - Specify & Clarify

Minimal hub for the **specification** stage of the spec-driven flow. It creates the feature
spec from a natural-language description, then interrogates it for gaps — chaining
**`speckit:specify`** → **`speckit:clarify`**.

## Usage

```bash
/ac:spec [feature description]
```

## Prerequisite

The target project must be Spec Kit-initialized (`.specify/` present). If it is not, run
**`/ac:index`** first (it runs `specify init . --ai claude`), or seed `.specify/` from the
`speckit-scripts` skill.

## Workflow

0. **Constitution** *(optional, project-level)* — if the project has no
   `.specify/memory/constitution.md`, or you want to (re)establish guiding principles first,
   run **`speckit:constitution`**. It defines the principles all specs/plans must honor and
   keeps dependent templates in sync. Run once per project, not per feature.
1. **Specify** — run **`speckit:specify`** with the feature description to create/update
   `spec.md` (creates the feature branch + `specs/<n>/` dir via
   `scripts/bash/create-new-feature.sh`).
2. **Clarify** — run **`speckit:clarify`** to surface underspecified areas: up to 5 targeted
   questions, encoding each answer back into `spec.md`.

## Delegation

- Optionally runs **`speckit:constitution`** (step 0), then **`speckit:specify`** →
  **`speckit:clarify`** (all from `commands/speckit/`).
- **Next step:** **`/ac:spec-plan`** to turn the clarified spec into design artifacts.

## Output

A clarified `spec.md` on a dedicated feature branch, ready for planning.
