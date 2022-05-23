{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  talosctl-bin = pkgs.callPackage ./pkgs/talosctl-bin { };

  intiface-desktop = pkgs.callPackage ./pkgs/intiface-desktop { };
  intiface-nix-patcher = pkgs.callPackage ./pkgs/intiface-nix-patcher { };
}
