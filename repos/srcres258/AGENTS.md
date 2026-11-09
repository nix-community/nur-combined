# AGENTS.md

## Repo shape
- NUR package set; almost everything is Nix under `pkgs/*/default.nix`.
- Root wiring lives in `default.nix`, `ci.nix`, `flake.nix`, `overlay.nix`, `overlays/default.nix`, and `maintainers.nix`.
- `default.nix` exports package attrs plus the special attrs `lib`, `modules`, and `overlays`; `ci.nix`/`overlay.nix` strip those specials.
- Current tree has no other repo-local instruction files or OpenCode config; if any appear later, reconcile them here first.

## Commands to use
- Run commands from repo root.
- Flake is the primary entrypoint; every channel is a locked flake input.
- CI parity evaluation (forces `meta`, which `nix build` never does):
```bash
nix eval --json .#channels.<channel>.packages.x86_64-linux \
  --apply 'pkgs: builtins.mapAttrs (_: p: p.meta) pkgs'
```
- Build CI-selected (buildable + cacheable) outputs for a channel:
```bash
targets=$(nix eval --raw .#channels.<channel>.cacheOutputs.x86_64-linux \
  --apply 'ds: builtins.concatStringsSep " " (map (d: "${d.drvPath}^*") ds)')
nix build --keep-going --print-build-logs --no-link $targets
```
- Channels live in `flake.lock`, so tests are reproducible without NIX_PATH: `nixpkgs-unstable`, `nixos-unstable`, `nixos-25-05` (branch `nixos-25.05`).
- Build one package: `nix build .#<package-attr>`, or per channel `nix build .#channels.<channel>.packages.x86_64-linux.<package-attr>`.
- Legacy entrypoints still work with a plain `<nixpkgs>`: `nix-build -A <package-attr>` and `nix-build ci.nix -A cacheOutputs`.

## Verification order
- For package edits, build the touched attr with `nix build .#<package-attr>`.
- For changes to `default.nix`, `ci.nix`, `flake.nix`, or overlays, also build the channel `cacheOutputs` and run the `meta` evaluation above.
- There is no separate test runner; a single package build is the test equivalent here.

## CI
- GitHub Actions (`build.yml`) builds against **3 nixpkgs channels**: `nixpkgs-unstable`, `nixos-unstable`, and `nixos-25-05` (one matrix leg each), selected through the flake, not `NIX_PATH`.
- `nix build` never evaluates `meta`; CI runs an explicit `nix eval ... --apply (pkgs: ... p.meta)` step because NUR tooling (`nix-env -q --meta`, `nix search`) does. Dropping that step hides broken `meta` attributes behind a green run.
- Flake installables must be derivations or paths, so the `cacheOutputs` list is expanded to one installable per output. Each installable **must** carry the `^*` suffix: a bare `.drv` path is itself a valid store path, so `nix build $drv` silently builds nothing and the leg goes green without building.
- Cache upload is **implicit**: `cachix/cachix-action@v16` runs in its default daemon mode, registering a Nix `post-build-hook` that pushes each *newly built* store path to cache `nur-packages-srcres258`. Its post step only flushes that daemon; there is no explicit `cachix push` step.
- **Keep `Setup cachix` above every build step** (both the iEDA build and the per-channel `cacheOutputs` build). The hook does not exist before the action runs, and daemon mode never scans the store afterwards, so anything built earlier is silently never cached.
- Substituted paths are not re-pushed, so a green run that uploads zero paths can simply mean everything was already cached — not a broken setup. Expect uploads only when something is genuinely rebuilt.
- Pushing requires `secrets.CACHIX_AUTH_TOKEN` / `CACHIX_SIGNING_KEY`; without them the action only warns and CI still passes read-only. Fork PRs receive no secrets, so they cannot write to the cache.
- `Trigger NUR update` is gated to the `nixpkgs-unstable` leg only, otherwise all 3 matrix legs POST the same request. The iEDA build is likewise gated to that leg because it comes from its own flake input and is channel-independent.
- CI runs on PR, push to main/master, daily schedule, and manual dispatch.

## Adding a package
1. Create `pkgs/<name>/default.nix`. Match an existing template below — do not invent new patterns.
2. Register it in `default.nix` with `pkgs.callPackage ./pkgs/<name> { inherit maintainers; }`.
3. Verify with `nix build .#<name>` (and, if the edit touches shared wiring, the channel `meta` evaluation).
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
| Node + Python hybrid | `pi-furry-partner-hd` | `stdenvNoCC` driving upstream build scripts, `buildNpmPackage` runtimes for the test suite, `outputs = [ "out" "bundle" ]`, no `mainProgram` |

## Repo-specific conventions
- **Hash format**: Use SRI format (`hash = "sha256-..."`). Some older packages (`adif-manage`) use bare `sha256` — prefer SRI for new packages.
- **Fetch source**: Prefer `pkgs.fetchFromGitHub` with `rev = "v${version}"`. Use `fetchzip` for binary archives, `fetchurl` for direct URLs.
- **`doCheck`**: Most packages omit it (defaults to on). Only override when tests are known-broken in the sandbox (`keystroke`: `doCheck = false`; `jyyslide-util`: `doCheck = true`).
- Rust packages may need `meta.broken = versionOlder pkgs.rustc.version "X.Y.Z"` if the crate requires a minimum Rust version (`waveql`: ≥1.90.0, `bibox`: ≥1.88.0).
- `bibox` uses `cargoBuildFlags = [ "--ignore-rust-version" ]` to bypass Cargo's MSRV check.
- Electron repacks need `dontConfigure = true; dontBuild = true;` with manual `installPhase`.
- `kwm` uses `dontUseZigCheck = true`.
- All packages must include `meta.mainProgram` (except Python libraries, and extension/data trees such as `pi-furry-partner-hd` which ship no executable).
- **Never filter a fetched source with `lib.cleanSourceWith` / `builtins.path`**: those read the store while evaluating, so CI's clean store fails with `path '…-source.drv' is not valid`. Filter inside a derivation (`runCommand`) or pass the pinned tree as-is.
- Porting an upstream flake output means vendoring its derivation logic (`pi-furry-partner-hd` mirrors `pi-hd-extension`), not calling `builtins.getFlake`; the `ieda` wiring in `default.nix` is the existing exception.
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
