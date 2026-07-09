---
name: ac:spec-plan
description: "Spec-driven planning stage. Turns a clarified spec into design artifacts via speckit:plan, then hands off to /ac:spec-tasks."
category: workflow
complexity: advanced
mcp-servers: []
personas: [system-architect]
---

# `/ac:spec-plan` - Plan from Spec

Minimal hub for the **planning** stage. Runs the implementation-planning workflow over the
current feature's `spec.md`, generating design artifacts — delegates to **`speckit:plan`**.

## Usage

```bash
/ac:spec-plan [technical constraints / stack notes]
```

## Prerequisite

A clarified `spec.md` must exist for the current feature (produced by **`/ac:spec`**).

## Workflow

1. **Plan** — run **`speckit:plan`** (scaffolds `plan.md` via
   `scripts/bash/setup-plan.sh`, then fills design artifacts: data model, contracts,
   research, quickstart) honoring any stack/constraint notes you pass.
2. **Checklist** *(optional)* — run **`speckit:checklist`** to generate a feature-specific
   quality checklist (security, UX, testing, or any domain you name) from the design
   artifacts. Use it as an acceptance gate before or during implementation.

## Delegation

- Runs **`speckit:plan`**, optionally **`speckit:checklist`** (from `commands/speckit/`).
- **Previous:** **`/ac:spec`** (specify + clarify).
- **Next step:** **`/ac:spec-tasks`** to break the plan into an ordered task list.

## Output

`plan.md` plus its design artifacts, ready for task generation.
