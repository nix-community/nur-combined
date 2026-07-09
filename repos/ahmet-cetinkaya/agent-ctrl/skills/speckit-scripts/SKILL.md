---
name: speckit-scripts
description: Bundled Spec Kit automation scripts (bash + PowerShell) and artifact templates that back the /speckit:* commands. Use when a spec-driven workflow needs to create a feature, set up plan/tasks, or check prerequisites, and the target project has no .specify/ yet.
metadata:
  origin: github-spec-kit
  source: github.com/github/spec-kit
---

# Spec Kit Scripts & Templates

This skill bundles the automation layer behind the `/speckit:*` commands: the shell scripts
that create feature branches/dirs and wire up plan/tasks, plus the artifact templates
(`spec`, `plan`, `tasks`, `constitution`, `checklist`) they render.

## What's bundled

### `scripts/bash/` (and `scripts/powershell/` mirror)

| Script | Purpose |
|--------|---------|
| `common.sh` | Shared helpers: locate `.specify/` root, resolve feature paths, JSON output. Sourced by the others. |
| `create-new-feature.sh` | Create a feature (branch + `specs/<n>/` dir + `spec.md` from template). Used by `/speckit:specify`. |
| `setup-plan.sh` | Scaffold `plan.md` from the plan template for the current feature. Used by `/speckit:plan`. |
| `setup-tasks.sh` | Scaffold `tasks.md` for the current feature. Used by `/speckit:tasks`. |
| `check-prerequisites.sh` | Validate that required artifacts exist (`--require-tasks`, `--paths-only`, `--json`). Used by `analyze`, `clarify`, `implement`, `converge`, `checklist`. |

### `templates/`

`spec-template.md`, `plan-template.md`, `tasks-template.md`, `constitution-template.md`,
`checklist-template.md`, `vscode-settings.json` — the canonical artifact shapes the scripts
and commands fill in.

## How the commands use these

The `/speckit:*` command frontmatter references scripts by a project-relative path, e.g.:

```yaml
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/setup-plan.ps1 -Json
```

At runtime these resolve against the **target project's** `.specify/` directory — Spec Kit
installs a copy of these scripts and templates into `.specify/` when the project is
initialized. So the canonical execution path is `.specify/scripts/bash/<script>.sh`, not
this skill's copy.

## Setup (when a project has no `.specify/`)

Spec-driven commands require the project to be initialized once:

```bash
specify init . --ai claude      # creates .specify/ with scripts + templates
```

`/ac:index` already runs this as part of repo initialization. If `specify` (the CLI) is not
available, this skill's `scripts/` and `templates/` are the reference copies to seed
`.specify/` manually:

```bash
mkdir -p .specify/scripts .specify/templates
cp -r <this-skill>/scripts/* .specify/scripts/
cp -r <this-skill>/templates/* .specify/templates/
```

## Boundaries

- These scripts operate on `.specify/`-structured projects. Running them outside such a
  project (no `.specify/` marker found by `common.sh`) will fail fast — initialize first.
- The bash and powershell trees are mirrors; use whichever matches the host shell.
- Do not edit the bundled scripts to hardcode a project path — resolution is dynamic via
  `common.sh`'s `.specify/` upward search.
