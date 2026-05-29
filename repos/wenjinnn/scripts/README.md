# Scripts

This directory contains scripts for managing packages in this NUR repository.

## check-updates.sh

Checks for upstream version updates for all monitored packages.

### Usage

```bash
# Check for updates (human-readable output)
./scripts/check-updates.sh

# Check for updates (JSON output)
./scripts/check-updates.sh --json
```

### Monitored Packages

| Package | Source | Nix File |
|---------|--------|----------|
| lemminx-maven | [eclipse-lemminx/lemminx-maven](https://github.com/eclipse-lemminx/lemminx-maven) | `pkgs/lemminx-maven/default.nix` |
| pi-acp | [svkozak/pi-acp](https://github.com/svkozak/pi-acp) | `pkgs/pi-acp/default.nix` |
| pi-mcp-adapter | [nicobailon/pi-mcp-adapter](https://github.com/nicobailon/pi-mcp-adapter) | `pkgs/pi-packages/default.nix` |
| pi-web-access | [nicobailon/pi-web-access](https://github.com/nicobailon/pi-web-access) | `pkgs/pi-packages/default.nix` |
| pi-hermes-memory | [chandra447/pi-hermes-memory](https://github.com/chandra447/pi-hermes-memory) | `pkgs/pi-packages/default.nix` |
| @gotgenes/pi-subagents | [gotgenes/pi-packages](https://github.com/gotgenes/pi-packages) | `pkgs/pi-packages/default.nix` |
| @juicesharp/rpiv-ask-user-question | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono) | `pkgs/pi-packages/default.nix` |
| @juicesharp/rpiv-btw | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono) | `pkgs/pi-packages/default.nix` |

### Exit Codes

- `0`: All packages are up to date
- `1`: One or more packages have updates available

### GitHub Actions

This script is automatically run weekly via GitHub Actions (`.github/workflows/check-updates.yml`). When updates are found, an issue is automatically created/updated with the `upstream-updates` label.

## update-pi-package.sh

Updates a specific pi-package to a new version. See `pkgs/pi-packages/scripts/update-pi-package.sh` for details.
