{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) callPackage;
  libprinthex = callPackage ./pkgs/libprinthex { };
in
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  # packages
  convert-with-moss = callPackage ./pkgs/convert-with-moss { };
  id3edit = callPackage ./pkgs/id3edit { inherit libprinthex; };
  gearmulator = callPackage ./pkgs/gearmulator { };
  # loomer
  loomer-architect = callPackage ./pkgs/loomer/architect.nix { };
  loomer-aspect = callPackage ./pkgs/loomer/aspect.nix { };
  loomer-manifold = callPackage ./pkgs/loomer/manifold.nix { };
  loomer-resound = callPackage ./pkgs/loomer/resound.nix { };
  loomer-sequent = callPackage ./pkgs/loomer/sequent.nix { };
  loomer-shift2 = callPackage ./pkgs/loomer/shift2.nix { };
  loomer-string = callPackage ./pkgs/loomer/string.nix { };
  # ODDSound
  libmts = callPackage ./pkgs/libmts { };
  # monome
  serialosc = callPackage ./pkgs/serialosc { };
  # emprcl
  sektron = callPackage ./pkgs/sektron { };
  signls = callPackage ./pkgs/signls { };
  # madronalabs
  utu = callPackage ./pkgs/utu { };
}
