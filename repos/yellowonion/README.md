# Nightly bcachefs nix user repository

your `configuration.nix` should look something like this:
```nix
{ config, pkgs, lib, ...}:
let
  yo-nur     = import (builtins.fetchTarball "https://github.com/YellowOnion/nur-bcachefs/archive/master.tar.gz") {};
in
{
  boot.kernelPackages = lib.mkOverride 0 (pkgs.linuxPackagesFor pkgs.bcachefs-kernel-kent);
  nixpkgs.overlays = [(super: final: { bcachefs-tools = yo-nur.bcachefs-tools;})];
  
  nix = {
    settings = {
      substituters = [
          "https://yo-nur.cachix.org"
          "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "yo-nur.cachix.org-1:E/RHfQMAZ90mPhvsaqo/GrQ3M1xzXf5Ztt0o+1X3+Bs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
  };
}
```

build iso:

```bash
    git clone https://github.com/YellowOnion/nur-bcachefs.git
    cd nur-bcachefs
    nix-build -A bcachefs-iso --option extra-substituters "https://yo-nur.cachix.org" --option extra-trusted-public-keys "yo-nur.cachix.org-1:E/RHfQMAZ90mPhvsaqo/GrQ3M1xzXf5Ztt0o+1X3+Bs="
    ls ./result/iso
```

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/YellowOnion/nur-bcachefs/workflows/Build%20and%20populate%20cache/badge.svg)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
-->
[![Cachix Cache](https://img.shields.io/badge/cachix-yo-nur-blue.svg)](https://yo-nur.cachix.org)

