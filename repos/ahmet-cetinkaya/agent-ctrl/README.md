# agent-ctrl configuration

This is the source catalog applied by [agent-ctrl](https://github.com/ahmet-cetinkaya/agent-ctrl) to Claude Code and OpenCode. It is a deliberately small, provider-neutral engineering core rather than a restoration of the legacy catalog.

## Inventory

- `agents/`: 7 coordinated `ac-*` agents.
- `commands/ac/`: 12 explicit workflow commands: `spec`, `plan`, `plan-review`, `run`, `fix`, `research`, `review`, `verify`, `doc`, `changelog`, `pr`, and `pr-address`.
- `skills/`: 10 skills, each with a short routing contract and focused references.
- `rules/`: 2 shared rules, `safety.md` and `clean-code.md`.
- `profiles/`: 38 optional language, framework, platform, and domain profiles, applied per project; see `docs/profiles/README.md`.
- `mcps/`: existing MCP definitions, applied globally. The AFFiNE servers are not here: they are local-scoped to the ACBrain project (`projects["/home/ac/Documents/ACBrain"].mcpServers` in `~/.claude.json`) so only sessions in that vault load them.
- `settings/claude/` and `settings/opencode/`: platform-specific settings copied by apply. `settings/omo/`: the standalone `oh-my-openagent` config, symlinked (not apply-copied) into `~/.config/opencode/.omo/`.
- `docs/`: composition indexes and one provenance record per executable artifact. Documentation is kept outside scanned artifact directories.

## Entry points

Ordinary natural-language sessions start with `lead`. It handles small, known work directly and routes specialized work only when needed. Explicit checkpoints are available as `/ac:spec`, `/ac:plan`, `/ac:plan-review`, `/ac:run`, `/ac:fix`, `/ac:research`, `/ac:review`, `/ac:verify`, `/ac:doc`, `/ac:changelog`, `/ac:pr`, and `/ac:pr-address`.

Durable plans live at `.agents/work/<slug>/plan.md`, independent of either provider's private state directories. `/ac:plan` writes `status: draft` but never implements it; only explicit approval changes it to `status: approved`. `/ac:run` starts approved plans, resumes recorded in-progress or resolved-blocked plans, rejects draft/completed/ambiguous plans, and executes clear scoped requests without committing or pushing. Runtime state — resume pointer, notepad, ledger, and captured evidence — lives in the same work folder, and plan-less work uses `.agents/work/<YYYYMMDD>-<scope-slug>/`. Finished work is archived to `.agents/archive/<YYYY>/<id>/` by the start-of-run sweep of `/ac:pr` once its PR is merged. Keep `.agents/work/` and `.agents/archive/` git-ignored: durable design (`research.md`, `data-model.md`, `contracts/`) lives beside the spec under `specs/changes/`. Projects on the earlier layout must be migrated by hand first, as described in [Migrating from the legacy layout](skills/plan-execution/references/run-state.md#migrating-from-the-legacy-layout).

Spec-driven work is optional and adds one artifact upstream of the plan. `/ac:spec` writes a behavior spec (EARS requirements, Given/When/Then scenarios, measurable success criteria) to `specs/changes/<NNNN>-<slug>/SPEC.md`; re-running it on the draft asks targeted clarifying questions. After explicit approval, `/ac:plan <spec-path>` derives the plan with a traceability table, `/ac:plan-review` checks spec coverage, `/ac:run` records deviations in the spec instead of silently changing requirements, and `/ac:verify` demands evidence per criterion. On ship the change's deltas merge into the living spec at `specs/<capability>/SPEC.md` and the change directory is archived unchanged.

## Delegation graph

- `lead` may call planner, executor, worker, explorer, researcher, or advisor. It writes `/ac:plan` plans, runs `/ac:run` plans, and runs the `/ac:fix` loop itself, dispatching workers only for parallel task batches.
- `planner` writes `/ac:spec` specs and may call explorer, researcher, or advisor only.
- `executor` serves the `/ac:verify` gate and `/ac:pr-address` fixes, and may call worker, explorer, researcher, or advisor only.
- `worker`, `explorer`, `researcher`, and `advisor` are leaves and never delegate.
- No child calls back to `lead`; the graph has no cycle.

Review depth is risk-based. Correctness and scoped verification remain mandatory, while independent advisor review is added for security, authentication, sensitive data, schema or migration, shared API, CI, and critical user-facing changes. Verification is fail-closed: missing evidence cannot produce `READY`. Project-defined quality gates take precedence; there is no global coverage percentage or blanket language policy.

## Apply and inspect

Run catalog inspection from this directory:

```bash
agent-ctrl agent ls .
agent-ctrl command ls .
agent-ctrl skill ls .
agent-ctrl rule ls .
```

`apply` reads the catalog from `~/.agent-ctrl`, which points at this repository. Do not pass `--path` for a live apply: agent-ctrl then reads the catalog from `<path>/.agent-ctrl`, and with `--override` an empty catalog there deletes the live `skills/`, `agents/`, and `commands/`. For OpenCode, `--path` also replaces the target root (`~/.config/opencode` by default).

Try an apply in a throwaway directory before writing to real home configuration. A dry run does not list the files it would write, so inspect a real sandbox apply instead:

```bash
# Claude: AGENT_CTRL_CLAUDE_HOME moves the target; the catalog still comes from ~/.agent-ctrl
AGENT_CTRL_CLAUDE_HOME=/tmp/agent-ctrl-claude agent-ctrl apply claude --override --no-prompt

# OpenCode: --path sets the target root and the catalog parent, so link the catalog into it
mkdir -p /tmp/agent-ctrl-opencode && ln -sfn ~/.agent-ctrl /tmp/agent-ctrl-opencode/.agent-ctrl
agent-ctrl apply opencode --path /tmp/agent-ctrl-opencode --override --no-prompt
```

Then apply to the live target without `--path`, for example `agent-ctrl apply claude --override --no-prompt`. The Claude apply replaces `~/.claude/settings.json` with `settings/claude/settings.json`, dropping preferences Claude Code saved there, and merges only `mcpServers` into `~/.claude.json`. Applying to real home configuration is a separate user-authorized action.

## Claude settings

The Claude settings and the auto mode guard model are described in [settings/claude/README.md](settings/claude/README.md).

## Claude and OpenCode coexistence

Claude and OpenCode both default to `lead`, and the shared catalog is rendered by agent-ctrl. OpenCode keeps `oh-my-openagent@latest` for its runtime, routing, and existing settings. Its Claude artifact import switches remain disabled, preventing duplicate commands, skills, hooks, plugins, agents, or MCP definitions. Delegating source agents use Claude's backward-compatible `Task` alias; agent-ctrl renders the OpenCode tool map in lowercase.

## Model tiers

Agent `models.claude` values are Claude model aliases resolved through the `ANTHROPIC_DEFAULT_*_MODEL` settings: `advisor`, `planner` and `executor` → `opus`, `worker` and `researcher` → `sonnet`, `explorer` → `haiku`, `lead` → `inherit` (the session's main model). Delegating agents omit per-invocation model overrides so these definitions stay authoritative.

Composition and licensing details are indexed in `docs/agents/`, `docs/commands/`, `docs/skills/`, and `docs/rules/`.
