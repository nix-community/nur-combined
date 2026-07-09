---
name: ac:brainstorm
description: "Discover and shape requirements from a vague idea via Socratic dialogue, then hand a concrete brief to /ac:research or /ac:ship. Minimal hub over /sc:brainstorm."
category: workflow
complexity: standard
mcp-servers: []
personas: [architect, requirements-analyst]
---

# `/ac:brainstorm` - Shape the Idea Before Building

Minimal hub. Delegates to **`/sc:brainstorm`** for interactive requirements discovery —
turning an ambiguous idea into a concrete, actionable brief through Socratic questioning.

## Usage

```bash
/ac:brainstorm [topic or rough idea]
```

## Workflow

1. **Explore** — Socratic dialogue to surface the real need behind the idea.
2. **Validate** — feasibility and scope assessment.
3. **Specify** — produce a concrete brief (goal, constraints, success criteria).

## Delegation

- Runs **`/sc:brainstorm`** for the discovery dialogue.
- Hand the resulting brief to **`/ac:research`** (search-first) or **`/ac:ship`** (build it).
- Pairs with **`/sc:design`** when the brief needs an architecture shape next.

## Output

A short requirements brief: goal, constraints, open questions, and the recommended next
command.
