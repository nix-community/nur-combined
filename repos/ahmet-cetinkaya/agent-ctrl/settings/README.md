# settings

Platform-native settings that `agent-ctrl` syncs into each tool's own config root — the parts
that are **not** commands, MCPs, agents, or skills (those live in the repo's top-level dirs).

## Layout

```
settings/
└── claude-code/     # Claude Code (~/.claude/) main settings
```

Each subdirectory targets one platform. Today only `claude-code/` exists; other platforms
(Cursor, etc.) can get their own subdirectory here as needed.

## What belongs here

- Top-level config files (e.g. `settings.json`)
- Event hooks (`hooks/`)
- Hook/runtime scripts (`scripts/`)
- Behavior-mode context primers (`contexts/`)

## What does NOT belong here

Commands, MCP server configs, agent personas, and skills are managed in the repo's top-level
`commands/`, `mcps/`, `agents/`, and `skills/` directories — not under `settings/`.

## Secrets

Never commit live credentials. Secret values are replaced with `${VAR}` placeholders and
resolved from `.env` at `agent-ctrl apply` time (e.g. `ANTHROPIC_AUTH_TOKEN` in
`claude-code/settings.json`).
