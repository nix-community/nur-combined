# NUR packages

Personal Nix packages and NixOS/nix-darwin modules. `default.nix` exports
packages and module paths for NUR and caller-supplied `pkgs`; `flake.nix` locks
`nixpkgs/master` to expose prebuilt `packages.{x86_64-linux,aarch64-linux,aarch64-darwin}`,
`nixosModules`, and `darwinModules` backed by `https://davinci42.cachix.org`.

| Package           | Modules                                       | Documentation                                             |
| ----------------- | --------------------------------------------- | --------------------------------------------------------- |
| `basic-memory`    | None                                          | [Markdown memory and MCP server](pkgs/basic-memory/README.md) |
| `fluxdown-server` | `nixosModules.fluxdown`                       | [FluxDown Server](pkgs/fluxdown-server/README.md)         |
| `magpie`          | `nixosModules.magpie`, `darwinModules.magpie` | [Magpie gateway and agent manager](pkgs/magpie/README.md) |
| `mnamer-rs`       | None                                          | [mnamer Rust rewrite](pkgs/mnamer-rs/README.md)           |

## Maintenance

Run from the repository root with `<nixpkgs>` and `nix-command` enabled.
`nix-shell` supplies the tools; GitHub queries require authenticated `gh`.

```sh
nix-shell
just --list
just build mnamer-rs
just update mnamer-rs
just check mnamer-rs
just contract fluxdown-server
NIXPKGS_ALLOW_UNFREE=1 just check-all
NIXPKGS_ALLOW_UNFREE=1 just check-updates
NIXPKGS_ALLOW_UNFREE=1 just check-updates --update
just lint
```

- `just update <package> [version]` refreshes hashes and validates in a temporary
  copy before writing back. Review FluxDown contract changes before accepting
  them with `just update-reviewed fluxdown-server <version>`.
- `just check <package>` builds the package and lints. `just check-all` builds all
  packages and lints. Builds cover the current platform only.
- `just check-updates` detects releases in temporary copies without source or
  dependency downloads. Add `--update` to update and validate locally.

These commands do not deploy, commit or push. For in-place updates, use
`nix-update -f . <package> --use-update-script`; plain nix-update does not select
`passthru.updateScript` automatically. See [AGENTS.md](AGENTS.md) for maintenance rules.

## Automated updates

GitHub Actions checks packages daily at 00:37 UTC (08:37 China time) or via
`workflow_dispatch`. Validated updates become PRs without auto-merging.
The workflow supplies tokens to gh and nix-update, checks every package despite
individual failures, and fails after the summary if any package failed.
