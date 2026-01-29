{
  system ? builtins.currentSystem,
  nixpkgs ? <nixpkgs>,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  bundlers = import ./bundlers {
    inherit system pkgs;
  };

  lib = import ./libs {
    inherit system nixpkgs pkgs;
  };

  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
}
// import ./packages {
  inherit system pkgs;
}
