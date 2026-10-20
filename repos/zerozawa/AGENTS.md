# AGENTS.md - Zerozawa's NUR Repository

This repository is a **Nix User Repository (NUR)** with package definitions, a small library surface, CI filtering logic, and local `.agents` command/skill metadata.

## Source of Truth

When updating code or documentation, treat these files as authoritative:

- `default.nix` - exported packages plus reserved attrs `lib`, `modules`, `overlays`
- `lib/default.nix` - exported library helpers (currently `fetchPixiv`)
- `flake.nix` - flake outputs (`legacyPackages`, filtered `packages`, `ciJobs`)
- `ci.nix` - CI build/cache filtering rules
- `modules/default.nix` - current modules namespace (placeholder)
- `overlays/default.nix` - current overlays namespace (placeholder)
- `.agents/command/*.md` - repo-local omp command docs
- `.agents/skill/nix-packaging/SKILL.md` - repo-local omp nix-packaging skill
- `.opencode/opencode.jsonc` - OpenCode config and remote `context7` MCP setup
- `pkgs/*/AGENTS.md` - package-level packaging guides (currently `pkgs/banguminet/AGENTS.md`, `pkgs/pctx/AGENTS.md`)

## Current Repository Shape

```text
nur/
├── default.nix              # main export surface
├── flake.nix                # flake outputs and cache config
├── ci.nix                   # CI package/output filtering
├── pkgs/                    # 28 exported package definitions
├── lib/                     # library helpers (currently fetchPixiv)
├── modules/                 # placeholder NixOS modules namespace
├── overlays/                # placeholder overlays namespace
└── .agents/                # local omp command/skill metadata
```

## Current Exports

### Reserved attrs

- `lib`
- `modules`
- `overlays`

### Library helpers

- `fetchPixiv` - configurable Pixiv fetch helper with mirror and extension fallback

### Modules and overlays

- `modules/default.nix` currently exports `{ }`
- `overlays/default.nix` currently exports `{ }`

Do not document modules or overlays as active features unless they have been implemented.

## Package Inventory Summary

The repo currently exports 28 packages from `default.nix`, grouped roughly as:

- SR Vulkan ecosystem: `sr-vulkan` and four model packages
- Desktop readers and clients: `JMComic-qt`, `picacg-qt`, `LoveIwara`
- Media and streaming tools: `StartLive`, `bilibili_live_tui`, `lightnovel-crawler`, `mihomo-smart`
- MCP and developer tools: `agentic-contract`, `context-mode`, `jadx-headless-mcp`, `mcp-cli`, `pctx`, `rea-agents`, `truenas-mcp`, `wakaru`, `wechat-web-devtools-linux`
- Themes and utilities: `grub-theme-yorha`, `sddm-eucalyptus-drop`, `waybar-vd`, `zsh-url-highlighter`, `mikusays`, `fortune-mod-*`

Always derive exact package names from `default.nix`, not from README snippets or memory files.

## Common Build Patterns Actually Used Here

This repo is not limited to one packaging style. Examples worth following:

- `python3Packages.buildPythonApplication` / `buildPythonPackage`
  - Examples: `pkgs/JMComic-qt.nix`, `pkgs/picacg-qt.nix`, `pkgs/sr-vulkan.nix`
- `flutter347.buildFlutterApplication`
  - Example: `pkgs/LoveIwara/default.nix` — JSON pub lock, native source builders, desktop entry, and runtime FFI wrapping
- `buildGoModule`
  - Example: `pkgs/mihomo-smart.nix`
- `buildDotnetModule`
  - Example: `pkgs/banguminet/default.nix` — read `pkgs/banguminet/AGENTS.md` for deps.json regeneration
- `rustPlatform.buildRustPackage`
  - Examples: `pkgs/pctx/default.nix` — read `pkgs/pctx/AGENTS.md` before updating its fixed V8 and Swagger UI inputs — and `pkgs/wakaru.nix`
