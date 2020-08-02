{ pkgs ? import <nixpkgs> {} }:
rec {
  lib = import ./lib { inherit (pkgs) lib; };
  # home-manager modules
  hmModules = import ./hm-modules;
  # A list of all modules in hmModules.
  allHmModules = builtins.attrValues hmModules;
  # Overlays
  overlays = import ./overlays;

  id3 = pkgs.callPackage ./pkgs/id3 { };
  mopidy-podcast = pkgs.callPackage ./pkgs/mopidy-podcast { };
  ocamlweb = pkgs.callPackage ./pkgs/ocamlweb { };
  onedrive = pkgs.callPackage ./pkgs/onedrive { };
  # passenv = import ./pkgs/passenv {
  #   inherit pkgs;
  #   passenv-overlay = overlays.passenv;
  # };
}
