---
name: ac:plan
description: Create one decision-complete plan under .agents/work without implementing it. Interviews only for what the repository cannot answer.
---

# `/ac:plan` — Plan Work

Turns an underspecified request into one decision-complete plan file that an executor can carry out without follow-up questions. No product code is written.

## Usage

```
/ac:plan <request>
/ac:plan <spec-path>       # derive the plan from an approved spec
```

## Workflow

Activate `work-planning` and `technical-writing` for the plan prose, and write the plan yourself, in this session: discovery, the interview, and the plan build on each other, and only this session can ask the user directly — subagents have no question tool. Do not route the request to `planner`.

Run the [legacy check](../../skills/plan-execution/references/run-state.md#migrating-from-the-legacy-layout) before any plan or run-state access.

### 1. Repository before questions

Inspect project instructions, existing patterns, configs, and conventions first. An existing convention beats a question every time. Delegate internal discovery to `explorer` and external contracts to `researcher`; route genuine architecture tradeoffs to `advisor`.

### 2. Interview only for what evidence cannot settle

Ask about scope boundaries, intended behavior the code cannot reveal, constraints, and the definition of done. Batch questions — three sharp questions in one message beat nine rounds of one. State inferable assumptions instead of asking about them.

### 3. Write exactly one plan

Write `.agents/work/<slug>/plan.md` with `status: draft`, containing: a human Summary first (written last), Goal, Context (paths and constraints found), Decisions (each resolved ambiguity), Scope in/out, numbered tasks with dependencies and per-task acceptance criteria, QA/evidence expectations, and final verification. Every task must be independently verifiable — if its acceptance criteria cannot be stated, it is not specified well enough yet.

Keep unresolved user-owned decisions as explicit blockers inside the plan.

**Delivery shape.** After discovery, recommend phased delivery only when both hold: the review scope, coupling, risk, or context needed make the total PR not meaningfully reviewable, and coherent phases exist that can each be scoped, tested, and reviewed as their own PR into an umbrella branch. Use no fixed file or line thresholds. Ask the user to choose, and record the choice (or a blocker while undecided) in the same plan; if the user declines, record the concern and keep a single PR. Small or unsplittable work stays a single PR, and a clear small request gets no extra question. Phases group the existing numbered tasks inside the one plan; see the plan contract's "Phased delivery".

**Commit strategy.** Set `commits: none` for small single-PR work without asking. For a multi-task or phased plan, recommend `per-task` or `per-phase` with the other surviving questions and record the answer; see the plan contract's "Commit strategy".

### 4. Plan from a spec

When given a spec path, start only from a spec with `status: approved` and no open `[NEEDS CLARIFICATION]` marker — refuse a draft and point back to `/ac:spec`. Write the design artifacts whose condition holds — `research.md`, `data-model.md`, `contracts/` — beside the spec, and reference them from the plan instead of copying them. Record the path as `spec:` in the plan frontmatter, run the Constitution Check against the project's instruction files under Decisions, and add a **Traceability** table mapping every `FR-###`, `SC-###`, and `PB-<n>` to the tasks and evidence that prove it. A criterion with no task is a planning gap; a task with no criterion needs a stated reason.

### 5. Gap analysis and review gate

Before presenting the draft, run the skill's gap analysis and fold the findings in. When the user asked for high accuracy or a deep review, or a non-trivial plan rests on defaults adopted for a fuzzy outcome, run the `/ac:plan-review` review instead — its adversarial lane covers the gap analysis, so no separate gap-analysis session runs — and fix its blocking findings under that command's round cap before presenting. Otherwise the review stays an offer.

## Output

The plan path, its Summary, the task and phase count, anything added beyond the request with a one-line reason (or "none"), how completion will be verified, the review result when one ran, and any user-owned blockers awaiting an answer.

## Next Step

Close the turn with the plan path and the recommended next command:

- Plan is decision-complete and you want an adversarial pass first → `/ac:plan-review <plan-path>`
- Plan is ready to execute → approve it, then `/ac:run <plan-path>`
- Owner-decisions remain → list them and stop; the plan stays `status: draft`
- The request is really about intended behavior, not design → `/ac:spec <intent>` first

When the plan is hard to take in from the file alone — phased delivery, many cross-task dependencies, a large traceability table, or a risk boundary — also offer `/ac:doc <plan-path> --type explainer` for a readable HTML view before approval. Offer it; do not generate it unasked.

Say plainly that `/ac:run` requires explicit approval — writing the plan is not approval — and, when `commits` is not `none`, that approval also authorizes the listed local commits.

## Boundaries

- Do not edit product code, execute the plan, commit, or push. Approval of a plan with `commits: per-task` or `per-phase` authorizes only those local commits during execution. Do not create branches or PRs while planning; phased-delivery branches and PRs are proposals only.
- Only explicit user approval changes the plan to `status: approved`.
- Approval authorizes later execution of the plan, not the risky operations listed inside it — those still need their own authorization at execution time.
