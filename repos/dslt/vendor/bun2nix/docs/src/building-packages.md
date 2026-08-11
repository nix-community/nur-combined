# Building Packages

`bun2nix` provides a number of functions to aid in building Bun-related packages:

> All of these functions are available as attributes on the `bun2nix` package itself via its [`passthru`](https://aux-docs.pyrox.pages.gay/Nixpkgs/Standard-Environment/passthru.chapter/).

- [`mkDerivation`](./building-packages/mkDerivation.md)
- [`hook`](./building-packages/hook.md)
- [`fetchBunDeps`](./building-packages/fetchBunDeps.md)
- [`writeBunApplication`](./building-packages/writeBunApplication.md)
- [`writeBunScriptBin`](./building-packages/writeBunScriptBin.md)
