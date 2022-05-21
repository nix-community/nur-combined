# Nix User Repository for dtn7

![Build Status](https://github.com/dtn7/nur-packages/workflows/Build%20all/badge.svg)
![Build Status](https://github.com/dtn7/nur-packages/workflows/Update%20dtn7-go/badge.svg)

This is a [NUR](https://github.com/nix-community/NUR) repository for:

- [dtn7-go](https://github.com/dtn7/dtn7-go): `dtn7-go` and `dtn7-go-unstable`
- [dtn7-rs](https://github.com/dtn7/dtn7-rs): `dtn7-rs`


## Install

At the moment those packages are buildable on nixpkgs unstable.

To include the whole Nix User Repositories, follow [their
README](https://github.com/nix-community/NUR).

If you only want to include this repository, use the snippet below. This adds
unstable as a packet source on a stable system.

```nix
let
  unstableTarball = builtins.fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";
  unstable = import unstableTarball {
    config = config.nixpkgs.config;
  };
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    dtn7-nur = import (builtins.fetchTarball "https://github.com/dtn7/nur-packages/archive/master.tar.gz") {
      pkgs = unstable;
    };
  };
}

# ...

{
  environment.systemPackages = with pkgs; [
    dtn7-nur.dtn7-go-unstable
  ];
}
```
