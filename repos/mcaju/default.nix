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
  ubi_reader = pkgs.callPackage ./pkgs/ubi_reader { };

  prjxray-db = pkgs.callPackage ./pkgs/prjxray-db { };
  prjxray-tools = pkgs.callPackage ./pkgs/prjxray-tools { };
  symbiflow-arch-defs = pkgs.callPackage ./pkgs/symbiflow-arch-defs { };
  symbiflow-vtr = pkgs.callPackage ./pkgs/symbiflow-vtr { };
  symbiflow-yosys = pkgs.callPackage ./pkgs/symbiflow-yosys { };

  symbiflow-yosys-plugins = pkgs.callPackage ./pkgs/symbiflow-yosys/plugins/symbiflow-yosys-plugins {
    inherit symbiflow-yosys;
  };

  python3Packages = pkgs.python3Packages // rec {
    python-prjxray = pkgs.python3Packages.callPackage ./pkgs/python-prjxray {
      inherit prjxray-tools;
      inherit symbiflow-fasm;
      inherit textx;
    };
    symbiflow-fasm = pkgs.python3Packages.callPackage ./pkgs/symbiflow-fasm {
      inherit textx;
    };
    textx = pkgs.python3Packages.callPackage ./pkgs/textx { };
    xc-fasm = pkgs.python3Packages.callPackage ./pkgs/xc-fasm {
      inherit python-prjxray;
      inherit symbiflow-fasm;
      inherit textx;
    };
  };
}
