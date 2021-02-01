{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  i3-wm-iconpatch = pkgs.callPackage pkgs/applications/window-managers/i3/icons.nix { };

  unreal-world = pkgs.callPackage pkgs/games/unreal-world/default.nix { };
}
