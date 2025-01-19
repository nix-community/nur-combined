# Abszero

[![NUR Badge](https://img.shields.io/badge/NUR-abszero-lightblue?style=flat-square&logo=hack-the-box&logoColor=lightblue)](https://nur.nix-community.org/repos/abszero)
[![Cachix Badge](https://img.shields.io/badge/Cachix-abszero-lightblue?style=flat-square&logo=googlepubsub&logoColor=lightblue)](https://app.cachix.org/cache/abszero)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/Weathercold/nixfiles?authorFilter=Weathercold&style=flat-square&label=My%20commits)](https://github.com/Weathercold/nixfiles/commits?author=Weathercold)
[![Update Hash status](https://img.shields.io/github/actions/workflow/status/Weathercold/nixfiles/update-hash.yml?style=flat-square&label=Update%20Hash)](https://github.com/Weathercold/nixfiles/actions/workflows/update-hash.yml)
[![Build Packages status](https://img.shields.io/github/actions/workflow/status/Weathercold/nixfiles/build-packages.yml?style=flat-square&label=Build%20Packages)](https://github.com/Weathercold/nixfiles/actions/workflows/build-packages.yml)

Dotfiles powered by Nix™, plus a package overlay and a library of utility
functions.

## Highlights

- [Xray vless-tcp-xtls-reality tproxy configuration](nixos/modules/services/networking/xray)
- Using [haumea](https://github.com/nix-community/haumea):
  - to generate lists and trees of modules for `home` and `nixos`
  - as a module system for `lib`
- Using [disko](https://github.com/nix-community/disko) to declare partitions

## Repository Structure

I try to make the repo structure as close to that of nixpkgs as possible,
differing from it only when it makes sense.

Each part of this repo (`home`, `lib`, `nixos`, `pkgs`) has a subflake that can
be used as flake input by specifying a directory like this:
`github:Weathercold/nixfiles?dir=home`

    nixfiles/
    ├ home/                                     home configurations
    │ ├ configurations/                         top-level home configurations
    │ │ ├ weathercold/                          my configurations
    │ │ ├ custom.nix                            example configuration
    │ │ └ _options.nix                          configuration abstraction
    │ └ modules/                                home modules
    │   ├ profiles/                             top-level home modules**
    │   ├ accounts/, programs/, services/, ...
    │   └ themes/                               **
    ├ nixos/                                    nixos configurations
    │ ├ configurations/                         top-level nixos configurations
    │ │ ├ nixos-inspiron.nix, ...               my configurations
    │ │ └ _options.nix                          configuration abstraction
    │ └ modules/                                nixos modules
    │   ├ profiles/                             top-level nixos modules**
    │   ├ config/, i18n/, programs/, ...
    │   └ hardware/, themes/                    **
    ├ pkgs/                                     package repository (by-name)
    └ lib/                                      library of shared expressions
      ├ modules/                                shared modules
      └ src/                                    shared functions

---

\*\*: external modules exposed with `self.nixosModules` and `self.homeModules`.
They are effective on import by default, but can be disabled with
`config.abszero.enableExternalModulesByDefault`.

## Import Graph

    nixfiles/flake.nix
    ├ home/flake-module.nix
    │ ├ configurations/custom.nix, ...
    │ └ configurations/weathercold/nixos-inspiron.nix, ...
    │   ├ ../_options.nix
    │   └ _base.nix
    │     └ ../../modules/profiles/full.nix
    │       └ base.nix
    │         └ ../accounts/*, ../programs/*, ../services/*, ...
    ├ lib/default.nix
    │ └ src/*
    ├ nixos/flake-module.nix
    │ └ configurations/nixos-inspiron.nix, ...
    │   ├ _options.nix
    │   ├ ../modules/hardware/dell-inspiron-7405.nix
    │   └ ../modules/profiles/full.nix
    │     ├ ../hardware/halo65.nix, ...
    │     └ base.nix
    │       └ ../config/*, ../i18n/*, ../programs/*, ...
    └ pkgs/flake-module.nix
      └ default.nix
        └ aa/*, ab/*, ...
