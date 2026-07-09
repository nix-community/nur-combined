---
name: ac:plan-estimate
description: "Estimate development effort/complexity for a task, feature, or project. Minimal hub over /sc:estimate; pairs with /ac:plan-validate and feeds /ac:ship sequencing."
category: workflow
complexity: standard
mcp-servers: []
personas: [architect, requirements-analyst]
---

# `/ac:plan-estimate` - Development Estimate

Minimal hub. Delegates to **`/sc:estimate`** for effort, complexity, and risk estimates on
a task, feature, or project.

## Usage

```bash
/ac:plan-estimate [task or feature description]
```

## Workflow

1. **Decompose** — break the work into units.
2. **Assess** — effort, complexity, unknowns, and risk per unit.
3. **Aggregate** — total estimate with confidence and the main risk drivers.

## Delegation

- Runs **`/sc:estimate`** for the analysis.
- Feed the estimate into **`/ac:ship`** (sequencing) or validate the surrounding plan with
  **`/ac:plan-validate`**.
- For unknowns that need investigation first, **`/ac:research`**.

## Output

An estimate with per-unit breakdown, confidence level, and the dominant risk/uncertainty
drivers.
