---
name: nix-packaging
description: Use this when writing or modifying Nix package definitions and related repo exports in this NUR repository.
---

## Use this when

- Creating a new package under `pkgs/`
- Updating an exported package version or hash
- Fixing a build/runtime issue in an existing derivation
- Adding or updating a library helper in `lib/`
- Wiring exports through `default.nix` or `lib/default.nix`

## Repository-specific ground rules

- `default.nix` is the source of truth for exported packages.
- `lib/default.nix` is the source of truth for library helpers and currently exports `fetchPixiv`.
- `modules/default.nix` and `overlays/default.nix` are placeholders right now; do not document them as populated unless you add real entries.
- CI behavior comes from `ci.nix`, not from guesswork.

## Packaging styles actually used in this repo

### Python applications and packages

Used heavily for GUI apps and helpers.

Examples:

- `pkgs/JMComic-qt.nix`
- `pkgs/picacg-qt.nix`
- `pkgs/sr-vulkan.nix`

Common patterns:

- `python3Packages.buildPythonApplication`
- `python3Packages.buildPythonPackage`
- wrapper scripts for GUI entrypoints
- Vulkan or site-packages symlink setup in `postInstall`

### Flutter applications

Example: `pkgs/LoveIwara/default.nix`

Use `flutter341.buildFlutterApplication` for reproducible Linux desktop builds:

- convert and check in upstream `pubspec.lock` as `pubspec.lock.json`
- use `customSourceBuilders` when Dart native-asset hooks attempt sandboxed downloads
- put dynamically loaded FFI libraries in `runtimeDependencies`
- install the upstream desktop entry and icon in `postInstall`
- launch the built GUI to verify native plugins and runtime libraries

### Rust packages

Example: `pkgs/waybar-vd/default.nix`

```nix
rustPlatform.buildRustPackage rec {
  pname = "...";
  version = "...";

  cargoLock.lockFile = ./Cargo.lock;
  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';
}
```

### Go packages

Example: `pkgs/mihomo-smart.nix`

```nix
buildGoModule rec {
  pname = "...";
  version = "...";
  vendorHash = "sha256-...";
}
```

### npm packages

Example: `pkgs/codegraph.nix`

```nix
buildNpmPackage rec {
  pname = "...";
  version = "...";
  npmDepsHash = "sha256-...";
  npmBuildScript = "build";
}
```

### bun + `stdenvNoCC` packages

Example: `pkgs/mcp-cli.nix`

This repo also contains packages that:

- prebuild dependency trees as fixed-output derivations
- use `bun install --frozen-lockfile`
- compile a final CLI binary with `bun build --compile`

### Generic derivations

Examples:

- `pkgs/grub-theme-yorha.nix`

Use `stdenv.mkDerivation` or `stdenvNoCC.mkDerivation` for asset packages, extracted binaries, or custom build workflows.

## Export wiring patterns

### Package export in `default.nix`

```nix
some-package = pkgs.callPackage ./pkgs/some-package.nix { };
```

### Library export in `lib/default.nix`

```nix
{ pkgs }:
{
  someHelper = pkgs.callPackage ./someHelper/default.nix { };
}
```

## Current repo-specific examples worth imitating

- `JMComic-qt` / `picacg-qt`: Python GUI packaging plus runtime wrapping
- `LoveIwara`: source-built Flutter GUI with offline pub dependencies, system SQLite, libmpv runtime wrapping, and upstream desktop integration
- `sr-vulkan`: model composition through `sr-vulkan-models`
- `deskbrid`: Rust package whose compositor helper tools stay on PATH at runtime — no wrapper
- `fetchPixiv`: helper-style library export using `fetchurl` fallback URLs

## Hash techniques

### Build once with a fake hash

```nix
hash = lib.fakeHash;
```

Then rebuild and copy the real hash from the failure output.

### Prefetch helpers

```bash
nix-prefetch-url --unpack <url>
nix-prefetch-github owner repo --rev v1.0.0
```

## Checklist

- [ ] Export wiring updated in `default.nix` or `lib/default.nix` if needed
- [ ] Runtime behavior checked for wrapped GUI / CLI tools
- [ ] Docs updated if package inventory or repo behavior changed

## oh-my-pi specific: ELF patching

`oh-my-pi` is a Bun monorepo with pre-built native Node.js addons from npm
(onnxruntime-node, sherpa-onnx, @img/sharp, etc.). These `.node` and `.so`
files need special ELF handling:

- **selective fixup** (`dontPatchElf = true` + `dontStrip = true` +
  `autoPatchelfHook`) replaces the old blanket `dontFixup = true`
- **`stdenv` (with cc) alongside `stdenvNoCC`** to access `stdenv.cc.cc.lib`
  for `libstdc++.so.6` resolution
- **SONAME dedup in installPhase**: multiple onnxruntime-node versions ship
  `libonnxruntime.so.1` with the same SONAME. Give each a unique
  `libonnxruntime.so.1.<cksum>` SONAME, rename the file, and update all
  local NEEDED refs.
- **`postPhases` RPATH fix**: autoPatchelfHook strips non-store RPATH
  entries; add the self-directory back via a `postPhases` hook that runs
  AFTER fixupPhase.
- Full docs: `pkgs/oh-my-pi/AGENTS.md`
