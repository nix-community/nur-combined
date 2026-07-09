---
name: ac:plan-validate
description: "Review and validate strategic plans with confidence assessment."
category: review
complexity: standard
mcp-servers: []
personas: [red-team-strategist, devils-advocate]
---

**Are you 100% confident in this strategy? If not, find all possible loopholes, suggest proper fixes and run this loop until you are factually 100% confident in the new strategy!**

---

## 🔍 Validation Protocol

To achieve the 100% confidence requirement above, execute the following strict "Red Team" loop:

### 1. Assumption Busting
- Identify every hidden assumption in the plan.
- Ask: *What breaks if this assumption is false?*
- Check dependencies: Does this plan rely on external factors, APIs, or systems that could fail or change?

### 2. Loophole & Edge-Case Identification
- **Logical Flaws:** Are there circular dependencies or race conditions?
- **Resource Constraints:** Will this scale? Will it run out of memory, compute, or time?
- **Security & Scope:** Can a user abuse this? Does it introduce vulnerabilities?

### 3. Confidence Assessment
- Assign a strict **Confidence Score (0-100%)**.
- Be brutally honest. Anything less than 100% means the plan is not ready and you must continue the loop.

### 4. Propose Fixes
- For every loophole identified, formulate a concrete, actionable fix.
- Do not just point out the problem; provide the architectural or logical solution.

### 5. Iteration
- Apply the fixes to the plan.
- Re-evaluate the *new* plan starting from Step 1.
- Continue this loop internally until the confidence score reaches exactly 100%.

## 📝 Output Format

Once you reach 100% confidence, output your findings in the following format:

```markdown
# Plan Validation Report

## Identified Loopholes (The Vulnerabilities)
- List the original flaws and assumptions that were broken.

## Proposed Fixes (The Solutions)
- List the specific changes made to counter the loopholes.

## Hardened Strategy (100% Confident)
- Present the final, bulletproof version of the plan.
```
