---
name: nix-package
description: Use when adding, updating, or reviewing packages in this repository's `pkgs/` tree.
---

# Nix packages

## Add a package

1. Read nearby packages first. Optionally consult similar packages in nixpkgs.
2. Follow the `pkgs/by-name` layout.
  - Put the entry at `pkgs/<first-two>/<attr-name>/package.nix`. `pkgs/default.nix` automatically loads it through `callPackage`.
  - Each package is self-contained. Lockfiles, update scripts, etc. live beside `package.nix`.
3. For simple packages, run `nix-init` headlessly to create skeleton. Check usage with `nix-init -h`.
4. Follow the local conventions and expression style.
  - For a small variant of an existing nixpkgs derivation, follow the local `overrideAttrs` pattern.
  - Add optional arguments only for useful caller-controlled variants, with a default that matches the normal package.
  - Non-exhaustive attribute order:
    - `pname` & `version` -> `src` -> `patches` -> deps -> build inputs -> phases -> `passthru` -> `meta`
    - In `meta`: `description` & `longDescription` -> `homepage` & `downloadPage` & `changelog` -> `license` -> `mainProgram` -> `maintainers` -> `platforms` -> `broken` & `insecure`
5. Add an `$update` entry to `.github/workflows/update-packages.yaml` in A-Z order.
  - Unstable package -> set `--version=branch`
  - Complex package that `nix-update` can't handle -> set `passthru.updateScript` & `--use-update-script`

## Maintain a package

- Run `treefmt` to format all changed Nix files.
- Run `nix-update` to update version and hashes. Refresh lockfile when needed.
- Build the package with `nix build --impure .#<attr-name>`.
