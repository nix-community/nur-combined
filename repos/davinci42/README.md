# NUR packages

Personal Nix packages and NixOS/nix-darwin modules. `default.nix` exports
packages and module paths for NUR and caller-supplied `pkgs`; `flake.nix` locks
`nixpkgs` (`nixos-unstable`, shallow Git) to expose
`packages.{x86_64-linux,aarch64-linux,aarch64-darwin}`, `overlays.default`,
`nixosModules`, and `darwinModules`, with Linux binary caches on
`https://davinci42.cachix.org`.

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
  copy before writing back.
- `just check <package>` builds the package and lints. `just check-all` builds all
  packages and lints. Builds cover the current platform only.
- `just check-updates` detects releases in temporary copies without source or
  dependency downloads. Add `--update` to update and validate locally.

These commands do not deploy, commit or push. For in-place updates, use
`nix-update -f . <package> --use-update-script`; plain nix-update does not select
`passthru.updateScript` automatically. See [AGENTS.md](AGENTS.md) for maintenance rules.

## Automated updates

GitHub Actions updates `flake.lock` (`chore(flake): update nixpkgs`) and checks
custom packages via `workflow_dispatch`. After `x86_64-linux` and
`aarch64-linux` builds succeed and push to `davinci42.cachix.org`, `main` is
fast-forwarded automatically and the NUR index is refreshed.
