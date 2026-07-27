# Claude Code (Home Manager Extension)

Extension module for Home Manager's `programs.claude-code` with plugin support.

## Usage

```nix
{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-repository.homeModules.claude-code
  ];

  programs.claude-code = {
    enable = true;

    # Use upstream settings for hooks, permissions, etc.
    settings = {
      permissions.allow = [ "Bash(git:*)" "Read" ];
      hooks.PreToolUse = [{
        matcher = "Bash";
        hooks = [{ type = "command"; command = "echo $TOOL_INPUT"; }];
      }];
    };

    # Import plugins (this module)
    plugins = [
      (pkgs.fetchFromGitHub {
        owner = "someone";
        repo = "claude-plugins";
        rev = "v1.0.0";
        hash = "sha256-...";
      })
    ];
  };
}
```

## Options

### `plugins`

Import commands/agents/skills from external sources.

```nix
plugins = [
  # From GitHub (use tag or commit hash)
  (pkgs.fetchFromGitHub {
    owner = "someone";
    repo = "claude-plugins";
    rev = "v1.0.0";
    hash = "sha256-...";
  })

  # Subpath import (monorepo with multiple plugins)
  ((pkgs.fetchFromGitHub {
    owner = "someone";
    repo = "dotfiles";
    rev = "abc1234";
    hash = "sha256-...";
  }) + "/claude/my-plugin")

  # Local path
  ./my-local-plugin

  # Selective import
  {
    src = ./my-plugin;
    commands = true;
    agents = true;
    skills = false;
  }
];
```

**Plugin structure** (auto-detected):

```
plugin/
├── .claude-plugin/
│   └── plugin.json      # Optional: custom paths
├── commands/            # Default: ./commands/
├── agents/              # Default: ./agents/
└── skills/              # Default: ./skills/
```

**plugin.json format**:

```json
{
  "name": "my-plugin",
  "commands": "./custom/commands/",
  "agents": "./agents/",
  "skills": "./my-skills/"
}
```

## Generated Files

Plugin files are merged into `~/.claude/` with plugin name as subdirectory:

| Source             | Destination                         |
| ------------------ | ----------------------------------- |
| `plugin/commands/` | `~/.claude/commands/{plugin-name}/` |
| `plugin/agents/`   | `~/.claude/agents/{plugin-name}/`   |
| `plugin/skills/`   | `~/.claude/skills/{plugin-name}/`   |

Name resolution order:

1. User-provided `name` option
2. `name` field in `plugin.json`
3. Directory basename (store hash stripped)
