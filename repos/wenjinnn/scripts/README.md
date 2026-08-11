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
| --------- | -------- | ---------- |
| lemminx-maven | [eclipse-lemminx/lemminx-maven](https://github.com/eclipse-lemminx/lemminx-maven) | `pkgs/lemminx-maven/default.nix` |
| pi-acp | [svkozak/pi-acp](https://github.com/svkozak/pi-acp) | `pkgs/pi-acp/default.nix` |
| pi-web | [jmfederico/pi-web](https://github.com/jmfederico/pi-web) | `pkgs/pi-web/default.nix` |

### Exit Codes

- `0`: All packages are up to date
- `1`: One or more packages have updates available
- `2`: The update check could not complete

### GitHub Actions

This script is automatically run weekly via GitHub Actions (`.github/workflows/check-updates.yml`). When updates are found, an issue is automatically created/updated with the `upstream-updates` label.
