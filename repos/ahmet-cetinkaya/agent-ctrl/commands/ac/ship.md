---
name: ac:ship
description: "End-to-end eval-driven feature flow: define completion criteria, research, implement, verify, and review. The orchestrated 'do it right' path that chains the other /ac: commands with /sc:* and /ecc:*."
category: orchestration
complexity: advanced
mcp-servers: [serena, codegraph, context7, parallel-search]
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
4. **Implement** — `/ac:implement` (→ **`/sc:implement`**, or **`/ecc:feature-dev`**), decomposed into 15-minute units; before code generation, follow `rules/minimal-engineering.md`'s decision ladder and target the smallest diff that passes the up-front evals. Design first with `/sc:design` when the interface isn't obvious.
5. **Verify** — `/ac:verify` runs the six-phase gate (stack-aware via profile skills).
6. **Review** — `/ac:review` for clean-code/security/architecture findings.
7. **PR** — `/ac:pr` to open a draft Pull Request once verified and reviewed.
8. **Learn** — `/ac:learn` to capture what worked as reusable instincts.

Done only when the up-front evals pass and `/ac:verify` reports **READY**.

## Delegation Map

| Step | Delegates to | MCP |
|------|--------------|-----|
| Research | `/ac:research` → `/sc:research`, `deep-research` | `context7`, `parallel-search` |
| Context | `/ac:explore` → `serena`, `codegraph`, `Explore` agent | `serena`, `codegraph` |
| Design | `/sc:design` (architecture/API/component specs before implementing) | — |
| Implement | `/ac:implement` → `/sc:implement` (or `/ecc:feature-dev`) | `serena`, `context7` |
| Verify | `/ac:verify` → active profile verification skill | `serena` |
| Review | `/ac:review` → `/ecc:*` reviewer agents | `serena`, `codegraph` |
| PR | `/ac:pr` | — |
| Learn | `/ac:learn` — capture what worked as reusable instincts | — |

The MCP servers are inherited through the delegated commands (each `/ac:*` step declares its
own); they are listed here so the orchestrator loads them once for the whole flow.

Throughout the flow, apply the **`safety-guard`** skill before any destructive or
production-touching operation — this orchestrator runs many steps autonomously.
