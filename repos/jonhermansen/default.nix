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

  eiffelstudio = pkgs.callPackage ./pkgs/eiffelstudio { };
  fuse-zip = pkgs.callPackage ./pkgs/fuse-zip { };
  hello-jon = pkgs.callPackage ./pkgs/hello-jon { };
  #moonring = pkgs.callPackage ./pkgs/moonring { }; # can't build in CI
  user-mode-linux = pkgs.callPackage ./pkgs/user-mode-linux { };
  vfio-isolate = pkgs.callPackage ./pkgs/vfio-isolate { };
  wayback-x11 = pkgs.callPackage ./pkgs/wayback-x11 { };
  xlibre = pkgs.callPackage ./pkgs/xlibre { };
}
