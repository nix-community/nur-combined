# AGENTS.md

## Repo shape
- NUR package set; almost everything is Nix under `pkgs/*/default.nix`.
- Root wiring lives in `default.nix`, `ci.nix`, `flake.nix`, `overlay.nix`, `overlays/default.nix`, and `maintainers.nix`.
- `default.nix` exports package attrs plus the special attrs `lib`, `modules`, and `overlays`; `ci.nix`/`overlay.nix` strip those specials.
- Current tree has no other repo-local instruction files or OpenCode config; if any appear later, reconcile them here first.

## Commands to use
- Run commands from repo root.
- CI parity evaluation:
```bash
nix-env -f . -qa \* --meta --xml \
  --allowed-uris https://static.rust-lang.org \
  --option restrict-eval true \
  --option allow-import-from-derivation true \
  --drv-path --show-trace \
  -I nixpkgs=$(nix-instantiate --find-file nixpkgs) \
  -I $PWD
```
- Build CI-selected outputs:
```bash
nix-build ci.nix -A cacheOutputs
```
- CI wrapper form used in GitHub Actions:
```bash
nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached ci.nix -A cacheOutputs
```
- Build one package (the narrowest verification step): `nix-build -A <package-attr>`.
- Flake build for a derivation: `nix build .#<package-attr>`.

## Verification order
- For package edits, build the touched attr with `nix-build -A <package-attr>`.
- For changes to `default.nix`, `ci.nix`, `flake.nix`, or overlays, also run `nix-build ci.nix -A cacheOutputs`.
- There is no separate test runner; a single package build is the test equivalent here.

## Repo-specific quirks
- `ci.nix` only caches buildable packages: it filters out `meta.broken`, non-free licenses, and `preferLocalBuild`.
- `kwm` is exported only when `pkgs ? zig_0_16`.
- `jlc-assistant` is marked `meta.broken = true`.
- `ag` and `jyyslide-util` have `doCheck = true`; `deepseek-tui`, `keystroke`, and `pywellen-mcp` disable checks.
- Rust packages need both source `hash` and `cargoHash`.
- Binary repacks such as `lceda-pro` and `vivado-2022_2` preserve their existing `sourceProvenance` / FHS wrapper patterns.

## Editing style
- Keep diffs minimal and focused; do not reformat unrelated files.
- Match the existing indentation and fetch/hash convention in the file you touch.
