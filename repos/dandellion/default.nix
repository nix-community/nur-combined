# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixos-unstable> {} }:

let
#  wsgiserver = pkgs.callPackage ./pkgs/python-modules/wsgiserver { buildPythonPackage = pkgs.python3Packages.buildPythonPackage; fetchPypi = pkgs.python3Packages.fetchPypi; };

#  opencv-python-headless = pkgs.callPackage ./pkgs/python-modules/opencv-python-headless { buildPythonPackage = pkgs.python3Packages.buildPythonPackage; fetchPypi = pkgs.python3Packages.fetchPypi; };
#  pylzma = pkgs.callPackage ./pkgs/python-modules/pylzma { buildPythonPackage = pkgs.python3Packages.buildPythonPackage; fetchPypi = pkgs.python3Packages.fetchPypi; };
#  python-mpv = pkgs.callPackage ./pkgs/python-modules/python-mpv { buildPythonPackage = pkgs.python3Packages.buildPythonPackage; fetchPypi = pkgs.python3Packages.fetchPypi; };
in 
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  colors = pkgs.callPackage ./pkgs/colors { };
##  eplot = pkgs.callPackage ./pkgs/eplot { };

##  synapse-admin = pkgs.callPackage ./pkgs/synapse-admin { };
#  matrix-presents = pkgs.callPackage ./pkgs/matrix-presents { };
##  matrix-wug = pkgs.callPackage ./pkgs/matrix-wug { };

##  matrix-appservice-minecraft = pkgs.callPackage ./pkgs/matrix-appservice-minecraft { };

##  rust-synapse-compress-state = pkgs.callPackage ./pkgs/rust-synapse-compress-state { };
##  matrix-corporal = pkgs.callPackage ./pkgs/matrix-corporal { };

##  rank_photos = pkgs.callPackage ./pkgs/rank_photos { };

  # grav1 = pkgs.callPackage ./pkgs/grav1/server.nix { wsgiserver = wsgiserver; setuptools = pkgs.python3Packages.setuptools; };
  # grav1c = pkgs.callPackage ./pkgs/grav1/client.nix { };

  # av1client = pkgs.callPackage ./pkgs/av1master/client.nix { };

  # radical-native = pkgs.callPackage ./pkgs/radical-native { };
##  photini = pkgs.libsForQt5.callPackage ./pkgs/photini { };

###  hydrus = pkgs.libsForQt5.callPackage ./pkgs/hydrus { inherit pylzma;};

###  metapixel = pkgs.callPackage ./pkgs/metapixel { };

###  plotbitrate = pkgs.callPackage ./pkgs/plotbitrate { };

  # wii-u-gc-adapter = pkgs.callPackage ./pkgs/wii-u-gc-adapter { };

  # minecraft-server-fabric = pkgs.callPackage ./pkgs/minecraft-server-fabric { };

###  dowlords-faf-client = pkgs.callPackage ./pkgs/downlords { };

###  mesloNFp10k = pkgs.callPackage ./pkgs/fonts/MesloNFp10k.nix { };
###  wallpapers = pkgs.callPackage ./pkgs/wallpapers/monogatari { };
}
