# AtaraxiaDev's NUR repo

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/AtaraxiaSjel/nur/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-ataraxiadev--foss-blue.svg)](https://ataraxiadev-foss.cachix.org)

## Modules

* [authentik](https://goauthentik.io/), open-source Identity Provider focused on flexibility and versatility. Available as [services.authentik](modules/authentik.nix).

* [homepage](https://gethomepage.dev/), a modern, fully static, fast, secure fully proxied, highly customizable application dashboard. Available as [services.homepage-dashboard](modules/homepage.nix).
Disables NixOS's homepage-dashboard service.

* [hoyolab-claim-bot](https://github.com/AtaraxiaSjel/hoyolab-claim-bot/), hoyolab daily claim bot for Hoyoverse games. Available as [services.hoyolab-claim-bot](modules/hoyolab.nix).

* [kes](https://github.com/minio/kes), Key Managament Server for Object Storage and more. Available as [services.kes](modules/kes.nix).

* [ocis](https://owncloud.dev/ocis/), ownCloud Infinite Scale - the modern file-sync and share platform. Available as [services.ocis](modules/ocis.nix).
Package [ocis-bin](pkgs/ocis-bin/) included in this repo. Until [#230190](https://github.com/NixOS/nixpkgs/issues/230190) not resolved ocis-bin derivation pulls pre-built binary from [ocis repo](https://github.com/owncloud/ocis).

* [prometheus-podman-exporter](https://github.com/containers/prometheus-podman-exporter), Prometheus exporter for podman environments. Available as [services.prometheus.exporters.podman](modules/prometheus-exporters/podman.nix).

* [rinetd](https://github.com/samhocevar/rinetd), TCP/UDP port redirector. Available as [services.rinetd](modules/rinetd.nix).

* [rustic](https://github.com/rustic-rs/rustic), rustic - fast, encrypted, and deduplicated backups powered by Rust. Available as [services.rustic](modules/rustic.nix).
Usage [example](https://github.com/AtaraxiaSjel/nixos-config/tree/master/machines/Home-Hypervisor/backups.nix)

* [syncyomi](https://github.com/syncyomi/syncyomi/tree/develop), an open-source project crafted to provide a seamless synchronization experience for TachiyomiSY. Available as [services.syncyomi](modules/syncyomi.nix).

* [wopiserver](https://github.com/benbusby/whoogle-search/), a self-hosted, ad-free, privacy-respecting metasearch engine. Available as [services.services.whoogle-search](modules/whoogle.nix).

* [wopiserver](https://github.com/cs3org/wopiserver/), a vendor-neutral application gateway compatible with the WOPI specifications. Available as [services.wopiserver](modules/wopiserver.nix).

## Overlays

* [default](overlays/default.nix), default overlays that includes all [packages](pkgs/) from this nur repo.

* [grub2-argon2](overlays/grub2-23.05/), grub2 v2.06 with argon2 patches. Tested on my [home-hypervisor](https://github.com/AtaraxiaSjel/nixos-config/tree/master/machines/Home-Hypervisor) machine.

* [grub2-unstable-argon2](overlays/grub2-unstable/), upstream version of grub2 with argon2 patches from aur. Untested.

## Packages

WIP