- `stdenv.mkDerivation` + `gradle.fetchDeps`
  - Example: `pkgs/jadx-headless-mcp/` — Gradle 9.8.0 (`gradle_9`) dependency lockfile in `deps.json`, regenerated via `mitmCache.updateScript`; `jar.nix` exposes the fat jar as `passthru.jar`. REA compiles `bridge/android/ReaJadxBridge.java` against the JAR and rejects any engine whose `rea_jvm_status.engine_reported_version` differs from its `JADX_RELEASE.version` constant, so `pkgs/rea-agents/default.nix` re-pins that constant (version, upstream tag commit, and the digest of the source-built JAR) in `postPatch`; bump `jadxRevision` there whenever jadx moves (see `pkgs/jadx-headless-mcp/AGENTS.md`)

## Repo-Specific Packaging Notes

### Export wiring

- Add new packages to `default.nix` with `pkgs.callPackage`.
- Add new library helpers to `lib/default.nix`.
- Reserved attrs `lib`, `modules`, and `overlays` are not normal package targets.

### CI behavior (`ci.nix` + `.github/workflows/build.yml`)

CI excludes reserved attrs and flattens derivations recursively when `recurseForDerivations = true`.

Filtering behavior:

- `meta.broken = true` -> excluded from CI builds
- unfree licenses -> excluded from build/cache sets
- `preferLocalBuild = true` -> buildable locally but excluded from cache set

The GitHub Actions workflow builds `.#ciJobs.x86_64-linux` with `nix-fast-build`
against the nixpkgs pinned in `flake.lock` (not a channel matrix), so cached
paths match what flake users build locally. Scheduled and manually dispatched
runs run `nix flake update` first and push the bumped `flake.lock` only after
the build against it succeeds.

### Flake behavior (`flake.nix`)

- `legacyPackages.<system>` imports `default.nix`
- `packages.<system>` filters derivations by platform compatibility
- `ciJobs.<system>` exposes the `ci.nix` `cachePkgs` set keyed by package name for `nix-fast-build`
- `nixpkgs` is pinned to `nixpkgs-unstable`
- the flake config also publishes Cachix substituters and trusted keys

### Current implementation quirks worth remembering

