# Infra
(TBD README)Pretty much the everything nix repo(?)

## Installation / Using nix-darwin

evaluation status: ![](https://github.com/harukafractus/infra/actions/workflows/darwin-system-build.yml/badge.svg)


1. Install Nix on Darwin using [The Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer):
```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install —no-confirm
```
2. Clone this repository:
```sh
nix-shell -p git --command "git clone git@github.com:harukafractus/infra.git"
```
3. Apply:
```sh
nix run --extra-experimental-features "nix-command flakes" nix-darwin -- switch --flake .#haruka-air
```

### NixOS
Use the following:
```sh
nixos-install --impure --flake https://github.com/harukafractus/infra.git#[the_machine]
```
