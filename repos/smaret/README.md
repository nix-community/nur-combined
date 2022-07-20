# NUR packages

This repository contains a [collection of packages](https://nur.nix-community.org/repos/smaret/)
for the [Nix package manager](https://nixos.org/nix/). This collection is available from the
[Nix User Repository (NUR)](https://github.com/nix-community/NUR).

## Installation

First configure Nix to use NUR, following the instructions in [NUR
documentation](https://github.com/nix-community/NUR#installation).

Once Nix has been set up, you can use or install packages from this
repository with:

```sh
nix-shell -p nur.repos.smaret.astrochem
```

or

```sh
nix-env -iA nur.repos.smaret.astrochem
```

## How to download binaries

To avoid compiling the packages, you may download binaries with
[Cachix](https://smaret.cachix.org).

![Build and populate cache](https://github.com/smaret/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-smaret-blue.svg)](https://smaret.cachix.org)

