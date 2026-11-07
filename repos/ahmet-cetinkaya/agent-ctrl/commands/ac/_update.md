---
name: ac:_update
description: "TEMPORARY update command for the ac commands: moves an existing installation to the new .agents/work layout. Migrates legacy .agents layouts, backs up the live configuration, rehearses agent-ctrl apply in a private sandbox, then applies the updated catalog to the real home configuration after explicit confirmation. Remove it once every project is migrated."
---

# `/ac:_update` — Update the `ac` Commands (temporary)

> **Temporary update command.** This is not a workflow command. It exists only to move an existing installation of the `ac` commands to the new `.agents/work/` layout and to put the updated catalog live. Once every project is migrated and the catalog is applied, remove it (step 7).

Updates the installed `ac` commands in four stages: migrate legacy `.agents/` layouts, back up the live configuration, rehearse `agent-ctrl apply` in a private sandbox, then apply to the real home configuration. It is a one-off update: remove it when done (step 7).

It ships in the catalog, so it only exists in `~/.claude` after a first apply. Until then, apply once by hand (step 5 command, after the backup in step 3) and run this command afterwards to migrate and verify; every stage is safe to repeat.

## Usage

```
/ac:_update [project-path ...]
```

Without arguments it acts on the current project root, the directory that holds `.agents/` and `specs/`. Each extra path is another project whose legacy layout should be migrated.

## Rules

- Every step that writes stops first and asks. "Yes" to one step is never "yes" to the next.
- Never print, `cat`, or copy live or rendered settings: they hold `ANTHROPIC_AUTH_TOKEN`. Report only paths, counts, key names, and exit statuses.
- Never pass `--path` to a live apply (see README "Apply and inspect").
- Do not commit, push, open a PR, or edit any `.gitignore`.
- The shell keeps no variables between tool calls: run each sandbox sequence, from `mktemp -d` to its cleanup, in one invocation, with cleanup in a `trap ... EXIT`.
- Use `command grep` (the shell aliases `grep`) and `python3 -I` for Python.

## Steps

### 1. Preflight (read-only)

- `git status --short -- .`: report the count of modified and untracked files. Apply uses the working tree, not commits.
- `readlink -f ~/.agent-ctrl` must equal the project root; otherwise stop.
- `command grep -c '^## Migrating from the legacy layout$' skills/plan-execution/references/run-state.md` must print `1`; otherwise stop, because this is not the migrated catalog.
- `agent-ctrl agent ls .`, `agent-ctrl command ls .`, and `agent-ctrl skill ls .` must succeed; report the counts.
- Legacy scan of the project root and each extra path: list the entries of `.agents/plans/` and `.agents/state/`, reading only the `status:` line of each plan. Flag every `in_progress` and `blocked` plan.

### 2. Migrate legacy items (writes; confirm per project)

Follow the [migration steps](../../skills/plan-execution/references/run-state.md#migrating-from-the-legacy-layout). Show the planned moves as `from -> to` and ask before moving anything.

- Record `sha256sum` of every file you will move before the first move.
- Use one `mv` per item after `mkdir -p` of its parent. Never overwrite: if a target exists, stop and report.
- Rewrite `state.json` `plan` and any spec frontmatter `plan:` that points at the old path. List the matches first, edit on confirmation, and use `python3 -I` for the JSON.
- A `completed` plan and its state go to `.agents/work/<id>/` first, then to `.agents/archive/<current year>/<id>/` (step 6 of the migration). An `in_progress` or `blocked` plan stays in `.agents/work/<id>/`.
- A plan-less state directory without `active_tasks` counts as finished only after the user says so; then set `active_tasks: []`.
- Files in `.agents/plans/` without `status:` frontmatter are not ac plans. List them and ask: delete, move out, or keep. They must leave before the legacy directories can go.
- Remove only empty legacy directories, with `rmdir`. Never `rm -r`.
- Verify: neither `.agents/plans` nor `.agents/state` exists; the moved files' hashes match the recorded ones; every `state.json` passes `python3 -I -m json.tool`.

### 3. Back up the live configuration (writes under home; confirm)

Live apply with `--override` replaces `~/.claude/{agents,commands,skills}` and `~/.claude/settings.json`, and merges `mcpServers` into `~/.claude.json`.

- Report which top-level keys `~/.claude/settings.json` has that `settings/claude/settings.json` lacks, by name only. Apply drops them.
- Offer a copy to `~/.agent-ctrl-backup/<UTC stamp>/` with `cp -a`, covering those three directories, `settings.json`, and `~/.claude.json`. Create it with mode `700`, because the files hold secrets. Report the path and file counts.

### 4. Rehearse in a sandbox (read-only toward home)

One invocation per target. Stop at the first failure.

- Claude: `C=$(mktemp -d)`, `trap 'rm -rf "$C"' EXIT`, then `stat -c %a "$C"` prints `700`; `AGENT_CTRL_CLAUDE_HOME="$C" agent-ctrl apply claude --override --no-prompt` exits `0`; `test -f "$C/.claude/settings.json"`; `command grep -l plansDirectory "$C/.claude/settings.json"` prints nothing; `command grep -rnoE '\.agents/(plans|state)' "$C"` matches only in the rendered `run-state.md`, below its migration heading.
- OpenCode (only if it will be applied): same shape with `O=$(mktemp -d)`, `ln -sfn ~/.agent-ctrl "$O/.agent-ctrl"`, and `agent-ctrl apply opencode --path "$O" --override --no-prompt`.
- Record the literal sandbox path and each exit status. Confirm each path is gone afterwards.

### 5. Apply live (writes to home; explicit confirmation)

State the targets, the exact command, what it replaces, and the backup path. Ask which targets to apply: Claude, OpenCode, or both. Then run, without `--path`:

```
agent-ctrl apply claude --override --no-prompt
agent-ctrl apply opencode --override --no-prompt
```

Run only the chosen ones, each as its own command. Report the exit status.

### 6. Verify the live result

- `agent-ctrl agent ls .`, `agent-ctrl command ls .`, and `agent-ctrl skill ls .` report the same counts as step 1.
- `command grep -c '\.agents/work/' ~/.claude/commands/ac/run.md` is at least `1`.
- `command grep -c plansDirectory ~/.claude/settings.json` prints `0`.
- `command grep -rlE '\.agents/(plans|state)' ~/.claude/agents ~/.claude/commands ~/.claude/skills` lists only the installed `run-state.md` and `commands/ac/_update.md`, the two files that name the legacy paths on purpose.
- Remind the user that running sessions keep the old catalog loaded until they restart.

### 7. Finish

- Print the backup path as the rollback source.
- Recommend `.agents/work/` and `.agents/archive/` for `.gitignore`; do not edit it.
- Offer to remove this command: delete `commands/ac/_update.md` from the catalog, and ask before re-running the apply that also removes the installed copy from `~/.claude/commands/ac/`. Delete nothing without confirmation.

## Output

A table of step, result, and evidence (paths, counts, exit statuses), then what remains for the user.

## Boundaries

- Read-only until the user confirms a step's writes.
- Stop and report on any failed check; never continue past a failed step or work around it.
- Do not run a live apply without the step 3 backup unless the user explicitly declines it.
