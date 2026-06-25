# V2 Release Guide

`bun2nix` V2 comes with many improvements, including:

- Guaranteed correct bun installs via building the bun cache instead of creating the `node_modules/` directory manually
- Faster incremental builds via better caching
- Rewritten nix API designed to be both more idiomatic and flexible
- New NPM packaged web assembly CLI - run the `bun2nix` CLI with nothing but `bunx bun2nix` - see the [NPM page](https://www.npmjs.com/package/bun2nix).
- Now supports more of bun's dependency types, including:
  - Files and symlinks
  - Tarballs
  - Git Dependencies

> This work was done under [Fleek](https://fleek.xyz/). Please, check us out, especially if you are interested in Nix!

## Updating

Below is a guide to all the breaking changes:

### `mkBunDerivation`

- `mkBunDerivation` has been renamed and moved from `inputs.bun2nix.${system}.mkBunDerivation` to `inputs.bun2nix.packages.${system}.default.mkDerivation` (or more simply `bun2nix.mkDerivation`)
- The `index` attribute has been renamed to `module` to be inline with how it's defined in `packages.json`.
- Instead of specifying `bunNix` directly, specify `bunDeps` using [`fetchBunDeps`](./building-packages/fetchBunDeps.md) instead.
- See [`mkDerivation`](./building-packages/mkDerivation.md) for other new features and examples

### `mkBunNodeModules`

- `mkBunNodeModules` has been removed entirely in favor of [`fetchBunDeps`](./building-packages/fetchBunDeps.md) to build a [bun compatible cache](https://github.com/oven-sh/bun/blob/642d04b9f2296ae41d842acdf120382c765e632e/docs/install/cache.md#L24).
- Still need to add `node_modules/` to an arbitrary derivation? Have a look at the new [`bun2nix` hook](./building-packages/hook.md), which provides a much nicer API.

### `writeBunScriptBin`

- This has been moved from `inputs.bun2nix.lib.${system}.writeBunScriptBin` to `inputs.bun2nix.packages.${system}.default.writeBunScriptBin`

### New `bun.nix` schema

- Now consumable by `pkgs.callPackage` and [`bun2nix.fetchBunDeps`](./building-packages/fetchBunDeps.md).
- Don't forget to rewrite your `bun.nix` file by running `bun2nix -o bun.nix` before use!
