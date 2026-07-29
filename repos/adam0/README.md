<div align="center">
  <img src="./assets/nix-logo.png" alt="Nix logo" width="112" />

  # adam0's NUR repository

  Personal Nix packages, modules, and plugin builds that I want available outside my main config.

  [![Checks](https://img.shields.io/github/actions/workflow/status/adam01110/nur/checks.yml?branch=main&style=flat-square&label=Checks&labelColor=504945&color=cc241d)](https://github.com/adam01110/nur/actions/workflows/checks.yml)
  [![Build](https://img.shields.io/github/actions/workflow/status/adam01110/nur/build.yml?branch=main&style=flat-square&label=Build&labelColor=504945&color=cc241d)](https://github.com/adam01110/nur/actions/workflows/build.yml)
  [![Repo Size](https://img.shields.io/github/repo-size/adam01110/nur?style=flat-square&label=repo%20size&labelColor=504945&color=3c3836)](https://github.com/adam01110/nur)
  [![Cachix](https://img.shields.io/badge/cachix-adam01110--nur-689d6a?style=flat-square&labelColor=504945&color=689d6a)](https://adam01110-nur.cachix.org)
  <br />
  [![NUR](https://img.shields.io/badge/NUR-adam0-458588?style=flat-square&labelColor=504945&color=458588)](https://github.com/nix-community/NUR)
  [![Flakes](https://img.shields.io/badge/Nix-flakes-b16286?style=flat-square&labelColor=504945&color=b16286)](https://nixos.wiki/wiki/Flakes)

  [Usage](#usage) - [Maintenance](#maintenance) - [Layout](#layout)
</div>

This is my small NUR repo for packages that either are not in nixpkgs, need changes faster than nixpkgs would get them, or are useful enough to share outside my own config.

## Usage

Add the repo as a flake input:

```nix
{
  inputs.adam0-nur.url = "github:adam01110/nur";
}
```

Then use packages from the flake output for your system:

```nix
{
  inputs,
  pkgs,
  ...
}: let
  nurPkgs = inputs.adam0-nur.packages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages = [
    nurPkgs.gruvbox-plus-icons
    nurPkgs.bibata-modern-cursors-gruvbox-dark
  ];
}
```

For classic NUR usage, import it like any other NUR repository:

```nix
import inputs.adam0-nur { inherit pkgs; }
```

## Maintenance

This repo is intentionally automated because I do not want package bumps to become fulltime job.

- `build.yml` evaluates and builds cacheable outputs against unstable and stable nixpkgs channels.
- `update-packages.yml` runs `python3 -m updater` and opens a signed pull request when package versions move.
- `update-flake-lock.yml` refreshes `flake.lock` weekly.
- `treefmt-nix` keeps formatting consistent with the rest of my Nix repos.

## Layout

| Path | Contents |
| --- | --- |
| `pkgs/` | Package definitions and grouped package sets |
| `hm-modules/` | Home Manager modules exported by the flake |
| `flake/` | Flake parts for packages, formatting, and dev shell wiring |
| `updater/` | Python package updater used by CI |
| `ci.nix` | Build/cache selection for CI |
| `default.nix` | Classic NUR export surface |
