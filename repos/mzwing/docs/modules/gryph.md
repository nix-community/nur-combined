# gryph Home Manager module

This module installs [gryph](https://github.com/safedep/gryph), a local-first audit trail and observability tool for AI coding agents, and wires its hooks into the agents you use. All data stays local in a SQLite database.

Unlike `gryph install` (which imperatively rewrites your agents' config files), the module manages everything declaratively and convergently:

- Standalone hook/plugin files are generated into the Nix store and linked by Home Manager.
- For agents whose hook configuration must live inside their own settings file (Claude Code, Gemini), and for the Codex feature flag, a Home Manager activation script merges the gryph entries idempotently. Disabling an integration removes the module-managed entries again; your own hooks and settings are never touched.

## Usage

```nix
# home.nix
{
  inputs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.home.gryph
  ];

  programs.gryph = {
    enable = true;

    # Pick the agents you use.
    enableIntegration = {
      claude-code = true; # merges into ~/.claude/settings.json
      gemini = true; # merges into ~/.gemini/settings.json
      codex = true; # ~/.codex/hooks.json + codex_hooks feature flag
      cursor = true; # ~/.cursor/hooks.json
      windsurf = true; # ~/.codeium/windsurf/hooks.json
      opencode = true; # ~/.config/opencode/plugins/gryph.js
      pi-agent = true; # ~/.pi/agent/extensions/gryph-hooks.ts
    };

    # Rendered verbatim to ~/.config/gryph/config.yaml. The module does not
    # validate keys; see https://github.com/safedep/gryph#configuration.
    settings = {
      logging.level = "full";
      storage.retention_days = 30;
      privacy.sensitive_paths = ["**/work-secrets/**"];
      display.timezone = "utc";
    };
  };
}
```

When consuming this repository directly as a flake input, import `inputs.mzwing.homeModules.gryph` instead.

After switching, use your agents normally and inspect the audit trail with:

```console
$ gryph logs
$ gryph status
$ gryph query --action exec --since 1w
```

## Options

| Option | Default | Description |
| --- | --- | --- |
| `enable` | `false` | Install gryph into `home.packages` and manage integrations. |
| `package` | `inputs.nur.repos.mzwing.gryph` | The gryph package to use. |
| `enableIntegration.<agent>` | `false` | Install gryph hooks for the given agent. Available agents: `claude-code`, `gemini`, `codex`, `cursor`, `windsurf`, `opencode`, `pi-agent`. |
| `hookCommand` | `"gryph"` | Command written into every generated hook. See the trade-off below. |
| `settings` | `{}` | Freeform attrset rendered to `~/.config/gryph/config.yaml`. Empty means no config file is generated. |
| `hooks` | (read-only) | Generated hook payloads per agent, for injection into other Home Manager modules. |

### `hookCommand`

The default bare `gryph` matches upstream behavior: gryph is on `PATH` via `home.packages`, and `gryph status`/`gryph doctor` recognize the hooks. Override it (e.g. with an absolute store path) only if your agents run in environments without the Home Manager session `PATH` — note that `gryph status` then reports the hooks as not configured, because it compares against the literal `gryph` command.

### Sharing a settings file with another Home Manager module

If you already manage `~/.claude/settings.json` or `~/.gemini/settings.json` with another Home Manager module (e.g. `programs.claude-code.settings`), the file is a Nix store symlink and the activation script refuses to touch it, aborting the switch with an explanatory error. Either disable the corresponding `programs.gryph.enableIntegration` entry, or inject the read-only hook payload into that module yourself:

```nix
programs.claude-code.settings.hooks = config.programs.gryph.hooks.claude-code;
```

The same applies to `~/.codex/config.toml` if another module manages it.

## Caveats

- **The config file is read-only.** `~/.config/gryph/config.yaml` is a Nix store symlink, so `gryph config set` fails with a permission error. This is expected and guarantees the file can only change through Home Manager — edit `programs.gryph.settings` instead.
- **Do not use `gryph install` / `gryph uninstall` under this module.** The module owns the hook installation. In particular, `gryph uninstall --purge` deletes the config symlink and the database; if that happens, re-run `home-manager switch` to restore them. Hooks removed from merged settings files are restored on the next switch.
- **Codex feature flag.** Enabling the Codex integration adds `codex_hooks = true` (with a `# managed-by:gryph-home-module` marker comment) to `~/.codex/config.toml`; disabling removes only the marked line. A flag you added yourself is never removed. If Codex rewrites the file and strips the comment, the flag may remain after disabling — it is harmless without the hooks.
- **Retention is manual.** Old events are not cleaned up automatically; run `gryph retention cleanup` periodically (see `storage.retention_days`, default 90 days).
- **Disabling the whole module.** Set the relevant `enableIntegration` entries to `false` and switch once before setting `programs.gryph.enable = false`, so the activation script can prune the merged entries. Home Manager removes the declaratively linked files on its own.
