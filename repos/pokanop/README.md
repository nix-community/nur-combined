# nur-packages

**[Pokanop Apps](https://pokanop.com) [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/pokanop/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

| Package | Description |
| --- | --- |
| [nostromo](https://github.com/pokanop/nostromo) | CLI for building powerful aliases and tools |

## Install

Via [NUR](https://github.com/nix-community/NUR):

```nix
nur.repos.pokanop.nostromo
```

Or as a flake input:

```nix
inputs.pokanop-nur.url = "github:pokanop/nur-packages";
```

## Package versions

Package definitions for `nostromo` are updated automatically by
[GoReleaser](https://goreleaser.com) on each upstream release.
