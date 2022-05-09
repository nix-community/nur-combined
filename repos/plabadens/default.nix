# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  #lib = import ./lib { inherit pkgs; }; # functions
  #modules = import ./modules; # NixOS modules
  #overlays = import ./overlays; # nixpkgs overlays

  diskgraph = pkgs.callPackage ./pkgs/diskgraph { };

  edmarketconnector =
    pkgs.python3.pkgs.toPythonApplication python3Packages.edmarketconnector;

  hassLovelaceModules = pkgs.recurseIntoAttrs {
    valetudo-map-card = pkgs.callPackage ./pkgs/home-assistant/lovelaceModules/lovelace-valetudo-map-card { };
    zigbee2mqtt-networkmap = pkgs.callPackage ./pkgs/home-assistant/lovelaceModules/zigbee2mqtt-networkmap { };
  };

  lsix = pkgs.callPackage ./pkgs/lsix { };

  python3Packages = pkgs.recurseIntoAttrs
    (pkgs.python3Packages.callPackage ./pkgs/python-modules { });

  python-validity = python3Packages.python-validity;
}

