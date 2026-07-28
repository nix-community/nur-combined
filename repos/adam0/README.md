<div align="center">
  <img src="./assets/nix-logo.png" alt="Nix logo" width="112" />

  # adam0's NUR repository

  Personal Nix packages, modules, and plugin builds that I want available outside my main config.

  [![Build](https://img.shields.io/github/actions/workflow/status/adam01110/nur/build.yml?branch=main&style=flat-square&label=Build&labelColor=504945&color=cc241d)](https://github.com/adam01110/nur/actions/workflows/build.yml)
  [![Repo Size](https://img.shields.io/github/repo-size/adam01110/nur?style=flat-square&label=repo%20size&labelColor=504945&color=3c3836)](https://github.com/adam01110/nur)
  [![Cachix](https://img.shields.io/badge/cachix-adam01110--nur-689d6a?style=flat-square&labelColor=504945&color=689d6a)](https://adam01110-nur.cachix.org)
  <br />
  [![NUR](https://img.shields.io/badge/NUR-adam0-458588?style=flat-square&labelColor=504945&color=458588)](https://github.com/nix-community/NUR)

  [Usage](#usage) - [Maintenance](#maintenance) - [Layout](#layout)
</div>

This is my small NUR repo for packages that either are not in nixpkgs, need changes faster than nixpkgs would get them, or are useful enough to share outside my own config.

## Usage

Use the repository through NUR:

```nix
{pkgs, ...}: {
  home.packages = [
    pkgs.nur.repos.adam0.gruvbox-plus-icons
    pkgs.nur.repos.adam0.tg
  ];
}
```

It can also be imported directly:

```nix
import (builtins.fetchTarball "https://github.com/adam01110/nur/archive/main.tar.gz") {
  inherit pkgs;
}
```

## Maintenance

- `build.yml` evaluates and builds cacheable outputs against unstable and stable nixpkgs channels.
- `update-packages.yml` runs `python3 -m updater` and opens a signed pull request when package versions move.

## Layout

| Path | Contents |
| --- | --- |
| `pkgs/` | Package definitions and grouped package sets |
| `hm-modules/` | Home Manager modules |
| `updater/` | Python package updater used by CI |
| `ci.nix` | Build/cache selection for CI |
| `default.nix` | Classic NUR export surface |
