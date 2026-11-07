# Run State

Runtime state makes a plan run resumable after compaction or a new session and keeps an audit trail of what was proven. The plan file stays the source of truth for status and task states; the rest of the work item directory holds only what the plan does not.

## Layout

```text
.agents/work/<id>/
├── plan.md             # planned work only
├── plan.explain.html   # when written
├── state.json      # resume pointer and review receipts
├── notepad.md      # append-only learnings handed to later tasks
├── ledger.jsonl    # one event per line
├── evidence/       # captured raw output: logs, responses, screenshots
└── reports/        # verification and code-review records that cite evidence/
```

Every `.agents/` path in this contract, including the legacy check, resolves against the project root: the directory that holds `.agents/` and `specs/`.

`<id>` is the plan slug (`<slug>`) for planned work, so the plan is `.agents/work/<slug>/plan.md`. Work without a plan file (a direct request, `/ac:fix`, or a plan-less `/ac:verify` or `/ac:review`) uses `<YYYYMMDD>-<scope-slug>`, so the item is `.agents/work/<YYYYMMDD>-<scope-slug>/`. An item is planned if and only if it contains `plan.md`. A plan slug must not start with an eight-digit date followed by `-`, and must not already exist under `.agents/work/` or `.agents/archive/*/`; the planner picks another slug on a collision. Same-day plan-less reruns reuse their directory.

`<stamp>` is the UTC write time in `YYYYMMDDTHHMMSSZ` form. Report names carry the full time so a second run on the same day never overwrites the first, and the form has no colons so it is a safe file name on every platform.

Only the orchestrating agent writes state: the session running `/ac:plan` when it creates a work item, the main session during a `/ac:run` run, the executor during a verification, the main session during a plan review, a code review, a user-requested migration, or when the user approves a plan, the `/ac:doc` session when it writes `plan.explain.html`, and the `/ac:pr` session during its archive sweep. Workers never write it; they return findings and evidence, and the orchestrator records them. This keeps parallel workers from conflicting on shared files.

Runtime state is local and never committed. Before the first write to a work item, check `git check-ignore -q .agents/work/`; when it is not ignored, say so once and recommend adding `.agents/work/` and `.agents/archive/` to `.gitignore`, not `.agents/`, because `.agents/skills/` is committed in some runtimes. Do not edit `.gitignore` unasked.

## `state.json`

```json
{
  "plan": ".agents/work/<slug>/plan.md",
  "branch": "<git branch --show-current>",
  "started_at": "<ISO-8601>",
  "updated_at": "<ISO-8601>",
  "active_tasks": ["<task id>"],
  "review": {
    "round": 1,
    "plan_sha256": "<sha256 of the reviewed plan bytes>",
    "lanes": {
      "executability": { "verdict": "<verdict>", "at": "<ISO-8601>" },
      "adversarial": { "verdict": "<verdict>", "at": "<ISO-8601>" }
    }
  }
}
```

`plan` is omitted for plan-less work, except an item that plan-reviews, verifies, or code-reviews archived work, which records `.agents/archive/<YYYY>/<id>/plan.md`. `branch` is omitted on a detached HEAD.

Whoever creates a work item's directory writes its initial `state.json` at that moment, with `started_at`, `updated_at`, `branch`, `active_tasks`, and (for planned work) `plan`: the session running `/ac:plan` beside `plan.md`, the orchestrating session for plan-less work. An orchestrator that finds a work item without `state.json` creates it with the current branch. At run start and resume, the session running `/ac:run` sets `branch` to the current branch when it is missing or different, with no ledger event. Every write to a work item, other than the archive move, also sets its `state.json` `updated_at` to the write time. A plan-less item lists its in-flight work in `active_tasks` from creation and empties it when that work ends; a missing `active_tasks` counts as not finished.

A recorded `.agents/work/<id>/plan.md` that no longer exists resolves to `.agents/archive/*/<id>/plan.md`. Archive moves never rewrite file contents.

On start, an existing `state.json` for an `in_progress` or resolved `blocked` plan is a resume: read it, the plan's task states, the notepad, and the ledger tail, then continue from the first unfinished task. Never replay completed tasks. When state and plan disagree, the plan wins and the disagreement is recorded as a ledger event.

## `notepad.md`

Append-only; never rewrite earlier entries. Each entry is headed `## <ISO-8601> Task <id>` and filed under one of: Learnings (conventions, patterns), Decisions (choices made during execution), Issues (gotchas and workarounds), Problems (unresolved blockers). Read it once before each batch and pass the relevant entries to workers as inherited context.

## `ledger.jsonl`

One JSON object per line, appended as events happen:

```text
{"at": "<ISO-8601>", "event": "check", "task": "3", "check": "unit tests", "status": "PASS", "command": "<exact command>", "observable": "<what proved it>", "artifact": "evidence/<file>"}
```

