# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/mrene/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Updating packages

```sh
./update-all.sh                 # bump flake.lock, then every package
./update-all.sh narwal-ha ...   # only these packages, against the current lock
```

Each package is updated with [nix-update](https://github.com/Mic92/nix-update), built, and
committed with `jj` as `pkg: old -> new`; failures are restored and listed at the end.
Requires a clean working copy.

Per-package flags use the nixpkgs convention:

```nix
passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
```

`passthru.updateScript = null` opts a package out. Vendored dependencies exposed through
`passthru` (e.g. `narwal-ha.bbpb`) are updated before their parent, and yarn-berry
`missingHashes` files are regenerated. See `update-plan.nix` for what is skipped.

