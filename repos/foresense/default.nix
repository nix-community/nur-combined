{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) callPackage;
in
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  # packages
  id3edit = callPackage ./pkgs/id3edit { };
  libprinthex = callPackage ./pkgs/libprinthex { };
  gearmulator = callPackage ./pkgs/gearmulator { };
  loomer-architect = callPackage ./pkgs/loomer/architect.nix { };
  loomer-aspect = callPackage ./pkgs/loomer/aspect.nix { };
  loomer-manifold = callPackage ./pkgs/loomer/manifold.nix { };
  loomer-resound = callPackage ./pkgs/loomer/resound.nix { };
  loomer-sequent = callPackage ./pkgs/loomer/sequent.nix { };
  loomer-shift2 = callPackage ./pkgs/loomer/shift2.nix { };
  loomer-string = callPackage ./pkgs/loomer/string.nix { };
  pianoteq = callPackage ./pkgs/pianoteq { };
  redux = callPackage ./pkgs/redux { };
  renoise = callPackage ./pkgs/renoise { };
  serialosc = callPackage ./pkgs/serialosc { };
}