- `JMComic-qt` and `picacg-qt` rely on `sr-vulkan-with-models`, not plain `sr-vulkan`
- The full SR Vulkan stack (`sr-vulkan`, models, `JMComic-qt`, and `picacg-qt`) is pinned to Python 3.13 because the upstream 2.0.1.1 `abi3` wheel segfaults in `initSet` under Python 3.14
- `JMComic-qt` 1.3.5 still commits `src/images_rc.py`, so copying `src/` is sufficient; do not assume it shares PicACG's resource-generation change. Its upstream code already handles XDG paths. Keep `smbprotocol` available: upload connection checks import the SMBv3 backend even for local-directory targets, so a GUI-only smoke test misses this dependency. Since 1.3.5 the selection widgets render SVG labels through `PySide6.QtSvg`, which nixpkgs `pyside6` ships; its bundled `curl_cffi` constraint moved to `<=0.16.1` (nixpkgs 0.16.0 satisfies it)
- `picacg-qt` 1.5.5.1 no longer commits `src/images_rc.py`; generate it from `res/images.qrc` with Qt's `rcc -g python` before installation. Its runtime now requires `curl-cffi` and `smbprotocol` instead of `httpx`, and the launcher uses `Setting.GetDBPath()` to seed the database in the application's XDG state directory (`$XDG_STATE_HOME/picacg-qt`, falling back to `~/.local/state`). Keep the installed-resource image check enabled via `doCheck` (the Python builder derives `doInstallCheck` from it)
- `LoveIwara` source-builds with `flutter347` (0.6.1 requires Flutter >= 3.47 per its pubspec SDK pin, and its `pubspec.yaml` now declares `0.6.1+1`, which the `postPatch` version rewrite must match — upstream left it at `0.5.0+3` in the 0.5.1 tag); its derivation patches the sqlite3 hook (`lib/src/hook/compile/description.dart`) to use system SQLite instead of the sandboxed native-asset download and treats `sqlite3_flutter_libs 0.6.0+eol` as an empty compatibility package. The Dio `transformTimeout` enum workaround was dropped when the lock moved to Dio 5.11.0, which provides it. The vendored `pubspec.lock.json` is regenerated from upstream's lock with mirror URLs rewritten to `pub.dev` (`yaml.safe_load` → `json.dumps(indent=2, sort_keys=True)`), which reproduces the committed file byte-for-byte
- `context-mode` is a `bun` + `stdenvNoCC.mkDerivation` package with pre-built bundles; it uses `makeBinaryWrapper` and the built-in `node:sqlite` (Node.js >= 22.5) so `better-sqlite3` is not loaded at runtime
- `fetchPixiv` intentionally uses `fetchurl` with ordered `urls` fallback rather than a single URL
- `banguminet` uses `buildDotnetModule` with a hand-generated `deps.json`; read `pkgs/banguminet/AGENTS.md` before updating
- `wechat-web-devtools-linux` source-builds the commit the rolling `continuous` release points at — upstream deletes the `continuous` branch between Electron milestones, so the release tag, not the branch name, is the stable reference (`master` is a stale NW.js-era line) — mirroring its CI (`tools/setup-wechat-devtools.sh`): 7z-extracts `resources` (app.asar + vsextensions) from the official Windows installer FOD, asar-unpacks, rebuilds native npm modules with `node-gyp --nodedir` (electron 36.6.0 headers for electron-side modules — nodegit, node-pty, @vscode/spdlog, @vscode/sqlite3; node 22.16.0 headers for node-side ones — extract-file-icon, native-keymap, native-watchdog), asar-packs with upstream's unpack globs, then applies the fix-* patches (package name, cli, skill, bootstrap/config, data-path, wcc/wcsc, float-pigment, webview touch-focus/mouse-leave). The Windows installer only ships the `@swc/core-win32-x64-msvc` binding, so `require('@swc/core')` fails with "Failed to load native binding" and the IDE white-screens; the derivation mirrors upstream's `@swc/core-linux-x64-gnu` step (issue #197) by extracting `swc.linux-x64-gnu.node` from the matching npm tarball into `@swc/core/`. nodegit links Electron's OpenSSL dynamically, so nixpkgs `openssl` is copied into `nodegit/vendor/openssl` and `npm_config_openssl_dir` skips the acquireOpenSSL source build. Since 2.02.2608070-2 upstream dropped its bundled node runtime: `bin/node` runs the Electron binary with `ELECTRON_RUN_AS_NODE=1`, so the derivation no longer stages `electron/node` (node headers are still needed for the node-side node-gyp modules). Since 2.02.2608080-2 the data path is unified to `<userData>/app` by prepending upstream `res/scripts/electron_main.js` to `js/electron/main.js` (the fixed `package.json` main), inlined from `tools/fix-data-path.sh`. Desktop entry is a `makeDesktopItem` mirroring upstream `res/deb.desktop` and icons come from upstream `res/icons`; native-module npm deps are pinned by hand-written lockfiles under `pkgs/wechat-web-devtools-linux/npm/` (upstream rebuilds from a floating `npm install` in `tools/rebuild-node-modules.sh` with no manifest)
- `pctx` source-builds its Rust CLI and exposes a separately released Python SDK only as `pctx.passthru.py`; read `pkgs/pctx/AGENTS.md` before updating its V8, Swagger UI, or Python build inputs
- `StartLive` builds the setuptools `startlive` package with upstream's `StartLive:cli` entry point; keep its upstream `requirements.txt` metadata but `dontCheckRuntimeDeps = true` because nixpkgs ships newer PySide6/cryptography/protobuf lines than the artifact pins, and wrap the generated binary for Qt plugin and library paths. Since 1.4.0 the tag ships `startlive/core/constant/_version.py` as a `0.0.0.dev0` placeholder that upstream's CI stamps, so `postPatch` writes the Nix `version` into it
- `rea-agents` source-builds the upstream `morluto/rea` tag `rea-agents-<version>` with its pristine `package-lock.json`; the default `npm run build` runs Turbo `artifacts:skills` → `compile` (metadata check, TypeScript compile, and runtime bundling). `npmFlags = [ "--ignore-scripts" ]` skips install lifecycle scripts: scout confirmed frida's installer only attempts an offline toolchain download, fsevents is Darwin-only, esbuild resolves its locked Linux x64 platform binary without postinstall, and `@lydell/node-pty-linux-x64` ships its prebuilt `.node`. Keep the upstream frida dependency and lock entry unchanged. `HUSKY=0` remains belt-and-braces because lifecycle scripts are skipped; `TURBO_TELEMETRY_DISABLED=1` disables Turbo telemetry. Because that flag also skips `frida`'s `prebuild-install`, `postInstall` unpacks the version-pinned upstream release artifact (`frida-v<napi-v8-linux-x64>.tar.gz`) into `node_modules/frida/build/frida_binding.node` — the path `bindings` resolves — after asserting the locked `frida` version matches `fridaVersion`, so a lockfile bump fails the build instead of silently pairing JS with a stale binding. `postInstall` prunes the checkout to the published runtime surface (`dist`, `skills`, `bridge`, `scripts`, `native`, `third_party`, `licenses`, `node_modules`, and runtime metadata/notice files). The JS is compiled from TS source; upstream's `@lydell/node-pty-linux-x64` `pty.node` and other native modules need `autoPatchelfHook` + `stdenv.cc.cc.lib`. REA rejects Python environments that are not exactly pwntools 4.15.0 / pyelftools 0.33 / unicorn 2.1.2, so the package builds a dedicated `python313` package set overriding pyelftools (sdist) and unicorn (manylinux wheel, loaded via ctypes) and pins it plus every `REA_*` tool env var via `wrapProgram --set-default` on `$out/bin/rea{,-agents}` (npmInstallHook's bins exec `node scripts/rea.mjs` directly, so wrapping the `.mjs` does not work). Two variables deliberately keep their ambient names because REA reads exactly those and ships no `REA_`-prefixed alias: `GHIDRA_INSTALL_DIR` and `JAVA_HOME` (also the names the Ghidra launcher and the jadx Java probe expect). `REA_SIGROK_COMMAND` points at `sigrok-cli` 0.7.2 imported from the last nixpkgs revision that carried it (`builtins.fetchTarball` + pure-eval `system`, derivation substituted from cache.nixos.org) because `src/signals/SigrokRecordingProvider.ts` admits exactly the `sigrok-cli 0.7.2` banner plus `libsigrokdecode` and nixpkgs ships 0.8.0; `REA_PWNDBG_GDB` points at the packaged `gdb` so the pwndbg bridge never depends on envfs' `/usr/bin/gdb` (pwndbg itself is deliberately unwired — REA demands exactly 2026.09.15, absent from nixpkgs — as are the proprietary IDA/Hopper/JEB providers). `doInstallCheck` runs the version-gate drift alarm: `rea doctor --provider ghidra --provider jadx --format json` (REA's own policy for ghidra release line, JDK bounds, jadx jar, node runtime; a drifted provider flips its exit code) plus hand-rolled asserts mirroring bridge constants doctor does not cover — exact pwntools/pyelftools/unicorn distributions, mitmproxy 12.2.3 profile, binwalk 3.1.x / unblob 26.6.x lines, apktool >= 2.7.0, the sigrok banner/libsigrokdecode pair, and loading the frida binding through `node`. Update the hand-rolled constants when bumping `version` — they come from upstream `bridge/` and `dist/` policy files. Since 6.7.0 the process-ownership provider spawns `ps` from `PATH`, so `procps` is wrapped onto the launcher `PATH` and placed in `nativeBuildInputs` for the installCheck doctor run. `postPatch` also rewrites REA's audited jadx-headless-mcp constants (`src/android/JadxRelease.ts`): the version becomes the packaged `jadx-headless-mcp.version`, the sha256 becomes the digest of the source-built JAR (computed during the build), and the revision comes from `jadxRevision` — bump that alongside any jadx update, otherwise Android operations fail at runtime while the build and doctor stay green.

