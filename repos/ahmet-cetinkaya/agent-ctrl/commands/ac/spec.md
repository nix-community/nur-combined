---
name: ac:spec
description: Write or refine one behavior spec (what and why, never how) under specs/changes before any plan. Re-running on an existing spec asks targeted clarifying questions; --checklist writes a requirements-quality checklist for one domain. Only explicit approval makes a spec plannable.
---

# `/ac:spec` — Specify Behavior

Captures the intended behavior of one change as a testable spec that the user approves before design begins. The spec is the contract for `/ac:plan`; no product code, no plan, and no technology decisions are written here.

## Usage

```
/ac:spec <intent>                 # new change: write specs/changes/<NNNN>-<slug>/SPEC.md
/ac:spec <spec-path>              # existing draft: clarify and refine it in place
/ac:spec <intent> --capability <name>   # target an existing living spec as a delta
/ac:spec <spec-path> --checklist <domain>   # requirements-quality checklist for one domain
```

## Workflow

Activate `work-planning` in **Spec First** mode and `technical-writing` for the spec prose, and route the request to `planner`.

### 1. Repository before questions

Read the project's instruction files and any living spec under `specs/` for the affected capability. Delegate discovery of current behavior, vocabulary, and constraints to `explorer`; use `researcher` only when an external product or API fact materially shapes the requirements. An existing convention beats a question every time.

### 2. Settle the direction before writing

Write no file until the direction is clear. When the intent arrives as a solution ("add X"), ask what problem it solves and for whom, and restate it as the outcome that matters. When several product directions are plausible, present two to four distinct alternatives with benefits, costs, risks, and reversibility, recommend one, and let the user choose; use `advisor` for a genuine high-impact tradeoff. Ask one focused question at a time and stop as soon as the intent can be specified. If the idea does not survive this step, say so and create nothing.

### 3. Write the change spec

Create `specs/changes/<NNNN>-<slug>/SPEC.md` following the spec contract: intent, prioritized user stories with a priority reason, an independent test, and Given/When/Then scenarios, `FR-###` requirements in EARS form, the user experience (or `none — no user interface`), key entities when data is involved, measurable `SC-###` success criteria, edge cases, assumptions, and out-of-scope boundaries. If no user flow can be identified, stop and say so instead of writing a spec. `<NNNN>` is the next unused number across `specs/changes/` and its archive; `<slug>` is two to four kebab-case words.

When the change alters an existing capability, write the requirements as `ADDED`, `MODIFIED`, and `REMOVED` deltas against the living spec and add at least two `PRESERVED` statements naming behavior that must keep working.

Adopt defensible defaults and record them under Assumptions. Mark only what a default cannot settle with `[NEEDS CLARIFICATION: …]`, at most three.

### 4. Self-check

Run the requirements checklist and the hostile-reader pass from the spec quality reference, fixing findings in place for at most three rounds, and write the result to `checklists/requirements.md` beside the spec. When the spec breaks the spec contract's Size rule, recommend the split with the surviving questions; a declined split is recorded under Out of scope. Then ask the surviving questions — at most three, all in one message, in the reference's question format — fold the answers into the spec, and re-evaluate the checklist.

### 5. Refine an existing spec

When given a spec path, follow the spec quality reference's refinement protocol: rate the coverage taxonomy, ask at most five questions one at a time for `Partial` or `Missing` areas, write each answer into the owning section and the `## Clarifications` log immediately, list unresolved high-impact areas as Deferred, and re-evaluate `checklists/requirements.md`. A spec that is `approved` or later is not refined in place; new behavior is a new change, and removing scope follows the spec contract's Descoping rule.

### 6. Domain checklist on request

With `--checklist <domain>`, write or extend `checklists/<domain>.md` beside the spec following the spec checklist reference: questions that test the requirements text, never the implementation, left unchecked for the reviewer. Do not change the spec in this mode.

### 7. Leave it as a draft

The spec keeps `status: draft`. Say plainly that only explicit user approval changes it to `approved`, and that approval covers the intent, not the risky operations a later plan may propose.

## Output

The spec path, the user stories with their priorities, the count of requirements and success criteria, adopted assumptions, the requirements checklist result (passing count, failing items), any open `[NEEDS CLARIFICATION]` markers, and, after a refinement, the questions answered and any Deferred areas.

## Next Step

Close the turn with the spec path and the recommended next command:

- Markers, failing checklist items, or `Partial` areas remain → answer them, or `/ac:spec <spec-path>` to refine
- The spec touches a high-risk domain (security, privacy, data, accessibility) and needs a reviewer pass → `/ac:spec <spec-path> --checklist <domain>`
- Spec is complete and you agree with it → approve it, then `/ac:plan <spec-path>`
- A solution or library choice blocks the intent → `/ac:research <question>` first
- The direction could not be settled → state the blocking owner-decision and stop

When the spec is large or hard to review from the file alone, also offer `/ac:doc <spec-path> --type explainer` for a readable HTML view before approval. Offer it; do not generate it unasked.

Name exactly one recommendation. Never chain commands automatically.

## Boundaries

- Do not write product code, a plan, or technology choices; the plan owns the how.
- Do not edit a spec under `specs/changes/archive/` or a living spec under `specs/`; new behavior is a new change.
- Do not approve the spec or move it past `draft`; only the user does.
- Do not commit or push.
