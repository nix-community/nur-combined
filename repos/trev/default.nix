{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}: {
  packages = import ./packages {
    inherit system pkgs;
  };

  bundlers = import ./bundlers {
    inherit system pkgs;
  };

  lib = import ./libs {
    inherit system pkgs;
  };

  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
}
