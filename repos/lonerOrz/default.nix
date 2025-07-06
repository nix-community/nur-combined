{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}: {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # example-package = pkgs.callPackage ./pkgs/example-package { };
  xdman7 = pkgs.callPackage ./pkgs/xdman7 {};
  abdm = pkgs.callPackage ./pkgs/abdm {};
  mpv-handler = pkgs.callPackage ./pkgs/mpv-handler {};
  astronaut-sddm = pkgs.callPackage ./pkgs/astronaut-sddm {};
}
