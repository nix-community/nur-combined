{ lib, ... }:
{
  flake.nixosModules = lib.mapAttrs' (name: _: {
    name = lib.removeSuffix ".nix" name;
    value = import (../modules + "/${name}");
  }) (lib.filterAttrs (name: _: lib.hasSuffix ".nix" name) (builtins.readDir ../modules));
}
