# claude-code settings

Main Claude Code settings, mirrored from `~/.claude/` and version-controlled here. Applied back
into your Claude root via `agent-ctrl apply claude`.

## Layout

```
claude-code/
├── settings.json    # Core Claude Code settings (env, permissions, hooks wiring, plugins)
├── RTK.md           # Rust Token Killer reference (token-optimizing CLI proxy)
├── contexts/        # Behavior-mode context primers (dev / research / review)
├── hooks/           # Event-driven hook graph (see hooks/README.md)
└── scripts/         # Hook implementations + shared libs (see scripts/README.md)
```

## Files

| Path | Purpose |
|------|---------|
| `settings.json` | Environment, tool permissions, hook registration, enabled plugins, statusline. Secrets are `${VAR}` placeholders resolved from `.env`. |
| `RTK.md` | Command reference for the RTK proxy that rewrites shell commands to cut token usage. |
| `contexts/` | Manually-loaded behavior primers that bias mode (implement vs. explore vs. review). |
| `hooks/` | `hooks.json` graph + docs for quality, safety, and notification hooks. |
| `scripts/` | Node.js hook scripts (`scripts/hooks/`) and shared libraries (`scripts/lib/`). |

## Not managed here

Commands, MCP servers, agents, and skills come from the repo's top-level directories, not this
folder — even though `agent-ctrl apply` installs all of them into the same `~/.claude/` root.

## Secrets

`settings.json` stores `ANTHROPIC_AUTH_TOKEN` (and any other secret) as `${ANTHROPIC_AUTH_TOKEN}`.
The real value lives in `.env` (git-ignored) and is substituted at apply time. Never commit the
resolved token.
