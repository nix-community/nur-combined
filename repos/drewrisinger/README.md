# nur-packages

**Drew Risinger's personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build Status](https://travis-ci.org/drewrisinger/nur-packages.svg?branch=master)](https://travis-ci.com/drewrisinger/nur-packages)
[![Cachix Cache](https://img.shields.io/badge/cachix-drewrisinger-blue.svg)](https://drewrisinger.cachix.org)

## Using this repo

### Common

1. Install Cachix. This lets you use the pre-built binaries for these Nix expressions (built using Travis).
   1. ``$ nix-env -iA cachix -f https://cachix.org/api/v1/install``
2. Use my cachix cache. 
   1. ``$ cachix use drewrisinger``
3. Choose one of the two options below:

### As part of Nix User Repository

Follow the instructions on installation and package use at [GitHub NUR page](https://github.com/nix-community/NUR#installation)

### Standalone (my NUR packages only)

In a Nix script (example):
```nix
{ pkgs ? import <nixpkgs> {} }:
let
  # Option 1: get most recent version
  drew-nur-master = import (builtins.fetchTarball "https://github.com/drewrisinger/nur-packages/archive/master.tar.gz") {
    inherit pkgs;
  };
  
  # Option 2: get a specific version
  drew-nur-at-commit = import (builtins.fetchTarball {
    # Get the revision by choosing a version from https://github.com/drewrisinger/nur-packages/commits/master
    url = "https://github.com/drewrisinger/nur-packages/archive/ffd7e82fa492ce9c52ffeabb8250c6182b96c482.tar.gz";
    # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
    sha256 = "1vs1z05k68hn3mvq8kh68c78zlp417p0bbxw20a9arjb9cdffckn";
  }) { inherit pkgs; };
in
  drew-nur-master.python3Packages.qiskit
  drew-nur-at-commit.python3Packages.cirq
```
