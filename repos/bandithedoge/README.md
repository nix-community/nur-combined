[![Build packages](https://github.com/bandithedoge/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/bandithedoge/nur-packages/actions/workflows/build.yml)
[![Update sources](https://github.com/bandithedoge/nur-packages/actions/workflows/update.yml/badge.svg)](https://github.com/bandithedoge/nur-packages/actions/workflows/update.yml)
[![Cachix Cache](https://img.shields.io/badge/cachix-bandithedoge-blue.svg)](https://bandithedoge.cachix.org)

Packages in this repository are bleeding-edge, meaning they are automatically updated daily with no manual review step. Make sure you understand the stability and security implications before using them.

See [LIST.md](LIST.md) for a full list of packages.

# Conventions

- Commits are made to `staging` (including automated package updates). Everything is merged into `master` by CI if all builds succeed.
- `-bin` suffix is added to packages that _could_ be built from source but for some reason aren't
- Import order:

  ```nix
  {
    withFoo ? true, # package-specific configuration options

    sources,

    lib,
    stdenv, # or platform sets like rustPlatform or buildNpmPackage

    # libraries, hooks, etc
  }:
  ```

- Dependency lists and the like are sorted alphabetically
- `version` attribute must be a diffable version:
  - `v` prefix stripped
  - date instead of commit hash
- `autoPatchelfHook` and `patchelf` preferred over wrappers
- `fetchTarball` preferred over `fetchurl`
- Packages that are available in nixpkgs are removed and added to [`_upstreamed.nix`](./_upstreamed.nix) except in cases where ours is significantly different (eg. tracking unstable versions)
- Packages that are renamed are added to [`_renamed.nix`](./_renamed.nix), including when binary packages become source-built and vice versa
- Packages that are dropped are added to [`_removed.nix`](./_removed.nix)
- To help keep this repo small, the update action emits a warning if any of the exported attributes is present in nixpkgs. Packages intended to replace their nixpkgs counterparts have `passthru._ignoreDupes = true`.
