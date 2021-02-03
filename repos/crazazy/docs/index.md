# Crazazy's personal nixos configuration and package repository

![CI](https://github.com/crazazy/nixos-config/workflows/CI/badge.svg)

## Hello!

I'm Crazazy, and nowadays I mostly work on nix projects in my free time

Currently I study at the [University of Twente](https://utwente.nl)

This README.md is part of my personal monorepo, where I plan to experiemnt with automation using nix and maybe eventually build my own small operating system based on NixOS. For now it's pretty barren, though so don't expect much when clicking on the link
In this git repo you will find my personal configuration, and some packages I find useful to have
 
### folders:

- `pkgs/`: personal package repository
- `modules/`: nixos modules for my current laptop
- `local/`: configuration files that are not written in nix

### main files:

- `configuration.nix` nixos config entrypoint. this repository lives in my /etc/nixos
- `createLinks.sh`: creates links to my local config directory. Right now I'm not using home-manager     as some of these configs are automatically written by GUI's

### copying this system setup

- install [NixOS](https://nixos.org/nixos/manual/)
- replace configuration.nix with the following:
```nix
{ ... }:
let 
    nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
    inherit (nur-no-pkgs.repos.crazazy.modules) desktop-configuration system-configuration;
in
{
    imports = [
        desktop-configuration
        system-configuration
        ./hardware-configuration.nix
        ];
}
```

then run `createLinks.sh` do create symlinks to configurations managed in the repository

### Installing packages faster

This repository uses [cachix](https://cachix.org) to cache the build artifacts nix created. To use the built derivations just put the following in your command line:
```sh
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use crazazy
```


