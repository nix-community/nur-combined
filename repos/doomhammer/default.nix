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

let
  sources = pkgs.callPackage ./_sources/generated.nix { };
in

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hammerspoon = pkgs.callPackage ./pkgs/hammerspoon { source = sources.hammerspoon; };
  paperwm-spoon = pkgs.callPackage ./pkgs/paperwm-spoon { source = sources.paperwm-spoon; };
  powershell-beautifier = pkgs.callPackage ./pkgs/powershell-beautifier {
    source = sources.powershell-beautifier;
  };
  sketchyhelper = pkgs.callPackage ./pkgs/sketchyhelper { };
}
