---
name: ac:ship
description: "End-to-end eval-driven feature flow: define completion criteria, research, implement, verify, and review. The orchestrated 'do it right' path that chains the other /ac: commands with /sc:* and /ecc:*."
category: orchestration
complexity: advanced
mcp-servers: [serena, graphify, context7, parallel-search]
personas: [architect, code-reviewer, quality-engineer]
---

# `/ac:ship` - Eval-Driven Feature Flow

The flagship orchestrator. Applies **`eval-harness`** / **`agentic-engineering`** (define done first),
then chains research → explore → implement → verify → review.

## Usage

```bash
/ac:ship [feature description]
```

## Flow

1. **Define done** — Write capability + regression evals up front (`eval-harness` skill). These are the gate.
2. **Research** — `/ac:research` to avoid reinventing existing solutions.
3. **Explore** — `/ac:explore` to gather minimal high-relevance context.
4. **Implement** — `/ac:implement` (→ **`/sc:implement`**, or **`/ecc:feature-dev`**), decomposed into 15-minute units. Design first with `/sc:design` when the interface isn't obvious.
5. **Verify** — `/ac:verify` runs the six-phase gate (stack-aware via profile skills).
6. **Review** — `/ac:review` for clean-code/security/architecture findings.

Done only when the up-front evals pass and `/ac:verify` reports **READY**.

## Delegation Map

| Step | Delegates to | MCP |
|------|--------------|-----|
| Research | `/ac:research` → `/sc:research`, `deep-research` | `context7`, `parallel-search` |
| Context | `/ac:explore` → `serena`, `Explore` agent | `serena`, `graphify` |
| Design | `/sc:design` (architecture/API/component specs before implementing) | — |
| Implement | `/ac:implement` → `/sc:implement` (or `/ecc:feature-dev`) | `serena`, `context7` |
| Verify | `/ac:verify` → profile verification skill, `/ecc:*-build` | `serena` |
| Review | `/ac:review` → `/ecc:*` reviewer agents | `serena`, `graphify` |
| PR | `/ac:pr` | — |
| Learn | `/ac:learn` — capture what worked as reusable instincts | — |

The MCP servers are inherited through the delegated commands (each `/ac:*` step declares its
own); they are listed here so the orchestrator loads them once for the whole flow.
