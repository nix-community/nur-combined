# Nightly bcachefs nix user repository

```nix
{ pkgs, ...}:
{   
    boot.kernelPackages = lib.mkOverride 0 (pkgs.linuxPackagesFor pkgs.bcachefs-kernel);
    nixpkgs.overlays = [ 
    (
    import "${builtins.fetchTarball "https://github.com/YellowOnion/nur-bcachefs/archive/master.tar.gz"}/overlay.nix" {}
    )
    ];
}
```

ISO Image is available in the cache.

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/YellowOnion/nur-bcachefs/workflows/Build%20and%20populate%20cache/badge.svg)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
-->
[![Cachix Cache](https://img.shields.io/badge/cachix-yo-nur-blue.svg)](https://yo-nur.cachix.org)

