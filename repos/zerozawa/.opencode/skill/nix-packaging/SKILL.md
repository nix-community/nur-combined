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

### Flutter packages

Example: `pkgs/Fladder/default.nix`

```nix
flutter.buildFlutterApplication rec {
  pname = "...";
  version = "...";
  pubspecLock = lib.importJSON ./pubspec-lock.json;
  gitHashes = { ... };
}
```

This repo also uses custom Flutter source builders and CI lockfile sync checks for `Fladder`.

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

Example: `pkgs/hyprland-mcp-server.nix`

```nix
buildNpmPackage rec {
  pname = "...";
  version = "...";
  npmDepsHash = "sha256-...";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram "$out/bin/${pname}" --prefix PATH : "${lib.makeBinPath [ ... ]}"
  '';
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
- custom source builders inside `pkgs/Fladder/default.nix`

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
- `sr-vulkan`: model composition through `sr-vulkan-models`
- `Fladder`: Flutter packaging with custom source builders and lockfile tooling
- `hyprland-mcp-server`: npm packaging plus PATH wrapping
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
- [ ] Builder matches the closest existing package in this repo
- [ ] `meta` is complete enough for CI filtering and flake exposure
- [ ] License format matches current repo conventions or is improved deliberately
- [ ] Build verified with `nix-build -A <pkg>` or equivalent
- [ ] Runtime behavior checked for wrapped GUI / CLI tools
- [ ] Docs updated if package inventory or repo behavior changed
