# Composes the packages collection.

{
  # The system packages will be build and used on.
  localSystem
  # Nixpkgs
, pkgs
  # Nixpkgs lib
, lib ? pkgs.lib
}:
let
  allPackages = import ./stage.nix {
    inherit lib pkgs;
  };

  available = lib.filterAttrs
    (_: drv: builtins.elem localSystem (drv.meta.platforms or [ ]));
in
available allPackages
