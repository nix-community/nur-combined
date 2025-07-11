{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}: rec {
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # packages
  bobgen = pkgs.callPackage ./pkgs/bobgen {};
  protoc-gen-connect-openapi = pkgs.callPackage ./pkgs/protoc-gen-connect-openapi {};
  opengrep-core = pkgs.callPackage ./pkgs/opengrep/opengrep-core.nix {};
  opengrep = pkgs.python311Packages.callPackage ./pkgs/opengrep {inherit opengrep-core;};
}
