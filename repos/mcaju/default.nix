{ pkgs ? import <nixpkgs> { } }:

rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  decaf-emu = pkgs.libsForQt5.callPackage ./pkgs/decaf-emu { };
  epk2extract = pkgs.callPackage ./pkgs/epk2extract { };
  mdk4 = pkgs.callPackage ./pkgs/mdk4 { };
  reicast-emulator = pkgs.callPackage ./pkgs/reicast-emulator { };
  scamper = pkgs.callPackage ./pkgs/scamper { };

  prjxray-db = pkgs.callPackage ./pkgs/prjxray-db { };
  prjxray-tools = pkgs.callPackage ./pkgs/prjxray-tools { };
  vtr = pkgs.callPackage ./pkgs/vtr { };
  symbiflow-yosys-plugins = pkgs.callPackage ./pkgs/symbiflow-yosys-plugins { };

  symbiflow-arch-defs = pkgs.callPackage ./pkgs/symbiflow-arch-defs/default.nix { };

  python3Packages = pkgs.recurseIntoAttrs rec {
    python-prjxray = pkgs.python3Packages.callPackage ./pkgs/python-prjxray {
      inherit fasm;
      inherit prjxray-tools;
      inherit textx;
    };
    fasm = pkgs.python3Packages.callPackage ./pkgs/fasm {
      inherit textx;
    };
    textx = pkgs.python3Packages.callPackage ./pkgs/textx { };
    ubi_reader = pkgs.python3Packages.callPackage ./pkgs/ubi_reader { };
    xc-fasm = pkgs.python3Packages.callPackage ./pkgs/xc-fasm {
      inherit fasm;
      inherit python-prjxray;
      inherit textx;
    };
  };
}
