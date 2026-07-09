---
name: ac:research
description: "Research existing tools, libraries, and patterns before writing code. Applies the search-first technique and outputs an Adopt/Extend/Compose/Build recommendation."
category: workflow
complexity: standard
mcp-servers: [context7, parallel-search, serena, graphify]
personas: [deep-research, architect]
---

# `/ac:research` - Research Before You Code

Applies the **`search-first`** skill: never write custom code for a solved problem.

## Usage

```bash
/ac:research [need or feature description]
```

## Workflow

1. **Repo first** — search the current codebase for an existing implementation: `serena`
   (`find_symbol`, `find_referencing_symbols`) for symbol-level lookup, and — when a
   knowledge graph exists (`/ac:index`) — `graphify` to see what already depends on the area.
2. **External search** — npm/PyPI, `context7` for library docs, `parallel-search` for the
   web, plus installed skills and GitHub.
3. **Evaluate** — functionality fit, maintenance, community, docs, license, dependency weight.
4. **Decide** — Adopt / Extend / Compose / Build (see the `search-first` skill's decision matrix).

## Delegation

- For deep multi-source investigation, delegate to **`/sc:research`** or the **`deep-research`** agent.
- When the decision is **Build/Compose** and needs an architecture/API shape, hand off to **`/sc:design`** before implementing.
- Hand the chosen approach to **`/sc:implement`** or **`/ac:ship`**.
- Pairs with the **`iterative-retrieval`** skill (via `/ac:explore`) for in-repo candidate discovery.

## Output

A short recommendation: the decision (Adopt/Extend/Compose/Build), the chosen tool/approach, and why.
