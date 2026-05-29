# piPackages - Nix Package Set for Pi Coding Agent

A Nix package set similar to `pythonPackages` in nixpkgs, providing access to all official pi packages from [pi.dev/packages](https://pi.dev/packages).

## Features

- **Declarative package management**: Define pi packages in your Nix configuration
- **Version pinning**: Lock specific package versions for reproducibility
- **Offline installation**: Packages are fetched once and cached in the Nix store
- **Type-safe**: Package names are validated at build time
- **Home-manager integration**: Seamlessly integrate with existing pi configuration

## Quick Start

### 1. Using piPackages in Home Manager

```nix
# In your home-manager configuration (e.g., home-manager/hosts/nixos.nix)
{ config, pkgs, ... }:
{
  programs.pi = {
    enable = true;

    # Declaratively install pi packages from piPackages
    extraPackages = with pkgs.piPackages; [
      pi-mcp-adapter
      pi-web-access
      "@gotgenes/pi-subagents"
      pi-lens
      "@samfp/pi-memory"
    ];

    # Or use string specifiers (existing behavior)
    packages = [
      "npm:@gotgenes/pi-subagents"
      "npm:pi-mcp-adapter"
    ];
  };
}
```

### 2. Accessing piPackages Directly

```nix
# In any Nix expression
{ pkgs, ... }:
let
  myPiPackage = pkgs.piPackages.pi-mcp-adapter;
in
{
  # Use the package derivation
  environment.systemPackages = [ myPiPackage ];
}
```

### 3. Building a Package

```bash
# Build a specific pi package
nix build .#piPackages.pi-mcp-adapter

# Build all pi packages
nix build .#piPackages
```

## Available Packages

The piPackages set includes popular packages from the pi ecosystem:

### Core Extensions
- `pi-mcp-adapter` - MCP (Model Context Protocol) adapter
- `pi-web-access` - Web search and URL fetching
- `pi-lens` - Real-time code feedback

### Subagent Extensions
- `@gotgenes/pi-subagents` - Claude Code-style sub-agents
- `@tintinweb/pi-subagents` - Smart sub-agents
- `pi-subagents` - Basic subagent delegation

### UI Extensions
- `pi-powerline-footer` - Powerline-style status bar
- `pi-bar` - Statusline with model info

### Memory Extensions
- `@samfp/pi-memory` - Persistent memory
- `pi-hermes-memory` - Memory with session search
- `gentle-engram` - Agent memory system

### Search Extensions
- `@ahkohd/pi-yagami-search` - Yagami web search
- `@ollama/pi-web-search` - Ollama web search
- `@ff-labs/pi-fff` - Fuzzy file search

### Security Extensions
- `@gotgenes/pi-permission-system` - Permission enforcement
- `@aliou/pi-guardrails` - Guardrails and security
- `@vigolium/piolium` - Security audits

### Workflow Extensions
- `@juicesharp/rpiv-ask-user-question` - Structured questions
- `@juicesharp/rpiv-todo` - Todo list overlay
- `@juicesharp/rpiv-web-tools` - Web tools with providers
- `@juicesharp/rpiv-advisor` - Second opinion
- `@juicesharp/rpiv-pi` - Skill-based workflow

### Document Extensions
- `pi-docparser` - Document understanding
- `pi-markdown-preview` - Markdown + LaTeX preview

### Browser Extensions
- `pi-chrome` - Chrome profile integration

### Workflow Extensions
- `pi-agent-flow` - Flow-state transitions
- `pi-crew` - Coordinated AI teams
- `@linimin/pi-letscook` - Long-running workflows

### Spec-Driven Development
- `@capyup/pi-specs` - Spec-driven workflows
- `@gonrocca/zero-pi` - Zero SDD workflow
- `gentle-pi` - Senior-architect harness

### Other Extensions
- `pi-simplify` - Code review
- `pi-cmux` - Terminal integrations
- `pi-resource-center` - Resource browsing
- `pi-skillful` - Skill improvements
- `pi-studio` - Browser workspace
- `pi-intercom` - Intercom integration
- `@llblab/pi-actors` - Local Actor Kernel
- `@runfusion/fusion` - Fusion CLI
- `context-mode` - Context window optimization
- `pi-btw` - Side conversations
- `pi-ask-user` - Interactive questions
- `pi-sub-agent` - Sub-agent functionality
- `osdy-pi` - Themes and editor
- `@kimuson/pi-ralph` - Kimuson package
- `@oppiai/pi-package` - OPPi package
- `@timtekno/agentic-template` - Company workflows
- `@eko24ive/pi-ask` - Clarification tool
- `@outlit/pi` - Outlit intelligence
- `@narumitw/pi-skillforge` - Skill improvement
- `@aexol/pi-wizard` - Wizard tools
- `@howaboua/pi-codex-conversion` - Codex adapter
- `@nitra/cursor` - Cursor rules
- `@pi-unipi/core` - Unipi utilities
- `@raindrop-ai/pi-agent` - Raindrop observability
- `@a5c-ai/babysitter-pi` - Babysitter
- `aptive-airflow-agent-team` - Airflow agent chain
- `gentle-engram` - Persistent memory

## Adding New Packages

### Manual Method

1. Find the package on [npmjs.com](https://www.npmjs.com/)
2. Get the package name and version
3. Use the update script to get the hash:

```bash
./pkgs/pi-packages/scripts/update-pi-package.sh <package-name> [version]
```

4. Add the package to `pkgs/pi-packages/default.nix`

### Example

```bash
./pkgs/pi-packages/scripts/update-pi-package.sh @new-scope/pi-extension 1.0.0
```

The script will output the package definition with the correct hash.

## Architecture

```
pkgs/pi-packages/
├── default.nix          # Main package set
├── fetchPiPackage.nix   # Fetcher function
├── scripts/
│   └── update-pi-package.sh  # Helper script
└── README.md            # This file
```

### fetchPiPackage

A function that fetches a pi package from npm:

```nix
fetchPiPackage {
  name = "pi-mcp-adapter";  # Package name (without scope)
  version = "2.8.0";        # Version
  hash = "sha256-...";      # Nix hash
  scope = "";               # Optional scope (e.g., "@gotgenes")
}
```

## Troubleshooting

### Package not found

If a package is not in piPackages, you can:
1. Add it manually using the update script
2. Use string specifiers: `"npm:@scope/package-name"`
3. Create a custom derivation

### Hash mismatch

If you get a hash mismatch error:
1. Use `lib.fakeHash` temporarily
2. Build the package
3. Nix will show the correct hash
4. Update the hash in default.nix

### Package not loading in pi

Ensure:
1. The package is in `extraPackages` (not just `packages`)
2. The package has the correct structure (extensions/, skills/, etc.)
3. Check `~/.pi/npm/lib/node_modules/` for the symlink

## Contributing

To add a new package to piPackages:

1. Fork the repository
2. Add the package to `default.nix`
3. Test with `nix build .#piPackages.<package-name>`
4. Submit a pull request

## License

MIT
