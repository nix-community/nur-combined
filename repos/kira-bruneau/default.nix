{
  pkgs ? import <nixpkgs> { },
}:

let
  lib = pkgs.lib;
  nurPkgs = import ./pkgs { inherit lib; } (pkgs // nurPkgs) pkgs;
in
{
  # The `modules`, and `overlay` names are special
  modules = import ./nixos/modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Workaround to support auto-commiting with update script
  inherit lib;
}
// nurPkgs # nixpkgs packages
