# NUR packages

This repository contains a [collection of packages](https://nur.nix-community.org/repos/thestaccato/)
for the [Nix package manager](https://nixos.org/nix/). This collection is available from the
[Nix User Repository (NUR)](https://github.com/nix-community/NUR).

## Installation

First configure Nix to use NUR, following the instructions in [NUR
documentation](https://github.com/nix-community/NUR#installation).

Once Nix has been set up, you can use or install packages from this
repository with:

```sh
nix-shell -p nur.repos.thestaccato.mozart
```

or

```sh
nix-env -iA nur.repos.thestaccato.mozart
```
