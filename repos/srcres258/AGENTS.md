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

## CI
- GitHub Actions (`build.yml`) evaluates and builds against **3 nixpkgs channels**: `nixpkgs-unstable`, `nixos-unstable`, and `nixos-25.05`.
- Packages are pushed to `cachix` cache `nur-packages-srcres258`. CI triggers NUR index update on success.
- CI runs on PR, push to main/master, daily schedule, and manual dispatch.

## Adding a package
1. Create `pkgs/<name>/default.nix`. Match an existing template below — do not invent new patterns.
2. Register it in `default.nix` with `pkgs.callPackage ./pkgs/<name> { inherit maintainers; }`.
3. Verify with `nix-build -A <name>`.
4. If the package requires rare nixpkgs attrs (e.g., `zig_0_16` for `kwm`), gate it with `pkgs.lib.optionalAttrs`.

### Package templates to copy from

| Type | Reference package | Key traits |
|---|---|---|
| Rust app | `waveql`, `bibox` | `pkgs.rustPlatform.buildRustPackage`, both source `hash` and `cargoHash`, `meta.mainProgram` |
| Python app | `sootty`, `jyyslide-util` | `pythonEnv.buildPythonApplication`, `format = "pyproject"` or `"setuptools"`, `meta.mainProgram` |
| Python library | `simple-toml-configurator` | `pythonEnv.buildPythonPackage`, `pyproject = true`, no `mainProgram` or `platforms` |
| Zig app | `kwm` | `zig_0_16`, `zigDeps` with `fetchDeps`, symlink in `postConfigure` |
| Electron binary repack | `lceda-pro`, `jlc-assistant` | `stdenv.mkDerivation`, `makeWrapper` to electron, `sourceProvenance` in meta, `copyDesktopItems` |
| FHS env wrapper | `vivado-2022_2` | `buildFHSEnv` wrapping `stdenv.mkDerivation`, `patchelf` for ELF fixups |
| Prebuilt JAR | `peerbanhelper` | `stdenvNoCC.mkDerivation`, `makeWrapper` to jdk |

## Repo-specific conventions
- **Hash format**: Use SRI format (`hash = "sha256-..."`). Some older packages (`adif-manage`) use bare `sha256` — prefer SRI for new packages.
- **Fetch source**: Prefer `pkgs.fetchFromGitHub` with `rev = "v${version}"`. Use `fetchzip` for binary archives, `fetchurl` for direct URLs.
- **`doCheck`**: Most packages omit it (defaults to on). Only override when tests are known-broken in the sandbox (`keystroke`: `doCheck = false`; `jyyslide-util`: `doCheck = true`).
- Rust packages may need `meta.broken = versionOlder pkgs.rustc.version "X.Y.Z"` if the crate requires a minimum Rust version (`waveql`: ≥1.90.0, `bibox`: ≥1.88.0).
- `bibox` uses `cargoBuildFlags = [ "--ignore-rust-version" ]` to bypass Cargo's MSRV check.
- Electron repacks need `dontConfigure = true; dontBuild = true;` with manual `installPhase`.
- `kwm` uses `dontUseZigCheck = true`.
- All packages must include `meta.mainProgram` (except Python libraries).
- Indentation is 4 spaces. Match the whitespace style of the file you touch.

## Repo-specific quirks
- `ci.nix` only caches buildable packages: it filters out `meta.broken`, non-free licenses, and `preferLocalBuild`.
- `kwm` is exported only when `pkgs ? zig_0_16` (gated via `pkgs.lib.optionalAttrs` in `default.nix`).
- `jlc-assistant` is marked `meta.broken = true`.
- `peerbanhelper` has a `pkgs/*/default.nix` on disk but is **commented out** in `default.nix` — do not uncomment unless you intend to fix and enable it.
- Binary repacks (`lceda-pro`, `vivado-2022_2`, `jlc-assistant`) preserve their existing `sourceProvenance` / FHS wrapper patterns.
- `adif-manage` uses bare `sha256` (not SRI) — legacy, do not replicate for new packages.

## Editing style
- Keep diffs minimal and focused; do not reformat unrelated files.
- Match the existing indentation and fetch/hash convention in the file you touch.
