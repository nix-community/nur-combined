---
name: ac:context
description: "Audit context-window token consumption across loaded agents, skills, MCP servers, and rules; report bloat and prioritized token-savings recommendations."
category: utility
complexity: standard
mcp-servers: []
personas: [repo-index, architect]
---

# `/ac:context` - Context Budget Audit

Applies the **`context-budget`** skill. Run when a session feels sluggish, after adding many components,
or before adding more — to know your remaining headroom.

## Usage

```bash
/ac:context
```

## Workflow

1. **Inventory** — Estimate tokens (≈ words × 1.3) for agents, skills (`skills/` + `profiles/*/skills/`), rules, MCP servers, and the CLAUDE.md chain.
2. **Classify** — Always needed / Sometimes needed / Rarely needed.
3. **Recommend** — Prioritized trims with estimated savings: disable unused MCPs (`disabledMcpServers`), keep <10 MCPs and <80 tools, lazy-load niche skills, dedupe overlapping rules.

## Delegation

- Run before **`/ac:index`** on large repos to confirm headroom.
- Complements the **`strategic-compact`** technique (temporal/history) — this audit is structural (what's loaded).

## Output

A token-budget table per component class plus a ranked list of recommended trims.
