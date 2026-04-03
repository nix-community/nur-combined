{ lib, ... }:
let
  generateModules =
    path:
    lib.mapAttrs' (name: _: {
      name = lib.removeSuffix ".nix" name;
      value = import (path + "/${name}");
    }) (lib.filterAttrs (name: _: lib.hasSuffix ".nix" name) (builtins.readDir path));
in
{
  flake = {
    nixosModules = generateModules ../modules/nixos;
    darwinModules = generateModules ../modules/darwin;
  };
}
