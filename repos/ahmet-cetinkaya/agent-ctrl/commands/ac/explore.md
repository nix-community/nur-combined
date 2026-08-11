---
name: ac:explore
description: "Progressively gather the minimal high-relevance context for a task using the iterative-retrieval technique, then hand the curated file set to implementation."
category: workflow
complexity: standard
mcp-servers: [serena, codegraph]
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

1. **DISPATCH** — Broad keyword + glob search via Serena MCP / the `Explore` agent, plus
   `codegraph` for graph-backed source exploration when the entry symbols are known.
2. **EVALUATE** — Score each file's relevance (0–1) to the task; note missing context.
3. **REFINE** — Add discovered terminology/patterns, exclude irrelevant paths, target the gaps.
4. **LOOP** — Stop at ≥3 high-relevance files with no critical gaps, or after 3 cycles.

## Delegation

- Uses **`serena`** MCP (`find_symbol`, `find_referencing_symbols`) for symbol-level
  retrieval, with the **`Explore`** subagent as the retrieval engine.
- Uses **`codegraph`** MCP alongside Serena for graph-backed source exploration: it returns
  the verbatim source of the relevant symbols grouped by file, plus the call path between
  them and what depends on them. Prefer it over a grep/read loop when you can name the
  symbols or files involved. Requires `codegraph init` (see `/ac:index`).
- Hands the curated context to **`/sc:implement`** or **`/ac:ship`**.
- Run **`/ac:research`** first when the task may already be solved externally.

## Output

A ranked list of high-relevance files with one-line reasons, ready to pass into implementation.
