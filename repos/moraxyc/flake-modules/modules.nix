{ lib, ... }:
let
  modulesFromList =
    moduleList:
    lib.listToAttrs (
      map (path: {
        name = lib.removeSuffix ".nix" (baseNameOf path);
        value = import path;
      }) moduleList
    );
in
{
  flake = {
    nixosModules = modulesFromList (import ../nixos/modules/module-list.nix);
    darwinModules = modulesFromList (import ../darwin/modules/module-list.nix);
  };
}
