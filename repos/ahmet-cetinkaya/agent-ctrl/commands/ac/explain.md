---
name: ac:explain
description: "Explain code, a concept, or system behavior with educational clarity. Minimal hub over /sc:explain; complements /ac:explore (which gathers context, not explanations)."
category: workflow
complexity: standard
mcp-servers: []
personas: [learning-guide]
---

# `/ac:explain` - Explain Code or Concepts

Minimal hub. Delegates to **`/sc:explain`** for clear, educational explanations of code,
concepts, or system behavior — distinct from `/ac:explore`, which *gathers* context rather
than explaining it.

## Usage

```bash
/ac:explain [target or question]   # a file, symbol, error, or concept
```

## Workflow

1. **Locate** — identify the code/concept in scope (optionally via `/ac:explore` first).
2. **Explain** — break it down at the right level for the audience.
3. **Illustrate** — concrete examples, edge cases, and "why it works this way".

## Delegation

- Runs **`/sc:explain`** for the explanation.
- For finding the relevant files first, use **`/ac:explore`**.
- For up-to-date library/API specifics, the `docs-lookup` agent / Context7 MCP.

## Output

A clear, layered explanation with examples tuned to the asked level.
