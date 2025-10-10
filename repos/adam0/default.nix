# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  hmModules = import ./hm-modules; # Home Manager modules.

  bibata-modern-cursors-classic = pkgs.callPackage ./pkgs/bibata-modern-cursors-classic { };
  bibata-modern-cursors-classic-hyprcursor =
    pkgs.callPackage ./pkgs/bibata-modern-cursors-classic-hyprcursor
      { };

  bibata-modern-cursors-rosepine = pkgs.callPackage ./pkgs/bibata-modern-cursors-rosepine { };
  bibata-modern-cursors-rosepine-hyprcursor =
    pkgs.callPackage ./pkgs/bibata-modern-cursors-rosepine-hyprcursor
      { };

  bibata-modern-cursors-gruvbox-dark = pkgs.callPackage ./pkgs/bibata-modern-cursors-gruvbox-dark { };
  bibata-modern-cursors-gruvbox-dark-hyprcursor =
    pkgs.callPackage ./pkgs/bibata-modern-cursors-gruvbox-dark-hyprcursor
      { };
}
