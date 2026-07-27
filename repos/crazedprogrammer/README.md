# nix

My NixOS configuration files.

# Structure

`dotfiles/` contains dotfiles and scripts such as `init.vim` and
`bin/gitree`.

`modules/` contains NixOS configuration modules. Each machine has its
"entry point" in `modules/hosts/<hostname>.nix`. `/etc/nixos/configuration.nix`
is empty and only contains an import of the corresponding entry point.

`pkgs/` contains overlays, custom packages and overrides.

# Building

In order to build this configuration, you need to use these channels:

```
nixos https://nixos.org/channels/nixos-24.11
nixos-unstable https://nixos.org/channels/nixos-unstable
```