Events: `run_started`, `run_resumed`, `task_started`, `check`, `task_completed`, `task_blocked`, `plan_review`, `code_review`, `final_verification`, `run_completed`. Ledgers written before this split use `review` for a plan review; read it as `plan_review`. Statuses follow the evidence contract. A task is `completed` in the plan only after its `task_completed` event cites passing checks; under a commit strategy that event also carries `commit` (hash) and `message`.

## Evidence records

Capture real output — command logs, HTTP responses, screenshots, data readbacks — under `evidence/`. Records that summarize a verification or a code review go under `reports/` and cite the raw files in `evidence/`. A verification writes `reports/<stamp>-verify.md` with one section per gate or criterion:

- **Tested** — the exact command or action and the surface it drove.
- **Observed** — the actual observable and the artifact path holding the raw output.
- **Why enough** — how this covers the intended behavior and what regression risk remains.
- **Omitted** — anything redacted or summarized.

A code review writes `reports/<stamp>-code-review.md`: the target and reviewed revision, the verdict, areas reviewed, findings in the report format, and evidence gaps.

Never store secrets: redact tokens, credentials, auth headers, private keys, and secret-bearing environment dumps before writing, and summarize instead of copying when redaction is not reliable. An evidence record describes checks that ran; it never stands in for one that did not.

## Archive

Finished work moves from `.agents/work/<id>/` to `.agents/archive/<YYYY>/<id>/`, where `<YYYY>` is the UTC year of the move.

- Only finished items are archived: a planned item whose plan is `completed`, or a plan-less item whose `state.json` `active_tasks` is empty. A `draft`, `approved`, `in_progress`, or `blocked` plan is never archived.
- The automatic sweep also requires that the item's work PR is merged. It never archives an item whose PR is open or closed without merge, or that has no `branch` or no PR; those are archived only by hand, on user request.
- [`/ac:pr`](../../../commands/ac/pr.md) owns the sweep and runs it at its start. For each distinct `branch` among finished items it runs one standalone call, `gh pr list --head '<branch>' --author '@me' --state merged --json number,mergedAt`. An item is archived only if a returned PR has `mergedAt` later than the item's `updated_at`, compared as UTC instants; this guards against a reused branch name. The executor refreshes `updated_at` at the end of the run. `--author '@me'` guards against another author's PR with the same head branch name; such an item is archived by hand.
- Use a `branch` value only if it matches `^[A-Za-z0-9._/-]+$`, and pass it single-quoted. Otherwise skip the item and report it as `unsafe branch name`.
- The orchestrating agent performs the move. Skip and report it when `git check-ignore -q .agents/archive/` fails or when `.agents/archive/<YYYY>/<id>/` already exists. Never merge into or overwrite an archive.
- Archived items are never edited. A later plan review, verification, or code review of archived work starts a new plan-less item, whose `plan` points at the archived plan.
- Known gap: merged work stays in `.agents/work/` until the next `/ac:pr` run or a manual archive. An item with any state write after its PR merged (for example a later `/ac:verify`) is skipped by every later sweep and is archived by hand.

## Migrating from the legacy layout

The catalog never uses the layout that kept plans in `.agents/plans/` and run state in `.agents/state/`; only the legacy check below looks into it, to list what it finds, and it never migrates on its own.

**Legacy check.** Every command or agent that discovers plans, or reads or creates run state, runs this first. If `.agents/plans/` or `.agents/state/` exists, read only the names and `status:` lines of the legacy items, and stop before any other read or write of plans or run state. Name each legacy item found, flagging every plan whose `status:` is `in_progress` or `blocked`, and point the user to these steps.

**Migration steps.** Perform them only when the user asks; there is no script.

1. Move `.agents/plans/<slug>.md` to `.agents/work/<slug>/plan.md`.
2. Move `.agents/plans/<slug>.explain.html` to `.agents/work/<slug>/plan.explain.html`.
3. Move `.agents/state/<id>/*` to `.agents/work/<id>/` (planned and plan-less ids alike).
4. Rewrite `state.json` `plan` and any spec frontmatter `plan:` that points at the old path to the new `.agents/work/<slug>/plan.md`.
5. Move report files and ledger lines as they are; never rewrite them. Legacy `review` ledger events keep being read as `plan_review`.
6. A finished legacy item (plan `completed`, or plan-less with empty `active_tasks`; a migrated plan-less item without `active_tasks` counts as finished only after the user says so, and the migrating session then sets `active_tasks: []`) may go straight to `.agents/archive/<YYYY>/<id>/` under the Archive move rules, without the merge condition.
7. Files in `.agents/plans/` without `status:` frontmatter are not ac plans (for example Claude Code native plan-mode files from the old `plansDirectory` setting). List them; the user decides whether to delete or move them.
8. Remove the empty legacy directories. The check keeps stopping until both are gone.
