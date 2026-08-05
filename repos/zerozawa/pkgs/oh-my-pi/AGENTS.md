# oh-my-pi (omp) — Nix Packaging Guide

This document captures the architecture, rationale, and pitfalls of the
source-based Nix packaging for **oh-my-pi** (the `omp` AI coding agent).

Read this **before** bumping versions, changing build steps, or debugging
failures. The packaging is unusually complex (Rust native addon + Bun
workspace monorepo + generated assets), and skipping context here will
waste hours re-deriving the same lessons.

---

## Architecture Overview

```text
pkgs/oh-my-pi/
├── default.nix            # Single file: all 4 phases inline
├── pack-crx3.py           # Phase 4: CRX3 packer for the browser relay extension
├── browser-relay-key.pem  # Phase 4: throwaway RSA key pinning the CRX extension ID
└── AGENTS.md              # ← this file
```

The `default.nix` contains **four derivations** in one file:

```
let
  node_modules          = stdenvNoCC.mkDerivation { ... };    # Phase 1: FOD
  piNatives             = rustPlatform.buildRustPackage { ... }; # Phase 2: Rust
  browserRelayExtension = stdenvNoCC.mkDerivation { ... };    # Phase 4: CRX3 ext
in
stdenvNoCC.mkDerivation { ... };                              # Phase 3: final
```

The file is intentionally monolithic (not split into submodules) because
the phases share `src`, version, and platform mappings. Splitting them
would require duplicating those or adding a shared `common.nix`.

---

## Phase 1: node_modules — Fixed-Output Derivation (FOD)

### Purpose
Pre-fetch all npm dependencies (`bun install`) into a content-addressed
store path. This is the standard Nix pattern for JavaScript projects.

### Key attributes

| Attribute | Value | Rationale |
|-----------|-------|-----------|
| `outputHashMode` | `recursive` | Directory output, hashed as a whole |
| `dontFixup` | `true` | Must not modify store paths in FOD |
| `bun install` flags | `--frozen-lockfile --ignore-scripts --cpu="*" --os="*"` | Deterministic; no postinstall; cross-platform |

### Build command
```bash
bun install --cpu="*" --os="*" --frozen-lockfile --ignore-scripts --no-progress
```

### Install command
```bash
find . -type d -name node_modules -exec cp -R --parents {} $out \;
```

### Updating
1. Change `version` and `src.hash`
2. Set `outputHash = lib.fakeHash`
3. Build: `nix-build -A oh-my-pi.node_modules`
4. Replace `outputHash` with the real hash from the error message

### Hazards
- **Do NOT** run `bun install` without `--ignore-scripts` — puppeteer,
  onnxruntime, sherpa-onnx all try to download platform binaries at
  install time.
- **Do NOT** skip the `find ... -name node_modules` pattern — Bun
  workspace hoists packages into nested `node_modules` under
  `packages/*/node_modules` and `node_modules/.bun/`. A flat copy of
  only the root `node_modules` will miss workspace symlinks.
- `--cpu="*" --os="*"` prevents Bun from filtering platform-specific
  optional deps (needed for `@oh-my-pi/pi-natives-linux-x64` etc).

---

## Phase 2: pi-natives — Rust Native Addon

### Purpose
Build the N-API native addon (`pi_natives.linux-x64-baseline.node`) from
the upstream Rust workspace. This addon provides grep, ripgrep, clipboard,
image processing, PTY, syntax highlighting, and shell operations.

### Build approach

Uses `rustPlatform.buildRustPackage` with the **default** `cargo build`
(via `cargoBuildFlags = ["-p", "pi-natives"]`). No `buildPhase` override.

**Background**: Upstream ≤17.1.5 used `build-native.ts` (napi-rs CLI) to
build the addon. Upstream ≥17.1.6 migrated to `bazel-natives.ts` (Bazel
build system) — see `BUILD.bazel` at repo root and `crates/pi-natives/`
for the new crate location. Bazel is incompatible with the Nix sandbox
(requires network for toolchain downloads), so we bypass it entirely
and use bare `cargo build` + manual rename in `installPhase`.

