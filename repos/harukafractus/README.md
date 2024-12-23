# Nix
My nix darwin configs

### NUR
NUR: [![Build and populate cache](https://github.com/harukafractus/nix/actions/workflows/nur-build.yml/badge.svg)](https://github.com/harukafractus/nix/actions/workflows/nur-build.yml)


### Darwin
> nix run --extra-experimental-features "nix-command flakes" nix-darwin -- switch --flake .#[device_name]

### Standalone Home Manager
> nix run home-manager/master -- switch --flake [dir]