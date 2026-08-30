# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:
{
  lib = import ./lib { inherit (pkgs) lib; };
  overlays = import ./overlays;
  # Can't use `lib.modulesFromDirectoryRecursive` here because that would require `pkgs.lib`,
  # and NUR doesn't provide `pkgs` when evaluating this file. So we have to manually list the modules here.
  # See https://github.com/nix-community/NUR/blob/50b7a2/flake.nix#L46
    nixosModules = {
      mcp-searxng = ./modules/nixos/mcp-searxng/module.nix;
      safebucket = ./modules/nixos/safebucket/module.nix;
      rustic-exporter = ./modules/nixos/rustic-exporter/module.nix;
    };
}