The JS/TS loader files (`index.js`, `loader-state.js`, `index.d.ts`,
`desktop.js`, `desktop.d.ts`, `embedded-addon.js`) are checked into
`packages/natives/native/` in source and copied verbatim in `installPhase`.
They do NOT need regeneration — `gen-enums.ts` is dev-only for API changes.

### Key attributes

| Attribute | Value | Rationale |
|-----------|-------|-----------|
| `cargoHash` | `sha256-...` | Vendored crate tarballs (502 crates.io deps, zero git deps) |
| `RUSTC_BOOTSTRAP` | `"1"` | Crate uses `#![feature(alloc_error_hook)]` |
| `buildType` | `"ci"` | Uses upstream `[profile.ci]` (thin LTO, faster than fat LTO) |
| `dontStrip` | `true` | `.node` is a loaded binary addon, stripping may break it |
| `doCheck` | `false` | Tests fail in sandbox (process session isolation) |

### x86_64 CPU variant

Variant detection happens in `installPhase` via `/proc/cpuinfo`:
- 构建机有 AVX2 → `modern`（`x86-64-v3`）
- 无 AVX2 → `baseline`（`x86-64-v2`）
- ARM64 → `native`

At runtime, the loader (`loader-state.js`) tries `modern` first, then
falls back to `baseline`. So producing `modern` on AVX2-capable build
machines is fine — non-AVX2 CPUs will fall through to the `baseline`
candidate (which won't exist and will error, but on AVX2 machines this
isn't an issue).

用户可通过以下方式覆盖：
- `nixpkgs.config.gccArch = "x86-64-v4"`（nix.conf 的 `gccarch-x86-64-v4`）
- 直接传 `RUSTFLAGS="-C target-cpu=x86-64-v4"` 或 `TARGET_VARIANT=baseline`

`TARGET_VARIANT` env var is respected in the old `build-native.ts` but
not used in the cargo-only path — variant is always determined by
`/proc/cpuinfo` at install time.

### Hazards
- **x86_64 baseline vs modern**: InstallPhase auto-detects AVX2 on the
  build host. The loader tries `modern` first, then `baseline`. On a
  non-AVX2 runtime machine loading a `modern`-only build, the loader
  will fail to find a `baseline` variant — ensure the build machine has
  AVX2 or force `baseline` via installPhase edit.
- **aarch64**: No variant suffix — just `pi_natives.linux-arm64.node`.
- **Bazel incompatibility**: Upstream ≥17.1.6 uses `bazel-natives.ts`
  which requires Bazel. We bypass Bazel entirely with cargo build. If
  upstream changes the Rust workspace structure again, the cargo build
  may need `cargoBuildFlags` or `buildPhase` adjustments.

---

## Phase 3: Final Package (Source Tree Install)

### Purpose
Install a complete source tree (`$out/lib/oh-my-pi`) with all workspace
packages, generated assets, native addon, and `node_modules`, plus
`bin/omp` and `bin/omp-stats` wrappers.

### Install layout

```text
$out/
├── bin/
│   ├── omp                  # makeBinaryWrapper → bun → dist/cli.js
│   └── omp-stats            # makeBinaryWrapper → bun → src/index.ts
├── lib/
│   ├── oh-my-pi/
│   │   ├── package.json     # Workspace root
│   │   ├── bun.lock
│   │   ├── node_modules/    # All npm deps (from FOD)
│   │   ├── packages/        # 15 workspace packages
│   │   │   ├── coding-agent/dist/cli.js    # Pre-built CLI bundle
│   │   │   ├── stats/src/index.ts          # omp-stats entry
│   │   │   ├── natives/native/
│   │   │   │   ├── pi_natives.*.node       # Rust addon
│   │   │   │   ├── index.js               # JS loader
│   │   │   │   ├── index.d.ts             # TypeScript types
│   │   │   │   └── loader-state.js         # Runtime addon resolver
│   │   │   └── ... (agent, ai, tui, utils, etc.)
│   │   └── src/             # Generated assets embedded at build time
│   └── node_modules/
│       └── @oh-my-pi → ../oh-my-pi/node_modules/@oh-my-pi  # Exposure for consumers
```

### Build phases (in order)

| Step | Phase | Command | Output | Failure mode |
|------|-------|---------|--------|----------------|
| 1 | configure | `cp -R ${src}/. .` | Source tree | — |
| 2 | configure | `substituteInPlace` (×2) | Patched version checks | Bun version mismatch |
| 3 | configure | `cp -R ${node_modules}/. .` | node_modules | — |
| 4 | configure | `cp ${piNatives}/native/*` | Native addon in place | Wrong filename |
| 5 | build | `generate-client-bundle.ts --generate` | `embedded-client.generated.txt` | Stats dashboard empty |
| 6 | build | `generate-docs-index.ts --generate` | `docs-index.generated.txt` | omp:// docs missing |
| 7 | build | `gen:tool-views` | `tool-views.generated.js` | HTML export broken |
| 8 | build | `bundle-dist.ts` | `dist/cli.js` | `omp` command fails |
| 9 | install | Tree copy + overlays | Full install tree | — |

### Version check patches

nixpkgs ships `bun` v1.3.13, but oh-my-pi requires `>=1.3.14`. Two
patches in `configurePhase` work around this:

```nix
# 1. Downgrade error to warning
substituteInPlace packages/coding-agent/src/cli.ts \
  --replace-fail 'error: Bun runtime must be >= ' 'warn: Bun runtime must be >= '

# 2. Prevent process.exit(1) after the warning
substituteInPlace packages/coding-agent/src/cli.ts \
  --replace-fail 'process.exit(1)' 'process.exit(0)'

# 3. Override MIN_BUN_VERSION to match nixpkgs
substituteInPlace packages/utils/src/dirs.ts \
  --replace-fail 'engines.bun.replace(/[^0-9.]/g, "")' '"1.3.13"'
```

This pattern is adapted from nixpkgs' `opencode` package, which has the
exact same issue (bun 1.3.13 vs upstream's 1.3.14 requirement).

### Wrapper design

Both `bin/omp` and `bin/omp-stats` are `makeBinaryWrapper` wrappers over
`${bun}/bin/bun`, NOT standalone `bun build --compile` binaries.

| Wrapper | Target | Reason |
|---------|--------|--------|
| `omp` | `dist/cli.js` | Bundled CLI entrypoint (size varies per version) |
| `omp-stats` | `src/index.ts` | TypeScript source (Bun transpiles on the fly) |

Not using `bun build --compile` (standalone binary) was a deliberate
choice: a compiled binary would embed all sources in an inaccessible
bunfs, losing the `@oh-my-pi/*` package surface for downstream Nix
consumers.

### Hazards

- **`bundle-dist.ts` resets generated assets**: It calls `--reset` on
  `generate-client-bundle.ts` in a `finally` block, which empties
  `embedded-client.generated.txt`. This is EXPECTED — the bundle embeds
  the stats data internally. The `omp-stats` wrapper reads from
  `src/index.ts` directly, which checks the (empty) generated file and
  falls back to the compiled-in version from `dist/cli.js`.
- **`postPatch` runs too early**: The file `packages/coding-agent/src/cli.ts`
  doesn't exist at `postPatch` time because the source is only copied in
  `configurePhase`. All patching MUST happen in `configurePhase`.
- **Selective fixup (not `dontFixup`)**: The final derivation uses
  `dontPatchElf = true` + `dontStrip = true` + `autoPatchelfHook` +
  `autoPatchelfIgnoreMissingDeps = [ "*" ]` instead of blanket `dontFixup`.
  This preserves `$ORIGIN` RPATH entries in pre-built `.node` files (from
  npm packages like `onnxruntime-node`, `sherpa-onnx`, `@img/sharp-*`,
  `lightningcss`, `@rolldown/binding`, `@napi-rs/*`, `@tailwindcss/oxide`,
  `@anush008/tokenizers`) while letting `autoPatchelfHook` add
  `libstdc++.so.6` and `libgcc_s.so.1` to RPATH. `autoPatchelfIgnoreMissingDeps`
  prevents failures for runtime-loaded libraries (e.g. `libonnxruntime.so.1`,
  `libsherpa-onnx-c-api.so`, `libvips-cpp.so`) that ship alongside the `.node`
  files. `dontStrip` prevents stripping of `.node` addon files.
  `stdenv.cc.cc.lib` is added to `buildInputs` for `libstdc++` resolution;
  `stdenv` (regular, with cc) is passed alongside `stdenvNoCC` for this purpose.
- **Musl sharp builds must be pruned before `fixupPhase`**: the FOD runs
  `bun install --cpu="x64" --os="linux"` (x86_64-linux only), but bun
  does NOT filter optional deps by the `libc` field — `@img/sharp`'s
  glibc/musl variants share the same `os`/`cpu`, so
  `@img/sharp-libvips-linuxmusl-*` is still installed. `autoPatchelfHook`
  then resolves the NEEDED `libvips-cpp.so` of `@img/sharp-linux-x64` to
  the *musl* copy (its dir wins the search), rewriting the RUNPATH to the
  musl libvips; on glibc hosts the dlopen fails with
  `libc.musl-x86_64.so.1: cannot open shared object file`. Symptom: the
  local tiny-title worker crashes (`tiny-title: worker returned error`)
  and sessions get no titles. The `installPhase` prunes
  `@img/sharp-libvips-linuxmusl-*` and `@img/sharp-linuxmusl-*` before
  `fixupPhase` so autoPatchelfHook only finds the glibc libvips.
  The package is intentionally x86_64-linux only (`meta.platforms`), so
  the platform-specific bun flags don't break the shared FOD hash on
  other architectures; drop the restriction only if you also re-allow
  `--cpu="*" --os="*"` or make the FOD hash per-system.
- **Read-only store**: `$out/lib/oh-my-pi` is read-only. Assets that
  would normally be generated at runtime (stats dashboard build) must
  be pre-generated at build time.

---

## Phase 4: browserRelayExtension — CRX3 for home-manager

### Purpose

Source-builds the omp browser relay extension
(`packages/browser-relay/extension/`) and packs it into a **CRX3** file so
home-manager's `programs.chromium.extensions.*.crxPath` can install it.
Exposed as `passthru.browserRelayExtension`; the derivation's out path IS
the `.crx` file.

### Why a CRX packer

HM's `crxPath` is written into
`<configDir>/External Extensions/<id>.json` as
`{ external_crx, external_version }`, and Chromium's `external_crx`
installer only accepts **signed CRX3** files — the upstream release asset
`omp-browser-relay-extension.zip` is a bare zip and would be rejected.
nixpkgs has no CRX packer, so `pack-crx3.py` hand-rolls the format:
deterministic zip → `SignedData{crx_id}` → RSA PKCS#1 v1.5/SHA-256
signature → `CrxFileHeader` protobuf → `"Cr24"` header.

### The committed key (`browser-relay-key.pem`)

A committed **throwaway** RSA-2048 key. The CRX extension ID is derived
from the public key (`sha256(SPKI DER)[:16]`, nibbles → `a..p`), so the
key IS the extension's identity. It must stay fixed or every rebuild
would mint a new ID and break the HM config's `id`. It authenticates
nothing else — the CRX is installed locally from your own store path via
your own HM config; there is no remote update channel trusting this key.
Current ID: `lgcklnhmbedbnkhgepghbnojilibgani` (hardcoded as
`extensionId`; the build fails if the key no longer derives it).

### Build steps

Mirrors upstream `scripts/build-extension.ts` minus the zip/embed steps:

1. `bun build extension/background.ts --outdir=dist --target=browser`
   (run from the package root — a relative entrypoint keeps the banner
   comment byte-identical to the release-zip `background.js`; verified
   identical for v17.2.9 with nixpkgs bun 1.3.13)
2. copy `manifest.json`, `options.html`, `options.js` verbatim
3. `pack-crx3.py dist browser-relay-key.pem $out --expect-id …
   --expect-version …`

`version` is the extension **manifest** version (`0.1.0`), not the omp
release version — HM writes it into `external_version`, and Chromium
compares it against the installed manifest version.

### home-manager usage

```nix
let
  relayExt = pkgs.nur.repos.zerozawa.oh-my-pi.passthru.browserRelayExtension;
in
{
  programs.chromium.extensions = [
    {
      inherit (relayExt) id version;
      crxPath = relayExt;
    }
  ];
}
```

Chromium copies/extracts the CRX into the mutable profile
(`~/.config/chromium/Default/Extensions/<id>/<version>/`) at startup, so
the immutable store path is only read at install/update time; the HM
generation keeps it GC-alive. A version bump changes the store path and
`external_version`, and Chromium upgrades the extension on next start.

### Updating

No extra FOD hash — the derivation shares the main `src`. If upstream
bumps the extension's manifest version, the build fails at
`--expect-version`: bump `browserRelayExtension.version` to match. Only
rotate `browser-relay-key.pem` deliberately (changes the extension ID;
update `extensionId` accordingly).

---

## Updating the Package

### Full update checklist

When bumping `version` from `X.Y.Z` to `A.B.C`:

```
[src hash]  →  [node_modules hash]  →  [cargoHash]
    1                   2                     3
```

1. **Source hash**: Change `version`, set `src.hash = lib.fakeHash`,
   build (`nix-build -A oh-my-pi`), replace with real hash.

2. **node_modules hash**: Set `node_modules.outputHash = lib.fakeHash`,
   build (`nix-build -A oh-my-pi.node_modules` or the whole package),
   replace.

3. **cargoHash**: Set `piNatives.cargoHash = lib.fakeHash`,
   build (`nix-build -A oh-my-pi.piNatives`), replace.

4. **browserRelayExtension**: Build `nix build .#oh-my-pi.browserRelayExtension`.
   No hash to refresh (shares `src`); it fails only if upstream bumped the
   extension manifest version — then bump `browserRelayExtension.version`.

5. **Smoke test + ELF verification**:
   ```bash
   nix-build -A oh-my-pi
   result/bin/omp --version
   result/bin/omp --help >/dev/null 2>&1 && echo "omp help OK"
   result/bin/omp-stats --help >/dev/null 2>&1 && echo "omp-stats help OK"
   ls result/lib/node_modules/@oh-my-pi/ | head -5
   ls result/lib/oh-my-pi/packages/natives/native/*.node
   # Verify all onnxruntime .node files have self-dir in RPATH
   for f in $(find result -name 'onnxruntime_binding.node' -path '*/linux/x64/*'); do
     dir=$(dirname "$f")
     patchelf --print-rpath "$f" | grep -qF "$dir" || echo "MISSING self-dir RPATH: $f"
   done
   # Verify each binding's NEEDED matches the local renamed libonnxruntime
   for f in $(find result -name 'onnxruntime_binding.node' -path '*/linux/x64/*'); do
     dir=$(dirname "$f")
     needed=$(readelf -d "$f" | grep 'NEEDED.*libonnx' | sed 's/.*\[//;s/\]//')
   done
   ```

6. **Runtime ONNX check**: After installing the new build, restart omp and
   check `~/.omp/logs/` for any `libonnxruntime`, `libstdc++`, `VERS_`,
   or `cannot open shared object file` errors. A clean log means the ELF
   patching pipeline is intact.

### When upstream changes

- **Rust dependencies added**: Cargo.lock changes → `cargoHash` changes.
  If a Git dependency is added, you'll need `cargoHash` → `cargoLock`
  with `outputHashes`.
- **npm dependencies changed**: `bun.lock` changes → `node_modules`
  hash changes.
- **onnxruntime-node version changes**: If the lockfile resolves new
  onnxruntime-node versions (e.g. a dependency upgrades from 1.24.3 →
  1.27.0), the SONAME dedup logic in `installPhase` will automatically
  handle the new copies (unique SONAME per directory). However, verify
  step 5 above — confirm the new versions don't break API compatibility
  or introduce new shared library dependencies not covered by
  `autoPatchelfIgnoreMissingDeps`.
- **Bazel migration**: Upstream ≥17.1.6 replaced `build-native.ts` with
  `bazel-natives.ts`. If future versions change the build system again,
  check whether `bazel build` or the old `cargo build` approach still
  works. The cargo workspace still uses standard Cargo.toml at root and
  `crates/pi-natives/`, so bare cargo build should continue to work.
- **Bun version required changes**: If upstream bumps MIN_BUN_VERSION
  significantly (e.g., to 1.5), check if nixpkgs has caught up. If not,
  update the `substituteInPlace` values.

### Build times

| Phase | Time (x86_64-linux) |
|-------|--------------------|
| node_modules FOD | ~30s (cached) |
| Rust native addon | ~60s (cached) |
| Final package | ~25s (cached) |
| **Total (cold)** | **~3 min** |
| **Total (cached)** | **~1 min** |

---

## Troubleshooting

### Problem: `Bun runtime must be >= 1.3.14`

The `substituteInPlace` patches in `configurePhase` weren't applied.
Check:
- Is the patching in `configurePhase` (not `postPatch`)?
- Does `packages/coding-agent/src/cli.ts` exist at that point?
  (Only after `cp -R ${src}/. .`)

### Problem: `Module not found "dist/cli.js"`

`bundle-dist.ts` either didn't run or failed. Check build logs for:
```
Bundled coding-agent CLI to dist/cli.js (9.91MB)
```
If missing, the `|| true` at the end of the command swallowed an error.
Remove `|| true` temporarily to see the real failure.

### Problem: `EACCES: permission denied, mkdir 'target'`

The napi-rs build script tries to create `target/` in the source root.
Fix: `preBuild` must run `chmod -R u+w .` and set
`CARGO_TARGET_DIR=$TMPDIR/cargo-target`.

### Problem: native addon not loading at runtime

- Check that `pi_natives.*.node` exists in `packages/natives/native/`
- Check that `loader-state.js` and `index.js` are present
- The loader searches multiple paths; run with `PI_DEBUG_STARTUP=1` to
  see which path it's trying

### Problem: `hash mismatch in fixed-output derivation`

Expected when bumping versions. Follow the update checklist above.

---

## Appendix: Key Upstream Files Referenced

| File | Role |
|------|------|
| `package.json` | Bun workspace, catalog deps, packageManager version |
| `bun.lock` | Lockfile (binary) |
| `Cargo.toml` | Rust workspace, patches, profiles |
| `Cargo.lock` | 502 crates.io dependencies |
| `crates/pi-natives/Cargo.toml` | cdylib crate definition (was under packages/natives/ before 17.1.6) |
| `BUILD.bazel` | Bazel build definitions (not used in Nix build — cargo build used instead) |
| `packages/coding-agent/package.json` | omp bin, exports, types |
| `packages/coding-agent/src/cli.ts` | Entrypoint, bun version check |
| `packages/coding-agent/scripts/build-binary.ts` | Reference for compile flags and entrypoints |
| `packages/coding-agent/scripts/bundle-dist.ts` | Creates dist/cli.js |
| `packages/coding-agent/scripts/generate-docs-index.ts` | Docs index generation |
| `packages/natives/package.json` | native addon wrapper package |
| `packages/natives/scripts/bazel-natives.ts` | Bazel native build driver (bypassed — cargo used instead) |
| `packages/natives/scripts/gen-enums.ts` | Dev-only TS enum generation (checked-in files used instead) |
| `packages/natives/scripts/embed-native.ts` | Creates tar.gz archive for standalone binary (NOT used here) |
| `packages/natives/native/loader-state.js` | Runtime addon resolution |
| `packages/stats/package.json` | omp-stats entry |
| `packages/stats/scripts/generate-client-bundle.ts` | Stats dashboard generation |
| `packages/collab-web/scripts/build-tool-views.ts` | HTML export tool views |
| `packages/utils/src/dirs.ts` | MIN_BUN_VERSION source |

## Appendix: Reference: opencode Pattern

The version check relaxation pattern was taken from nixpkgs' `opencode`
package. If you need to adapt similar version checks in the future:

```nix
substituteInPlace packages/script/src/index.ts \
  --replace-fail \
    'throw new Error(...)' \
    'console.warn(...)'
```

Opencode also ships two canonicalization scripts (`canonicalize-node-modules.ts`
and `normalize-bun-binaries.ts`) that oh-my-pi does NOT need — oh-my-pi's
node_modules tree is simpler and works without them.
