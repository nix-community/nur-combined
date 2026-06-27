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
├── default.nix       # Single file: all 3 phases inline
└── AGENTS.md         # ← this file
```

The `default.nix` contains **three derivations** in one file:

```
let
  node_modules = stdenvNoCC.mkDerivation { ... };   # Phase 1: FOD
  piNatives    = rustPlatform.buildRustPackage { ... }; # Phase 2: Rust
in
stdenvNoCC.mkDerivation { ... };                     # Phase 3: final
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

Uses `rustPlatform.buildRustPackage` but **overrides** `buildPhase` to
run Bun's `build-native.ts` script instead of bare `cargo build`. This is
necessary because the upstream napi-rs pipeline:

1. Generates TypeScript declarations (`index.d.ts`, `loader-state.d.ts`)
2. Normalizes the `.node` filename (`pi_natives.linux-x64-gnu.node` → `pi_natives.linux-x64-baseline.node`)
3. Runs `gen-enums.ts` to fix ESM exports and const enums in `index.js`/`index.d.ts`

Using raw `cargo build` + manual rename would miss all three.

### Key attributes

| Attribute | Value | Rationale |
|-----------|-------|-----------|
| `cargoHash` | `sha256-...` | Vendored crate tarballs (502 crates.io deps, zero git deps) |
| `RUSTC_BOOTSTRAP` | `"1"` | Crate uses `#![feature(alloc_error_hook)]` |
| `buildType` | `"ci"` | Uses upstream `[profile.ci]` (thin LTO, faster than fat LTO) |
| `TARGET_VARIANT` | `null` | Auto-detect: AVX2 → modern/v3, else baseline/v2, ARM → native |
| `dontStrip` | `true` | `.node` is a loaded binary addon, stripping may break it |
| `doCheck` | `false` | Tests fail in sandbox (process session isolation) |

### x86_64 CPU variant

`TARGET_VARIANT` 设为 `null`，让上游 `build-native.ts` 自动检测：
- 构建机有 AVX2 → `modern`（`x86-64-v3`）
- 无 AVX2 → `baseline`（`x86-64-v2`）
- ARM64 → `native`

用户可通过以下方式覆盖：
- `nixpkgs.config.gccArch = "x86-64-v4"`（nix.conf 的 `gccarch-x86-64-v4`）
- 直接传 `RUSTFLAGS="-C target-cpu=x86-64-v4"` 或 `TARGET_VARIANT=baseline`

之前硬编码 `TARGET_VARIANT=baseline` 已移除，因为 NUR 包的用户
通常本地构建（不是 CI 缓存分发），自动检测能获得最优性能。
需要缓存一致性的场景可以显式指定。

### Hazards
- **x86_64 baseline vs modern**: Upstream build-native.ts auto-detects
  AVX2 support on the build host. Modern CPUs will fall back to baseline
  at runtime (the loader tries `modern` first, then `baseline`).
- **aarch64**: No variant suffix — just `pi_natives.linux-arm64.node`.

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
- **`dontFixup = true`**: Required because the Nix fixup phase would try
  to strip binaries and patch shebangs in the read-only store path.
  Shebangs are already patched in the build directory.
- **Read-only store**: `$out/lib/oh-my-pi` is read-only. Assets that
  would normally be generated at runtime (stats dashboard build) must
  be pre-generated at build time.

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

4. **Smoke test**:
   ```bash
   nix-build -A oh-my-pi
   result/bin/omp --version
   result/bin/omp --help | head -5
   result/bin/omp-stats --help | head -5
   ls result/lib/node_modules/@oh-my-pi/ | head -5
   ls result/lib/oh-my-pi/packages/natives/native/*.node
   ```

### When upstream changes

- **Rust dependencies added**: Cargo.lock changes → `cargoHash` changes.
  If a Git dependency is added, you'll need `cargoHash` → `cargoLock`
  with `outputHashes`.
- **npm dependencies changed**: `bun.lock` changes → `node_modules`
  hash changes.
- **New generation scripts**: If upstream adds build steps before
  `bun build --compile`, add them to `buildPhase`.
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
| `crates/pi-natives/Cargo.toml` | cdylib crate definition |
| `packages/coding-agent/package.json` | omp bin, exports, types |
| `packages/coding-agent/src/cli.ts` | Entrypoint, bun version check |
| `packages/coding-agent/scripts/build-binary.ts` | Reference for compile flags and entrypoints |
| `packages/coding-agent/scripts/bundle-dist.ts` | Creates dist/cli.js |
| `packages/coding-agent/scripts/generate-docs-index.ts` | Docs index generation |
| `packages/natives/package.json` | native addon wrapper package |
| `packages/natives/scripts/build-native.ts` | napi-rs build script |
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
