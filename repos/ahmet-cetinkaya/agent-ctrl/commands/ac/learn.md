---
name: ac:learn
description: "Review the session and capture reusable patterns as atomic, confidence-scored instincts using the continuous-learning technique. Offers to persist them to memory or a profile skill."
category: workflow
complexity: standard
mcp-servers: [serena]
personas: [repo-index]
---

# `/ac:learn` - Capture Patterns from the Session

Applies the **`continuous-learning-v2`** skill: turn what happened this session into reusable knowledge
as atomic "instincts" (one trigger, one action, confidence-scored, evidence-backed).

## Usage

```bash
/ac:learn
```

## Workflow

1. **Observe** — Review the session's prompts, corrections, and tool outcomes.
2. **Extract** — Form atomic instincts: trigger → action, tagged by domain (code-style, testing, git, workflow…).
3. **Score** — Assign confidence (0.3 tentative → 0.9 near-certain) with the supporting evidence.
4. **Scope** — Decide project-scoped vs global (universal patterns only).
5. **Persist** — Offer to save each instinct to project **`MEMORY.md`** (one fact per file), or evolve a
   cluster into a global/profile skill.

## Delegation

- Persists instincts to `MEMORY.md` and per-fact memory files; a mature cluster can graduate into a
  `skills/` or `profiles/<stack>/skills/` SKILL.md.
- Complements **`/ecc:learn`** / **`/ecc:learn-eval`** (ECC's instinct pipeline) and **`/sc:reflect`**.

## Output

A list of candidate instincts with confidence and evidence, plus a persistence recommendation.
