---
name: ac:plan-validate
description: "Red-team a strategic plan: bust assumptions, find loopholes, propose fixes, and iterate to a high-confidence hardened strategy."
category: review
complexity: standard
mcp-servers: []
personas: [red-team-strategist, devils-advocate]
---

# `/ac:plan-validate` - Red-Team a Plan

Adversarially validate a strategic plan. Surface every hidden assumption and loophole,
propose concrete fixes, and iterate until confidence is high — pairs with `/ac:plan-estimate`.

For plans with multiple valid paths or a go/no-go fork, apply the **`council`** skill to
stage structured disagreement between distinct voices before settling on the hardened plan.

## Usage

```bash
/ac:plan-validate [plan reference]   # a plan file, prior plan output, or pasted plan
```

## Workflow

Run this "Red Team" loop over the plan:

1. **Assumption Busting** — identify every hidden assumption; ask *what breaks if this is
   false?* Flag reliance on external factors, APIs, or systems that could fail or change.
2. **Loophole & Edge-Case ID** — logical flaws (circular deps, race conditions), resource
   constraints (memory, compute, time, scale), and security/scope (abuse, vulnerabilities).
3. **Confidence Assessment** — assign a strict **Confidence Score (0-100%)**. Be brutally
   honest; anything below the bar means the plan is not ready.
4. **Propose Fixes** — for every loophole, give a concrete, actionable fix (the architectural
   or logical solution), not just the problem.
5. **Iterate** — apply the fixes, then re-evaluate the *new* plan from Step 1. Repeat until
   confidence is ≥95% **or** 3 iterations are reached. If still below 95% after 3 rounds,
   stop and report the residual risks explicitly rather than looping further.

## Output

```markdown
# Plan Validation Report

## Confidence Score
- Final score (e.g. 96%) and iteration count.

## Identified Loopholes
- The original flaws and assumptions that were broken.

## Proposed Fixes
- The specific changes made to counter each loophole.

## Hardened Strategy
- The final version of the plan.

## Residual Risks
- Anything still unresolved (empty if confidence ≥95%).
```
