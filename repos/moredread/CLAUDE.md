# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal [NUR](https://github.com/nix-community/NUR) repository (NUR name `moredread`), derived from `nix-community/nur-packages-template`.

## Commands

New files must be `git add`ed before flake commands can see them.

```sh
nix build .#<pkg>                       # build one package via the flake (locked nixpkgs, nixos-26.05)
nix-build -A <pkg>                      # same via default.nix and <nixpkgs> from NIX_PATH
nix build .#<pkg> --override-input nixpkgs github:NixOS/nixpkgs/nixos-unstable   # test against unstable
nix flake show                          # list exposed packages
nix-build ci.nix -A cacheOutputs        # everything CI-buildable (non-broken, free, cacheable)
nix flake update                        # bump flake.lock
```

There are no tests; "building cleanly" is the check. CI (`.github/workflows/build.yml`) builds the package set against the locked input plus nixos-26.05 and nixos-unstable and on `main` pings the NUR update endpoint.

## Structure

- `default.nix` is the single source of truth: takes `pkgs` (must not import `<nixpkgs>` itself beyond the default arg) and returns the package attrset plus the reserved names `lib`, `overlays`, `nixosModules` (and, per the template, `homeModules`/`darwinModules`/`flakeModules`). Add a new package by creating `pkgs/<name>/default.nix` and wiring it here with the appropriate `callPackage` (`pkgs.callPackage`, `pkgs.python3Packages.callPackage`, `pkgs.haskellPackages.callPackage` for `implicitcad`, which is a cabal2nix-style expression).
- `flake.nix` wraps `default.nix`: `legacyPackages` = the full attrset (incl. `lib`/`overlays`/`nixosModules`), `packages` = only the derivations filtered out of it, `nixosModules` = `nixos-modules/`.
- `ci.nix` and `overlay.nix` both re-import `default.nix` and skip the reserved names; `ci.nix` additionally drops packages with `meta.broken`, non-free licenses, or `preferLocalBuild`, so set those meta fields to control what CI builds/caches.
- `lib/`, `nixos-modules/` and `overlays/` are empty template placeholders.
- Upstream template: `nix-community/nur-packages-template`; last synced at its `b885a76` (2026-06-12). Exception: `.github/workflows/build.yml` is a local flake-based rewrite (nix-fast-build, `--override-input` matrix), not the template's `nixPath`/`ci.nix` workflow.

## Conventions

Commit messages follow nixpkgs style: `<pkg>: init at <version>`, `<pkg>: <old> -> <new>`, `CI: …`, `flake: …`.
