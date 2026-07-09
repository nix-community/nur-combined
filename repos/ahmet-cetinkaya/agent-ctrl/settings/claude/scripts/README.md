# scripts

Node.js implementations behind the hook graph, plus the shared libraries they depend on. The
hook graph in `../hooks/hooks.json` references these by path; `agent-ctrl apply claude` installs
them alongside the resolved graph.

```
scripts/
├── hooks/    # Hook entry points (invoked by hooks.json)
└── lib/      # Shared libraries used by the hook scripts
```

## hooks/

Each file is a hook or a sub-check. Two dispatchers consolidate several checks into one process;
the rest are standalone. See `../hooks/README.md` for the wiring, matchers, and profiles.

**Dispatchers & routing**
- `pre-bash-dispatcher.js`, `post-bash-dispatcher.js` → delegate to `bash-hook-dispatcher.js`
- `run-with-flags.js`, `run-with-flags-shell.sh` — profile-gated runner (`ECC_HOOK_PROFILE`)
- `plugin-hook-bootstrap.js`, `check-hook-enabled.js` — root resolution + enable checks

**Bash pre-checks** — `block-no-verify.js`, `auto-tmux-dev.js`, `pre-bash-dev-server-block.js`,
`pre-bash-tmux-reminder.js`, `pre-bash-git-push-reminder.js`, `pre-bash-commit-quality.js`,
`gateguard-fact-force.js`

**Bash post-checks** — `post-bash-command-log.js`, `post-bash-pr-created.js`,
`post-bash-build-complete.js`

**Edit/Write** — `quality-gate.js`, `design-quality-check.js`, `post-edit-accumulator.js`,
`post-edit-format.js`, `post-edit-typecheck.js`, `config-protection.js`, `doc-file-warning.js`,
`pre-write-doc-warn.js`, `suggest-compact.js`

**MCP / security / governance** — `mcp-health-check.js`, `governance-capture.js`,
`insaits-security-monitor.py`, `insaits-security-wrapper.js`

**Stop** — `stop-format-typecheck.js`, `check-console-log.js`, `desktop-notify.js`

**Statusline / session** — `ecc-statusline.js`, `cursor-session-env.js`,
`pretooluse-visible-output.js`

> Not every script here is registered in the current `hooks.json`. Some are library-style helpers
> invoked by dispatchers, and some are available but unwired. The graph in `../hooks/hooks.json`
> is the source of truth for what actually runs.

## lib/

Shared modules imported by the hook scripts:

| Module | Role |
|--------|------|
| `state-store/` | Persistent hook/session state |
| `session-adapters/` | Session/transcript adapters |
| `install/`, `install-targets/` | Install lifecycle + per-platform targets |
| `mcp-inventory/` | MCP server inventory + health |
| `worktree-lifecycle/` | Git worktree orchestration |
| `github-coordination/` | GitHub PR/discussion coordination |
| `agent-proximity/`, `control-pane/` | Agent orchestration helpers |
| `skill-evolution/`, `skill-improvement/` | Skill capture/refinement |

Plus flat helpers — `utils.js`, `package-manager.js`, `project-detect.js`, `resolve-ecc-root.js`,
`resolve-formatter.js`, `session-manager.js`, `hook-flags.js`, `path-safety.js`, and others.

## Conventions

- Read the tool payload as JSON on stdin, write it back on stdout (see `../hooks/README.md`).
- Exit `2` to block (PreToolUse only); other non-zero is logged but non-blocking.
- Cross-platform Node.js (Linux/macOS/Windows); the one Python script is security monitoring.
