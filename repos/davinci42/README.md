# NUR packages

Personal Nix packages and NixOS modules using the caller's `pkgs`.
`default.nix` exports packages and module paths.

| Package | NixOS module | Documentation |
| --- | --- | --- |
| `basic-memory` | None | [Markdown memory and MCP server](pkgs/basic-memory/README.md) |
| `fluxdown-server` | `nixosModules.fluxdown` | [FluxDown Server](pkgs/fluxdown-server/README.md) |
| `mnamer-rs` | None | [mnamer Rust rewrite](pkgs/mnamer-rs/README.md) |

## Maintenance and tests

Run from the repository root with `<nixpkgs>` and `nix-command` enabled.
`nix-shell` supplies the tools; GitHub queries require authenticated `gh`.

```sh
nix-shell
just --list
just build basic-memory
just update basic-memory
just check basic-memory
just contract fluxdown-server
NIXPKGS_ALLOW_UNFREE=1 just check-all
NIXPKGS_ALLOW_UNFREE=1 just check-updates
NIXPKGS_ALLOW_UNFREE=1 just check-updates --update
just lint
```

- `just update <package> [version]` refreshes hashes and validates in a temporary
  copy before writing back. Review FluxDown contract changes before accepting
  them with `just update-reviewed fluxdown-server <version>`.
- `just check <package>` builds the package and its `passthru.tests`, then lints.
  `just check-all` also runs updater tests. Builds cover the current platform only;
  VM tests are opt-in.
- `just check-updates` detects releases in temporary copies without source or
  dependency downloads. Add `--update` to update and validate locally.

These commands do not deploy, commit or push. For in-place updates, use
`nix-update -f . <package> --use-update-script`; plain nix-update does not select
`passthru.updateScript` automatically. See [AGENTS.md](AGENTS.md) for maintenance rules.

## Automated updates

GitHub Actions checks packages daily at 00:00 UTC (08:00 China time) or via
`workflow_dispatch`. Validated updates become PRs without auto-merging. Publishing
requires a self-hosted runner and a token with repository write and PR permissions.
The workflow supplies tokens to gh and nix-update, checks every package despite
individual failures, and fails after the summary if any package failed.
