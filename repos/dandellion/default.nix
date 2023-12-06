# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <unstable> {} }:

let
#  wsgiserver = pkgs.callPackage ./pkgs/python-modules/wsgiserver { buildPythonPackage = pkgs.python3Packages.buildPythonPackage; fetchPypi = pkgs.python3Packages.fetchPypi; };
in 
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  xfer9860 = pkgs.callPackage ./pkgs/xfer9860 { };

  colors = pkgs.callPackage ./pkgs/colors { };
  eplot = pkgs.callPackage ./pkgs/eplot { };

  synapse-admin = pkgs.callPackage ./pkgs/synapse-admin { };
#  matrix-presents = pkgs.callPackage ./pkgs/matrix-presents { };
  matrix-wug = pkgs.callPackage ./pkgs/matrix-wug { };
  matrix-hydrus-bot = pkgs.callPackage ./pkgs/matrix-hydrus-bot { };

  matrix-appservice-minecraft = pkgs.callPackage ./pkgs/matrix-appservice-minecraft { };

  rust-synapse-compress-state = pkgs.callPackage ./pkgs/rust-synapse-compress-state { };
  matrix-corporal = pkgs.callPackage ./pkgs/matrix-corporal { };

  rank_photos = pkgs.callPackage ./pkgs/rank_photos { };

  # grav1 = pkgs.callPackage ./pkgs/grav1/server.nix { wsgiserver = wsgiserver; setuptools = pkgs.python3Packages.setuptools; };
  # grav1c = pkgs.callPackage ./pkgs/grav1/client.nix { };

  # av1client = pkgs.callPackage ./pkgs/av1master/client.nix { };

  # radical-native = pkgs.callPackage ./pkgs/radical-native { };
  photini = pkgs.libsForQt5.callPackage ./pkgs/photini { };

  pixitracker = pkgs.callPackage ./pkgs/pixitracker { };

  plotbitrate = pkgs.callPackage ./pkgs/plotbitrate { };

  wii-u-gc-adapter = pkgs.callPackage ./pkgs/wii-u-gc-adapter { };

  mcaselector = pkgs.callPackage ./pkgs/mcaselector { };
  minecraft-fabric = pkgs.callPackage ./pkgs/minecraft-fabric { };

  dowlords-faf-client = pkgs.callPackage ./pkgs/downlords { jdk16 = pkgs.jdk; };

  pvvmud = pkgs.callPackage ./pkgs/pvvmud { stdenv = pkgs.gcc49Stdenv; };

  # this is just for language of the program
  #libreoffice = pkgs.libreoffice.override { libreoffice = pkgs.libreoffice.libreoffice.override { langs = [ "nb" "nn" "en-GB" "en-US" ]; }; };

  soundux = pkgs.callPackage ./pkgs/soundux { };

  mesloNFp10k = pkgs.callPackage ./pkgs/fonts/MesloNFp10k.nix { };
  wallpapers = pkgs.callPackage ./pkgs/wallpapers/monogatari { };
}
