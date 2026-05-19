# Abszero

[![NUR Badge](https://img.shields.io/badge/NUR-abszero-lightblue?style=flat-square&logo=hack-the-box&logoColor=lightblue)](https://nur.nix-community.org/repos/abszero)
[![Cachix Badge](https://img.shields.io/badge/Cachix-abszero-lightblue?style=flat-square&logo=googlepubsub&logoColor=lightblue)](https://app.cachix.org/cache/abszero)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/Weathercold/nixfiles?authorFilter=Weathercold&style=flat-square&label=My%20commits)](https://github.com/Weathercold/nixfiles/commits?author=Weathercold)
[![Update Packages status](https://img.shields.io/github/actions/workflow/status/Weathercold/nixfiles/update-packages.yaml?style=flat-square&label=Update%20Packages)](https://github.com/Weathercold/nixfiles/actions/workflows/update-packages.yaml)
[![Build Packages status](https://img.shields.io/github/actions/workflow/status/Weathercold/nixfiles/build-packages.yaml?style=flat-square&label=Build%20Packages)](https://github.com/Weathercold/nixfiles/actions/workflows/build-packages.yaml)

Dotfiles powered by Nix™, plus a package overlay and a library of utility
functions.

## Rice

- Display manager: [tuigreet](https://github.com/apognu/tuigreet)
- Window manager: [niri](https://github.com/YaLTeR/niri)
- Desktop shell: [under construction](https://github.com/Weathercold/wisp)
- Terminal: [foot](https://codeberg.org/dnkl/foot)
- Shell: [Nu](https://www.nushell.sh)
- Prompt: [starship](https://starship.rs)
- Color theme: [catppuccin](https://catppuccin.com)

## Highlights

- Using [darkman](https://gitlab.com/WhyNotHugo/darkman) to
  [automatically switch theme](home/modules/services/scheduling/darkman.nix) based on
  [home-manager configurations](home/configurations/weathercold/nixos-redmibook.nix)
- A [module](nixos/modules/services/hardware/framework_rgbafan.nix) to control
  RGB on framework desktop
- [Xray vless-tcp-xtls-reality tproxy configuration](nixos/modules/services/networking/xray)
- Using [haumea](https://github.com/nix-community/haumea):
  - to generate lists and trees of modules for `home` and `nixos`
  - as a module system for `lib`
- Using [disko](https://github.com/nix-community/disko) to declare partitions

## Public modules

### NixOS

- `base-plymouth-rings_2` (unused): sets plymouth theme to rings 2
- `catppuccin-catppuccin`
- `catppuccin-fonts`: installs fonts for the catppuccin theme
- `catppuccin-plymouth`
- `catppuccin-sddm` (unused)
- `hardware-dell-inspiron-7405` (deprecated)
- `hardware-framework-12-13th-gen-intel`
- `hardware-framework-desktop-amd-ai-max-300-series`
- `hardware-keyboard-halo65` (deprecated)
- `hardware-vultr-cc-intel-regular`: configures hardware for vultr intel VPS
- `hardware-xiaomi-redmibook-16-pro-2024` (deprecated)
- `profiles-base`: set essential options for all hosts
- `profiles-desktop`: enables services for PCs
- `profiles-desktop-with-ai`: enables services for AI-capable PCs
- `profiles-graphical`: sets essential options for graphical hosts
- `profiles-graphical-full` sets full options for graphical hosts
- `profiles-laptop`: enables services for laptops
- `profiles-server`: sets options for servers
- `services-framework_rgbafan`: controls RGB on framework desktop
- `services-xray`: configures xray

### Home Manager

- `base-cursors`
- `base-fastfetch`: themes fastfetch
- `base-foot`
- `base-ghostty` (unused)
- `base-hyprland-dynamic-cursors` (unused): configures dynamic cursors plugin for hyprland
- `base-nushell`
- `base-starship`
- `catppuccin-catppuccin`: declares options for the catppuccin theme
- `catppuccin-cursors`
- `catppuccin-discord` (deprecated)
- `catppuccin-fcitx5`
- `catppuccin-fonts`: installs fonts for the catppuccin theme
- `catppuccin-foot`
- `catppuccin-ghostty` (unused)
- `catppuccin-gtk`
- `catppuccin-hyprland` (unused)
- `catppuccin-niri`
- `catppuccin-plasma6` (unused)
- `colloid-fcitx5` (unused)
- `colloid-firefox` (unused)
- `colloid-fonts` (unused)
- `colloid-gtk` (unused)
- `colloid-plasma6` (unused)
- `profiles-base`: sets essential options for all hosts
- `profiles-build-config` (deprecated): prevents installation of packages (only installs configs)
- `profiles-full`: sets full options for all hosts
- `profiles-hyprland` (unused): enables services for hosts running hyprland
- `profiles-niri`: enables services for hosts running niri

## Project Structure

I try to make the structure as close to that of nixpkgs as possible,
differing from it only when it makes sense.

> [!tip]
> Each part of this repo (`home`, `lib`, `nixos`, `pkgs`) has a subflake that can
> be used as flake input by specifying a directory like this:
> `github:Weathercold/nixfiles?dir=home`

    nixfiles/
    ├ home/                               home manager config
    │ ├ configurations/                   home configurations
    │ │ ├ weathercold/                    personal configurations
    │ │ │ └ nixos-fwlaptop.nix, ...
    │ │ ├ custom.nix                      example configuration
    │ │ └ _options.nix                    configuration abstraction
    │ └ modules/                          home modules
    │   ├ profiles/                       top-level home modules
    │   └ services/, programs/, ...
    ├ nixos/                              nixos config
    │ ├ configurations/                   nixos configurations
    │ │ ├ nixos-fwlaptop.nix, ...
    │ │ └ _options.nix                    configuration abstraction
    │ └ modules/                          nixos modules
    │   ├ profiles/                       top-level nixos modules
    │   └ services/, programs/, ...
    ├ pkgs/                               package repository (follows pkgs/by-name structure)
    └ lib/                                library of shared expressions
      ├ modules/                          shared modules
      └ src/                              shared functions

---

## Import Graph

    nixfiles/flake.nix
    ├ home/flake-module.nix
    │ ├ configurations/custom.nix, ...
    │ ├ configurations/weathercold/nixos-fwlaptop.nix, ...
    │ │ ├ _base.nix
    │ │ └ ../_options.nix
    │ │   └ ../modules/profiles/*, ../modules/services/*, ...                 all home modules
    │ └ modules/profiles/*, modules/themes/*, ...                             public home modules
    ├ nixos/flake-module.nix
    │ ├ configurations/nixos-fwlaptop.nix, ...
    │ │ ├ inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel, ... 3rd party nixos modules
    │ │ └ _options.nix
    │ │   └ ../modules/profiles/*, ../modules/services/*, ...                 all nixos modules
    │ └ modules/profiles/*, modules/themes/*, ...                             public nixos modules
    ├ pkgs/flake-module.nix
    │ └ default.nix
    │   └ aa/*, ab/*, ...
    └ lib/default.nix
      └ src/*