## Quick Commands

```bash
# Build a package from default.nix
nix-build -A JMComic-qt

# Build from flake output
nix build .#mcp-cli
# Build the PCTX CLI and its passthru Python SDK
nix build .#pctx
nix build .#pctx.py

# Build jadx-headless-mcp and get the absolute path of its fat jar
nix build .#jadx-headless-mcp
nix build .#jadx-headless-mcp.jar --print-out-paths

# Build what CI caches
nix-build ci.nix -A cacheOutputs

# Inspect flake outputs
nix flake show

# Check nixpkgs version in the current channel setup
nix-instantiate --eval -E '(import <nixpkgs> {}).lib.version'
```

## `.agents` Inventory

### Commands

- `.agents/command/build.md`
- `.agents/command/check.md`
- `.agents/command/commit.md`
- `.agents/command/update.md`
- `.agents/command/update-all.md`

These should stay aligned with real attr names from `default.nix` and real workflows from `ci.nix`, `flake.nix`, and package definitions.

### Skills

- `.agents/skill/nix-packaging/SKILL.md`

This skill should stay grounded in the packaging styles actually present in this repo, not only generic nixpkgs examples.

### Legacy `.opencode` Config

- `.opencode/opencode.jsonc` configures the provider and a remote `context7` MCP server.
- `.opencode/package.json` currently depends on `@opencode-ai/plugin`.
- `.opencode/.gitignore` excludes local dependency and lockfile state.

