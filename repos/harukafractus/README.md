# Nix
My Nix configuration for nix-darwin and Asahi Linux

Fix needed for sources: Create a Pull Request instead of pushing it directly 

NUR: [![Build and populate cache](https://github.com/harukafractus/nix/actions/workflows/nur.yml/badge.svg)](https://github.com/harukafractus/nix/actions/workflows/nur.yml)

## Directory
```
.
├── devices             <- Device-specific configuration
│  ├── _linux_options   <- Options for NixOS
│  ├── nix-isnt-xnu     <- configuration.nix for NixOS on Asahi Linux
│  └── walled-garden    <- Nix-darwin configs
├── nur-everything      <- NUR Repo Exports
└── users               <- User-specific configuration
   ├── _homeOptions     <- Options for Home Manager
   └── haruka           <- User haruka config
```


## Installation
nix-darwin: Install Nix using the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer), clone the repo, install [nix-darwin](https://github.com/LnL7/nix-darwin) using:
```
nix run --extra-experimental-features "nix-command flakes" nix-darwin -- switch --flake .#[device_name]
```