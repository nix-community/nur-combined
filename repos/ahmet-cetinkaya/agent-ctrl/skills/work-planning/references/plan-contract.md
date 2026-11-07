# Plan Contract

A durable plan under `.agents/work/<slug>/plan.md` contains frontmatter followed by the plan body:

```yaml
---
status: draft
spec: # optional: specs/changes/<NNNN>-<slug>/SPEC.md this plan implements
commits: none # none | per-task | per-phase; see Commit strategy
---
```

Valid lifecycle values are `draft`, `approved`, `in_progress`, `blocked`, and `completed`. `/ac:plan` writes `draft`. Only explicit user approval changes it to `approved`; approval does not authorize risky operations described inside the plan, except the local commits its commit strategy names. The session running `/ac:run` changes `approved → in_progress` before the first implementation task, `in_progress → blocked` when progress cannot continue, `blocked → in_progress` only after the blocker is resolved, and `in_progress → completed` only after final verification passes. An interrupted `in_progress` plan is resumed from its task states and evidence; it is not restarted blindly.

The plan body contains:

1. **Summary** — first in the file, written last so it describes the finished plan: what the user gets, why this approach, what it will not do, an effort band (Quick, Short, Medium, Large, or XL; never hours or days), the main risk, and the decisions made on the user's behalf.
2. **Goal** — outcome and reason.
3. **Context** — relevant paths, symbols, current behavior, conventions, and constraints.
4. **Decisions** — resolved alternatives, assumptions, and user-owned choices.
5. **Scope** — explicit in-scope and out-of-scope boundaries.
6. **Tasks** — numbered changes with exact files or discovery targets.
7. **Dependencies** — predecessor tasks and safe parallel groups.
8. **Per-task acceptance criteria** — observable proof for each task.
9. **QA and evidence** — project-defined checks, real-surface scenarios, risk gates, rollback evidence, and expected observables.
10. **Final verification** — checks over the complete delivered state, covering four dimensions: plan and spec compliance (every criterion has evidence), code quality, real-surface QA, and scope fidelity (nothing unrequested added, nothing requested missing).
11. **Traceability** — required when `spec:` is set: a table with one row per `FR-###`, `SC-###`, and `PB-<n>` from the spec, naming the task(s) that satisfy it and the evidence source that proves it. A criterion with no task is a planning gap, unless it is struck through as descoped and its row cites the move; a task with no criterion is unrequested work and needs a stated reason.

Plans are working documents that age with their run: recommend git-ignoring `.agents/work/` together with `.agents/archive/`, and keep durable design in the spec directory. Do not edit `.gitignore` unasked.

A plan derived from a spec writes its durable design beside the spec as [design artifacts](design-artifacts.md) — `research.md`, `data-model.md`, and `contracts/`, each only when its condition holds — and its Context names the ones written. It starts only from a spec with `status: approved` and no `[NEEDS CLARIFICATION]` marker; the plan's Decisions section records the Constitution Check — whether the design honors the project's instruction files (`AGENTS.md`, `CLAUDE.md`, or equivalent) and, for each conflict, the justification or the owner-decision it raises.

Task status is exactly `pending`, `in_progress`, `blocked`, or `completed`. Keep only genuinely executing work `in_progress`; mark completion only after its acceptance evidence passes. An unresolved user-owned decision keeps the plan `draft` and must appear under Decisions as a blocker.

## Phased delivery (when chosen)

Optional; use it only when the user chose it after the dual condition held: the total PR is not meaningfully reviewable given scope, coupling, risk, or context, and coherent phases exist that can each be scoped, tested, and reviewed as a PR. No fixed file or line thresholds apply. The plan stays one durable draft; phases group the existing numbered task IDs and add no separate plans, lifecycle states, or frontmatter.

Topology:

- The umbrella branch originates at the intended final target. The final umbrella PR has the umbrella branch as head and the final target as base.
- Each phase branch originates at its declared umbrella baseline; the phase head is the head of a PR whose base is the umbrella branch.
- Branch names follow repository conventions; do not invent PR identifiers.

Each phase records: outcome, scope, exclusions, task IDs, dependencies, order, acceptance criteria, test and QA evidence, branch origin and prerequisite baseline, and PR base and head. Details may reference tasks instead of repeating them.

Rules:

- Sequential phases branch only after their predecessors are integrated into the umbrella and verified. Independent phases may share a baseline only with no output dependency and no conflicting write surface.
- When the umbrella changes, affected phase branches are updated by the repository's approved process and their checks rerun.
- A phase must pass its checks on its baseline without any unfinished future phase. Independently reviewable does not mean independently deployable or mergeable to the main target.
- Preserve each phase's review evidence. Final umbrella verification covers every plan and spec criterion, cross-phase regressions, integration, and real-surface QA; phase checks do not replace it. The final umbrella review covers integration and remaining changes, yet the aggregate diff stays large. If the repository requires a fresh full-diff review of the final PR, state that the umbrella may not solve reviewability.
- Branch creation, PRs, pushes, and merges are proposals; neither planning nor plan approval authorizes them. Commits follow the commit strategy below.

## Commit strategy

The `commits` field decides whether execution commits. It defaults to `none`: execution leaves the changes uncommitted.

- `per-task` — one commit per verified task.
- `per-phase` — one commit per phase in phased delivery, after every task in the phase is verified.

Small single-PR work keeps `none` without a question. For a multi-task or phased plan, `/ac:plan` recommends a value and asks it together with the other surviving questions. A plan with `per-task` or `per-phase` carries a `## Commit strategy` section listing each commit's tasks, the files it stages, and a proposed message in the repository's own style.

Approving a plan with `per-task` or `per-phase` authorizes exactly those local commits on the current branch. It never authorizes branch creation, push, PR, merge, history rewrite, or amend; those stay separate user actions.

Execution rules:

- Only the session running `/ac:run` commits, and only after the task's or phase's checks pass. Workers never commit. Commits are serialized because parallel tasks share one git index.
- Stage by path the declared write set of the committed tasks only; never `git add -A` or `git add .`. Unrelated working-tree changes and the work directory under `.agents/work/` stay out of every commit. When a write-set file also holds unrelated changes that predate the run, stage only the task's hunks; when they cannot be separated, skip that commit and report it.
- Write the message with the `git-workflow` commit guidance: local style, no co-author or AI trailers. Use the plan's proposed message unless the delivered change makes it inaccurate.
- Never bypass hooks. A failing hook means the task is not complete: fix the cause, rerun the checks, and commit again.
- Record the commit hash and message on the task's `task_completed` ledger event.

Commands written in a plan are proposals, not authorization. The executing session must validate every command against project instructions, the current environment, and safety boundaries before running it.
