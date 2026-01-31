> [!IMPORTANT]  
> This repository is having a hard time updating in the NUR right now.
> 
> It will update when this issue is resolved: https://github.com/nix-community/NUR/issues/1076

# NUR Packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/Forkprince/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-forkprince-blue.svg)](https://forkprince.cachix.org)

This repository contains three types of packages:

| Type       | Description                                             |
|------------|---------------------------------------------------------|
| `custom`   | Packages I maintain outside nixpkgs (e.g., `moonplayer`, `yaagl`). |
| `modified` | Packages adjusted to my needs (e.g., `beeper-nightly`). |
| `support`  | Packages patched for extra platforms/architectures (e.g., `gimp`, `dolphin-emu`). |

This repository also provides an [overlay](./overlays/default.nix) which has platform-specific package overrides.