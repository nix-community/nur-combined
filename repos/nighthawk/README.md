# nur-packages

![Build and populate cache](https://github.com/CDotNightHawk/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg) [![Cachix Cache](https://img.shields.io/badge/cachix-nighthawk-blue.svg)](https://nighthawk.cachix.org)

My personal [NUR](https://github.com/nix-community/NUR) repository.

NUR link: https://nur.nix-community.org/repos/nighthawk/

## Packages

| Name | Attr | Description |
| --- | --- | --- |
| [lnshot-0.1.3](https://github.com/ticky/lnshot) | lnshot | Symlink your Steam screenshots to a sensible place |

## Overlay

The default overlay will add all the packages above in the `pkgs.nightpkg` namespace, e.g. `pkgs.nightpkg.something`.

There is a NixOS module to automatically add this overlay as `nixosModules.overlay`. This module can also be used with Home Manager and nix-darwin.

## Home Manager modules

### services.lnshot.enable

Enables the lnshot daemon to automatically link Steam screenshots.

### services.lnshot.picturesName

Name of the directory to manage inside the Pictures folder. Defaults to "Steam Screenshots".
