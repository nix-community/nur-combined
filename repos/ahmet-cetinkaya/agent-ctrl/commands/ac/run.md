---
name: ac:run
description: Execute an approved plan (or resume an in-progress one), or an already-clear scoped request, end to end in the main session — workers only for parallel task batches — with per-task verification and final gates.
---

# `/ac:run` — Execute a Plan or Scoped Request

Carries an approved plan through to completion with per-task verification. The plan is the contract; execution does not redesign it. A request that is already clear runs the same way without a plan file.

## Usage

```
/ac:run [plan-slug]        # omit to auto-select when exactly one plan is eligible
/ac:run <scoped request>   # implement an already-clear change without a plan file
```

## Workflow

Activate `plan-execution` and run the plan or request yourself, in this session: dependent tasks build on each other's output, so they keep one context and no handoff. Dispatch a `worker` only for a batch of two or more ready tasks with disjoint declared write sets, or for one large mechanical task whose output would flood this context. Do not route the run to `executor`.

Run the [legacy check](../../skills/plan-execution/references/run-state.md#migrating-from-the-legacy-layout) before any plan or run-state access.

### 1. Select and gate the input

After the legacy check passes, the argument is a plan when it equals a slug with `.agents/work/<slug>/plan.md` present, or is a path to such a file. A slug for which `.agents/archive/*/<slug>/plan.md` exists, or a path to such a file, is rejected as `completed` and makes no write — never a direct request. Anything else is a direct request.

**Plan.** If several are eligible and none was named, ask. Start only from `status: approved`; resume `in_progress`, or `blocked` after its blocker is resolved. Reject draft, completed, ambiguous, or still-blocked plans.

**Direct request.** Accept it only when the target files or area, the expected behavior, and the acceptance conditions are already known or settled by the repository. State those three before the first edit; they are the contract in place of a plan. Send broken behavior to `/ac:fix`, and anything ambiguous, multi-step with open decisions, or crossing a risk boundary to `/ac:plan` instead of guessing.

If the plan carries `spec:`, read that spec and move it `approved → in_progress` when execution starts. The spec's requirements and preserved behavior are part of the contract alongside the plan's tasks.

### 2. Execute task by task

Create or resume the run state in `.agents/work/<id>/` before the first dispatch; a resumed run continues from its recorded state and never replays completed tasks. Turn the plan's tasks into a dependency graph. A task is `in_progress` only while it is genuinely executing; parallelize independent tasks only when their write surfaces do not conflict. Delegate only to `worker`, `explorer`, `researcher`, and `advisor`, following the acyclic graph — never `planner` or `executor`.

Each delegation carries the task goal verbatim, allowed files, inherited decisions, acceptance criteria, required evidence, and exclusions.

### 3. Verify each result

Inspect every changed file and verify the evidence before marking a task `completed` — a worker's summary is not proof. Record checks as `PASS`, `FAIL`, `BLOCKED`, or `NOT_APPLICABLE` with command, scope, and observable, as ledger events with captured output under the run's `evidence/`. Security, auth, sensitive data, schema or migrations, shared APIs, CI, and critical user-facing changes require an independent `advisor` review of the task's diff, read-only and in a fresh context, before the task is `completed`.

### 4. Finish or stop honestly

Run the plan's final verification pass against the delivered state. If the plan is wrong or a required decision is unresolved, report the blocker — do not substitute a design. Update task states in the plan file as they change. When this session implemented any task, report the run as `completed — self-verified`: the independent readiness gate is then `/ac:verify`, required before `/ac:pr`.

When implementation cannot follow a linked spec as written, do not change the requirement silently: append the deviation and its reason to the spec's `## Deviations` section, ask the user, and continue only with their decision. Dropping or moving a requirement follows the spec contract's Descoping rule. After final verification passes, move the spec to `shipped`, merge its deltas into the living spec under `specs/<capability>/SPEC.md`, and move the change directory under `specs/changes/archive/`.

## Output

Per-task status with evidence and commit hashes when committed, the final verification verdict, the run-state path, and any blockers or follow-ups.

## Next Step

Close the turn by mapping the execution outcome to one command:

- All tasks complete, evidence green → `/ac:verify` for the independent readiness gate
- A gate failed or a defect surfaced → `/ac:fix <symptom>`
- The change crosses a risk boundary and needs an independent pass → `/ac:review`
- Blocked on a plan defect or owner-decision → state the blocker and stop

After a clean verify, the delivery path is `/ac:pr`; with `commits: none`, commit first through the `git-workflow` skill's COMMIT mode on request. Never push or open a PR without explicit authorization.

## Boundaries

- Do not start from a draft plan or silently redesign an approved one.
- Do not run a direct request whose scope or acceptance conditions are unclear; route it to `/ac:plan`.
- Do not rewrite a spec's requirements to match the code; record deviations and ask.
- Commit only as the approved plan's `commits` strategy allows; a direct request without a plan never commits. Do not push, create branches, open a PR, merge, deploy, or alter shared state without explicit authorization.
