# nixpkgs

Set of expressions to run [`angr`](https://angr.io) on Nix/NixOS.

[![Build Status](https://travis-ci.com/angr/nixpkgs.svg?branch=master)](https://travis-ci.com/angr/nixpkgs)


## Installation

### Via NUR

This repository has been made part of the Nix User Repository ([see details, documentation, and installation guide](https://github.com/nix-community/NUR#nur)).

With NUR set-up, `angr` can be made available to a `nix-shell` with the following:

```
nix-shell -p 'python3.withPackages(ps: with ps; [ nur.repos.angr.python3Packages.angr ])'
```

### Standalone

```
git clone git@github.com:angr/nixpkgs.git angr-nixpkgs
export ANGR_NIXPKGS="$(pwd)"
nix-shell --arg ANGR_NIXPKGS_PATH "$ANGR_NIXPKGS"
```

  * For a more "persistent" solution, add `export ANGR_NIXPKGS="$(pwd)/angr-nixpkgs"` to your shell configuration file.
  * To stay up-to-date, you will have to fetch and rebase your local repository manually.
