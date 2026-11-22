<!-- rumdl-disable MD033 MD041 -->

<div align="center">
  <img src="./assets/nix-logo.png" alt="Nix logo" width="112" />

  # adam0's NUR repository

  Personal Nix packages, modules, and plugin builds that I want available
  outside my main config.

  [![Checks](https://img.shields.io/github/actions/workflow/status/adam01110/nur/checks.yml?branch=main&style=flat-square&labelColor=504945&label=checks)](https://github.com/adam01110/nur/actions/workflows/checks.yml)
  [![Build](https://img.shields.io/github/actions/workflow/status/adam01110/nur/build.yml?branch=main&style=flat-square&labelColor=504945&label=build)](https://github.com/adam01110/nur/actions/workflows/build.yml)
  [![Repo Size](https://img.shields.io/github/repo-size/adam01110/nur?style=flat-square&labelColor=504945&label=repo%20size&color=3c3836)](https://github.com/adam01110/nur)
  <br />
  [![Nix](https://img.shields.io/badge/Nix-flakes-689d6a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.wiki/wiki/Flakes)
  [![NUR](https://img.shields.io/badge/NUR-adam0-458588?style=flat-square&labelColor=504945)](https://github.com/nix-community/NUR)
  [![Cachix](https://img.shields.io/badge/Cachix-adam01110--nur-d79921?style=flat-square&labelColor=504945)](https://adam01110-nur.cachix.org)

  [Usage](#usage) - [Maintenance](#maintenance) - [Layout](#layout)
</div>

This is my small NUR repo for packages that either are not in nixpkgs, need
changes faster than nixpkgs would get them, or are useful enough to share
outside my own config.

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
  nurPkgs = inputs.adam0-nur.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages = [
    nurPkgs.gruvbox-plus-icons
    nurPkgs.bibata.modern.cursors.gruvbox-dark
    nurPkgs.bibata.modern.cursors.gruvbox-dark.hyprcursor
  ];
}
```

Bibata exposes 40 combined XCursor/scalable SVG themes and their 40 Hyprcursor
variants. Both formats build directly from the SVG sources; Hyprcursor does not
depend on the XCursor package:

```nix
bibata.<modern|modern-right|original|original-right>.cursors.<palette>
bibata.<modern|modern-right|original|original-
right>.cursors.<palette>.hyprcursor
```

Available palettes are `classic`, `gruvbox-dark`, `gruvbox-light`, `rosepine`,
`rosepine-dawn`, `rosepine-moon`, and the four `catppuccin-*` flavors.

For classic NUR usage, import it like any other NUR repository:

```nix
import inputs.adam0-nur { inherit pkgs; }
```

## Maintenance

This repo is intentionally automated because I do not want package bumps to
become fulltime job.

- `build.yml` evaluates and builds cacheable outputs against unstable and stable
  nixpkgs channels.
- `update-packages.yml` runs `python3 -m updater` and opens a signed pull
  request when package versions move.
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
