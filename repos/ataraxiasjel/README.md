# AtaraxiaDev's NUR repo

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/AtaraxiaSjel/nur/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-ataraxiadev--foss-blue.svg)](https://ataraxiadev-foss.cachix.org)

## Modules

* [ocis](https://owncloud.dev/ocis/), ownCloud Infinite Scale - the modern file-sync and share platform. Available as [services.ocis](modules/ocis.nix).
Package [ocis-bin](pkgs/ocis-bin/) included in this repo. Until [#230190](https://github.com/NixOS/nixpkgs/issues/230190) not resolved ocis-bin derivation pulls pre-built binary from [ocis repo](https://github.com/owncloud/ocis).

## Overlays

* [default](overlays/default.nix), default overlays that includes all [packages](pkgs/) from this nur repo.

* [grub2-unstable](overlays/grub2-unstable/), grub2 with argon2 patches from aur. Tested on my [home-hypervisor](https://github.com/AtaraxiaSjel/nixos-config/tree/master/machines/Home-Hypervisor) machine.

* [grub2-23.05](overlays/grub2-23.05/), like previous overlay but for old nixos-23.05 version.

## Packages

WIP