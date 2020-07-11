# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixos-unstable> {} }:

let
  wsgiserver = pkgs.callPackage ./pkgs/python-modules/wsgiserver { buildPythonPackage = pkgs.python3Packages.buildPythonPackage; fetchPypi = pkgs.python3Packages.fetchPypi; };
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  colors = pkgs.callPackage ./pkgs/colors { };

  rank_photos = pkgs.callPackage ./pkgs/rank_photos { };
  JAVMovieScraper = pkgs.callPackage ./pkgs/JAVMovieScraper { };
  vcsi = pkgs.callPackage ./pkgs/vcsi {};

  grav1 = pkgs.callPackage ./pkgs/grav1/server.nix { wsgiserver = wsgiserver; setuptools = pkgs.python3Packages.setuptools; };
  grav1c = pkgs.callPackage ./pkgs/grav1/client.nix { };

  av1client = pkgs.callPackage ./pkgs/av1master/client.nix { };

  janus = pkgs.libsForQt5.callPackage ./pkgs/JanusVR/client { };

  radical-native = pkgs.callPackage ./pkgs/radical-native { };
  photini = pkgs.libsForQt5.callPackage ./pkgs/photini { };

  plotbitrate = pkgs.callPackage ./pkgs/plotbitrate { };

  mangohud = pkgs.callPackage ./pkgs/MangoHUD { };

  botamusique = pkgs.callPackage ./pkgs/botamusique { };

  mesloNFp10k = pkgs.callPackage ./pkgs/fonts/MesloNFp10k.nix { };

  wallpapers = pkgs.callPackage ./pkgs/wallpapers/monogatari { };
}
