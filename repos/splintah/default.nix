{ pkgs ? import <nixpkgs> {} }:
let
  sources = import ./nix/sources.nix;
  hmModules = import ./hm-modules;
in
{
  lib = import ./lib { inherit (pkgs) lib; };
  # home-manager modules
  inherit hmModules;
  # A list of all modules in hmModules.
  allHmModules = builtins.attrValues hmModules;
  # Overlays
  overlays = import ./overlays;

  giph = pkgs.callPackage ./pkgs/giph { };
  "hideIt.sh" = pkgs.callPackage ./pkgs/hideIt.sh { };
  id3 = pkgs.callPackage ./pkgs/id3 { };
  mopidy-podcast = pkgs.callPackage ./pkgs/mopidy-podcast { };
  ocamlweb = pkgs.callPackage ./pkgs/ocamlweb { };
  onedrive = pkgs.callPackage ./pkgs/onedrive { };

  pkgs = {
    passenv = import ./pkgs/passenv { inherit pkgs sources; };
  };
}
