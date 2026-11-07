---
name: plan-execution
description: Execute an approved plan or explicit scoped request through dependency-aware tasks and verified evidence. Use for implementation handoffs; do not use to redesign plans, conduct open-ended research, or create commits and pushes without explicit authorization.
---

# Plan Execution

## Trigger

Use when an approved plan or a clear implementation request is ready to execute.

## Non-trigger

Do not activate to invent product requirements, rewrite a plan silently, perform read-only research or review, or deliver through Git when the user has not authorized it.

## Workflow

1. Read the plan or request, project instructions, working state, dependencies, and acceptance criteria. A new plan run must have `status: approved` and no unresolved user-owned blocker, then transition it to `in_progress` before implementation. Create or resume the plan's [run state](references/run-state.md) before the first task, exactly as that reference lays it out: `state.json` written at creation and kept current, `notepad.md` for learnings handed to later tasks, one JSON event per line in `ledger.jsonl` for every check and task transition — no other file name or format — and captured output under `evidence/`. The orchestrating session is its only writer; resume an interrupted `in_progress` or resolved `blocked` plan from its task states, run state, and evidence, and never replay completed tasks blindly. When the plan carries `spec:`, treat the spec's requirements, success criteria, and preserved behavior as acceptance criteria and move the spec `approved → in_progress`.
2. Build a dependency graph and declare each task's write set before dispatch. Parallelize only disjoint write sets; serialize output-dependent work and exclusive surfaces such as lockfiles, manifests, generated outputs, settings, plans, or any file shared by multiple tasks.
3. Implement dependent tasks in the orchestrating session. Dispatch a leaf worker only for parallel tasks with disjoint write sets or one large mechanical task, and give it one self-contained task following [the task contract](references/task-contract.md).
4. Prefer existing code, standard or platform behavior, and installed dependencies before custom code. Make the minimum correct change at the owning layer and follow local conventions.
5. Bound recovery: after a concrete failure, diagnose and retry with the evidence; do not stack speculative patches or expand scope. Escalate unresolved ambiguity rather than redesigning the plan. When the code cannot satisfy a linked spec as written, append the deviation to the spec's `## Deviations` section and ask; never rewrite a requirement to fit the code.
6. When the plan sets `commits: per-task` or `per-phase`, commit each verified task or phase under the work-planning plan contract's "Commit strategy"; with `none` or no plan, leave changes uncommitted. Inspect changed state yourself and record results with [the evidence contract](references/evidence-contract.md) as ledger events, appending workers' reported learnings to the notepad. Run risk-based independent review where required.
7. Complete the plan's final verification on the stable delivered state. Mark the plan `completed` only after it passes; mark it `blocked` when a required unresolved condition stops progress. On completion of a spec-linked plan, mark the spec `shipped`, merge its deltas into the living spec, and archive the change directory as described in the work-planning spec contract. Beyond the plan's commit strategy, do not commit, push, open a PR, merge, deploy, or alter shared state unless explicitly authorized.

Load [implementation guidance](references/implementation.md) or [testing guidance](references/testing.md) only when that detail is needed.
