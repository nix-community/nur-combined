{
  pkgs ? import <nixpkgs> { },
}:

let
  nurPkgs = import ./pkgs (pkgs // nurPkgs) pkgs;
in
{
  # The `modules`, and `overlay` names are special
  modules = import ./nixos/modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Workaround to support auto-commiting with update script
  inherit (pkgs) lib;
}
// nurPkgs # nixpkgs packages
