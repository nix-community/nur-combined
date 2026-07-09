---
name: ac:explore
description: "Progressively gather the minimal high-relevance context for a task using the iterative-retrieval technique, then hand the curated file set to implementation."
category: workflow
complexity: standard
mcp-servers: [serena, graphify]
personas: [repo-index, architect]
---

# `/ac:explore` - Progressive Context Gathering

Applies the **`iterative-retrieval`** skill to solve the subagent context problem: find the few files
that actually matter before implementing, without overflowing context.

## Usage

```bash
/ac:explore [task description]
```

## Workflow (max 3 cycles)

1. **DISPATCH** — Broad keyword + glob search via Serena MCP / the `Explore` agent. When a
   knowledge graph exists (`/ac:index`), query **`graphify`** for god nodes and shortest
   paths to seed the retrieval with the structurally central files.
2. **EVALUATE** — Score each file's relevance (0–1) to the task; note missing context.
3. **REFINE** — Add discovered terminology/patterns, exclude irrelevant paths, target the gaps.
4. **LOOP** — Stop at ≥3 high-relevance files with no critical gaps, or after 3 cycles.

## Delegation

- Uses **`serena`** MCP (`find_symbol`, `find_referencing_symbols`) for symbol-level
  retrieval and **`graphify`** for architecture-level navigation (dependencies, god nodes,
  shortest paths), with the **`Explore`** subagent as the retrieval engine.
- Hands the curated context to **`/sc:implement`** or **`/ac:ship`**.
- Run **`/ac:research`** first when the task may already be solved externally.

## Output

A ranked list of high-relevance files with one-line reasons, ready to pass into implementation.
