# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  enroot = pkgs.callPackage ./pkgs/enroot { };

  python3 = pkgs.python3.override {
    packageOverrides = pySelf: pySuper: {
      fiblary3 = pySelf.callPackage ./pkgs/fiblary3 { };
      garminconnect = pySelf.callPackage ./pkgs/garminconnect { };
      hass-smartbox = pySelf.callPackage ./pkgs/hass-smartbox { };
      libpurecool = pySelf.callPackage ./pkgs/libpurecool { };
      python-engineio_3 = pySelf.callPackage ./pkgs/python-engineio/3.nix { };
      python-socketio_4 = pySelf.callPackage ./pkgs/python-socketio/4.nix { };
      ring_doorbell = pySelf.callPackage ./pkgs/ring_doorbell { };
      smartbox = pySelf.callPackage ./pkgs/smartbox { };
      teslajsonpy = pySelf.callPackage ./pkgs/teslajsonpy { };
    };
  };
  python3Packages = python3.pkgs;
}
