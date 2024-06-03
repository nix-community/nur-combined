# nur-packages

![Build and populate cache](https://github.com/ihaveamac/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg) [![Cachix Cache](https://img.shields.io/badge/cachix-ihaveahax-blue.svg)](https://ihaveahax.cachix.org)

My personal [NUR](https://github.com/nix-community/NUR) repository.

Darwin/macOS builds are manually pushed by me to cachix occasionally. Usually when I also update flake.lock.

## Packages

Attributes listed on [the NUR](https://nur.nix-community.org/repos/ihaveamac/)

* 3dstool-1.2.6 (as \_3dstool attribute)
* lnshot-0.1.3
* save3ds-dev-2023-03-28
* cleaninty-0.1.3
* rvthtool-dev-2024-01-24
* themethod3-2024-04-20
* makebax-2019-01-22
* ctrtool-1.2.0
* makerom-0.18.4
* kwin-move-window-1.1.1
* kwin-explicit-sync-patch-6.0.5.1
* mediawiki-1.39.7
* homebox-bin-0.10.3

## Using the KWin patch

Patch source: https://invent.kde.org/plasma/kwin/-/merge_requests/5511

This will be available until KWin 6.1 which includes this patch.

Put this in your NixOS configuration:

```nix
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
        kwin = nur.repos.ihaveamac.kwin-explicit-sync-patch;
      });
    })
  ];
```

**Note:** Make sure you set the nixpkgs input for the NUR (or this repo) to follow the same version of nixpkgs used for the NixOS system. Otherwise you may get an error such as "detected mismatched Qt dependencies".

## Home Manager modules

### services.lnshot.enable

Enables the lnshot daemon to automatically link Steam screenshots.
