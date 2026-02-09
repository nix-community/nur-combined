# AGENTS.md

## Commands
- **Build a package**: `nix build .#<package>` (e.g., `nix build .#caddy`)
- **Build all (CI)**: `nix-build ci.nix -A cacheOutputs`
- **Format**: `nix fmt`
- **Lint**: formatting includes deadnix, statix, nixfmt, shellcheck, shfmt, stylua, taplo, yamlfmt, rubocop
- **Update sources**: `./scripts/update.sh` (uses nvfetcher + nix update scripts)
- **Eval check**: `nix eval .#packages.x86_64-linux --apply builtins.attrNames`

## Architecture
NUR (Nix User Repository) flake. Entry point is `default.nix`; each package lives in `pkgs/<name>/default.nix` and is wired via `callPackage`. Sources are auto-fetched by nvfetcher (`nvfetcher.toml` → `_sources/generated.nix`).
- `pkgs/` — package derivations
- `modules/` — NixOS modules; `hm-modules/` — Home Manager modules
- `overlays/` — nixpkgs overlays
- `lib/` — helper functions

## Code Style
- Nix files formatted with `nixfmt`; linted with `deadnix` (unused bindings) and `statix` (anti-patterns).
- Shell scripts use `shfmt` (tab-indented) + `shellcheck`.
- Follow existing `callPackage` patterns in `default.nix` when adding packages.
- Use `meta` attrs (`broken`, `license`, `description`, `homepage`, `maintainers`) on all derivations.
- `_sources/` is auto-generated — never edit manually.
