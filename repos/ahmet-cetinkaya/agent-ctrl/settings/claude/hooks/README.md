# Hooks

Event-driven automations that fire around Claude Code tool executions. They enforce code
quality, protect config, guard against unsafe edits, and surface notifications — without
touching session memory (that layer is handled externally, see [Scope](#scope)).

## How Hooks Work

```
User request → Claude picks a tool → PreToolUse → tool runs → PostToolUse → … → Stop
```

- **PreToolUse** — runs before the tool. Can **block** (exit code 2) or **warn** (stderr, non-blocking).
- **PostToolUse** — runs after the tool completes. Can analyze output but cannot block.
- **PostToolUseFailure** — runs after a tool call fails.
- **Stop** — runs once after each Claude response.

The executable hook graph is `hooks.json`. Node.js script implementations live in
`../scripts/hooks/`. `agent-ctrl apply claude` installs the resolved graph into your Claude root.

## Scope

Session/memory lifecycle — context loading, compaction state, continuous-learning observation,
session metrics, and cost tracking — is handled externally by **OmniRoute** and is intentionally
**not** duplicated here. See the root README's *External layer* section. The hooks below are
limited to quality, safety, and notification concerns.

## The Hook Graph

Two Bash hooks (`pre:bash:dispatcher`, `post:bash:dispatcher`) are consolidators: each fans out
to a set of profile-gated sub-checks in one process. Everything else is a standalone hook.

### PreToolUse

| ID | Matcher | What it does | Blocks? |
|----|---------|--------------|---------|
| `pre:bash:dispatcher` | `Bash` | Fans out to: block `--no-verify`, auto-tmux dev servers, tmux reminder, git-push reminder, commit-quality check, GateGuard fact-force | yes (critical) |
| `pre:write:doc-file-warning` | `Write` | Warns on non-standard `.md`/`.txt` files (allows README, CLAUDE, CONTRIBUTING, CHANGELOG, LICENSE, SKILL, `docs/`, `skills/`) | no |
| `pre:edit-write:suggest-compact` | `Edit\|Write` | Suggests manual `/compact` at logical intervals | no |
| `pre:governance-capture` | `Bash\|Write\|Edit\|MultiEdit` | Captures governance events (secrets, policy violations, approvals). Opt-in via `ECC_GOVERNANCE_CAPTURE=1` | no |
| `pre:config-protection` | `Write\|Edit\|MultiEdit` | Blocks edits to linter/formatter config files; steers toward fixing code instead of weakening rules | yes |
| `pre:mcp-health-check` | `*` | Checks MCP server health before an MCP call; blocks unhealthy servers | yes |
| `pre:edit-write:gateguard-fact-force` | `Edit\|Write\|MultiEdit` | Blocks the first edit per file until importers/schemas/instructions are investigated | yes (first edit) |

### PostToolUse

| ID | Matcher | What it does |
|----|---------|--------------|
| `post:bash:dispatcher` | `Bash` | Fans out to: command-log audit + cost, PR-created notice, build-complete analysis (async) |
| `post:quality-gate` | `Edit\|Write\|MultiEdit` | Fast quality checks after edits (async) |
| `post:edit:design-quality-check` | `Edit\|Write\|MultiEdit` | Warns when frontend edits drift toward generic template-looking UI |
| `post:edit:accumulator` | `Edit\|Write\|MultiEdit` | Records edited JS/TS paths for a single batched format+typecheck at Stop |
| `post:governance-capture` | `Bash\|Write\|Edit\|MultiEdit` | Captures governance events from tool output. Opt-in via `ECC_GOVERNANCE_CAPTURE=1` |

### PostToolUseFailure

| ID | Matcher | What it does |
|----|---------|--------------|
| `post:mcp-health-check` | `*` | Tracks failed MCP calls, marks servers unhealthy, attempts reconnect |

### Stop

| ID | What it does |
|----|--------------|
| `stop:format-typecheck` | Batch-formats (Biome/Prettier) and typechecks (tsc) every JS/TS file edited this response — once, instead of per-edit |
| `stop:check-console-log` | Audits modified files for `console.log` |
| `stop:desktop-notify` | Sends a desktop notification with a task summary |

## Runtime Controls

Control hook behavior with environment variables — no need to edit `hooks.json`:

```bash
# Hook profile: minimal | standard | strict (default: standard)
export ECC_HOOK_PROFILE=standard

# Disable specific hook IDs (comma-separated)
export ECC_DISABLED_HOOKS="pre:bash:tmux-reminder,stop:desktop-notify"

# Disable only GateGuard (e.g. during setup or recovery)
export ECC_GATEGUARD=off

# Enable governance capture (off by default)
export ECC_GOVERNANCE_CAPTURE=1
```

Profiles:
- `minimal` — essential safety hooks only.
- `standard` — default; balanced quality + safety.
- `strict` — adds extra reminders (tmux, git-push, commit-quality) and tighter guardrails.

## Writing a Hook

A hook reads the tool payload as JSON on stdin and writes JSON back on stdout.

```javascript
let data = '';
process.stdin.on('data', chunk => (data += chunk));
process.stdin.on('end', () => {
  const input = JSON.parse(data);
  const { tool_name, tool_input, tool_output } = input; // tool_output: PostToolUse only

  // Warn (non-blocking): write to stderr
  console.error('[Hook] Heads up: …');

  // Block (PreToolUse only): process.exit(2)

  process.stdout.write(data); // always pass the payload through
});
```

**Exit codes:** `0` success · `2` block (PreToolUse only) · other non-zero → logged, non-blocking.

**Payload shape:**

```typescript
interface HookInput {
  tool_name: string;                 // "Bash" | "Edit" | "Write" | "Read" | …
  tool_input: {
    command?: string;                // Bash
    file_path?: string;              // Edit | Write | Read
    old_string?: string;             // Edit
    new_string?: string;             // Edit
    content?: string;                // Write
  };
  tool_output?: { output?: string }; // PostToolUse only
}
```

For slow work (background analysis), mark the hook `"async": true` with a `"timeout"` — it runs
detached and cannot block the tool.

## Related

- `hooks.json` — the executable hook graph
- `../scripts/hooks/` — Node.js hook implementations