## Documentation Maintenance Rules

Update docs when any of the following changes:

- package exports in `default.nix`
- library exports in `lib/default.nix`
- CI behavior in `ci.nix` or `.github/workflows/build.yml`
- flake outputs or cache settings in `flake.nix`
- local omp commands, skills, or config under `.agents/`

Specific expectations:

- `README.md` should describe the current export surface and user-facing usage.
- `AGENTS.md` should describe contributor/agent workflow and source-of-truth files.
- `.agents/command/*.md` should describe current commands using actual attr names and workflows.
- `.agents/skill/nix-packaging/SKILL.md` should reflect current repo packaging patterns.

## Package `description` Rule

Every exported package's `meta.description` must match the upstream project's own
one-line pitch — never write one yourself from memory or from the package code.

When updating a package, and periodically for all packages:

1. Open the upstream repo (GitHub / GitLab / other code platform) README.
2. Take the first line or first few lines — the project's own tagline/slogan.
3. Copy the most concise sentence verbatim into `meta.description` (trim trailing
   punctuation if needed, keep the wording identical).
4. If the current `description` drifted, is stale, or never matched upstream,
   replace it with the verbatim upstream line.

Do not paraphrase, translate, or compose descriptions yourself.

## Common Pitfalls

1. **Documenting from memory instead of code**
   - Re-read `default.nix`, `lib/default.nix`, and `.agents/` before editing docs.

2. **Treating placeholders as implemented features**
   - `modules` and `overlays` are currently empty placeholders.

3. **Using stale package lists**
   - Derive package names from `default.nix`, not from old README tables or update scripts.

4. **Forgetting CI/cache filters**
   - A package being exported does not automatically mean it is cacheable.

5. **Over-generalizing packaging guidance**
   - Match the builder and style already used by the closest package in this repo.
