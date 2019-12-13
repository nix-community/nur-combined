# Nix User Repository for dtn7 [![Build Status](https://github.com/dtn7/nur-packages/workflows/Update%20dtn7-go%20NUR%20packages/badge.svg)](https://github.com/dtn7/nur-packages/actions)

This is a [NUR](https://github.com/nix-community/NUR) repository for
[dtn7-go](https://github.com/dtn7/dtn7-go).

There is both a stable and an unstable release available, `dtn7-go` for the last
tagged version and `dtn7-go-unstable` for the current `master`.

Those packages are automatically updated on modifications in the `dtn7-go`
repository. Inb4 [xkcd](https://xkcd.com/1205/).


## Install

At the moment those packages are buildable on nixpkgs unstable. There seem to be
differences in `buildGoModule`.

To include the whole Nix User Repositories, follow [their
README](https://github.com/nix-community/NUR).

If you only want to include this repository, use the snippet below. This adds
unstable as a packet source on a stable system.

```nix
let
  unstableTarball = builtins.fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
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
