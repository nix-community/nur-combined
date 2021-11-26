{ pkgs ? import <nixpkgs> { } }:

rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  decaf-emu = pkgs.libsForQt5.callPackage ./pkgs/decaf-emu { };
  epk2extract = pkgs.callPackage ./pkgs/epk2extract { };
  scamper = pkgs.callPackage ./pkgs/scamper { };

  prjxray-db = pkgs.callPackage ./pkgs/prjxray-db { };
  prjxray-tools = pkgs.callPackage ./pkgs/prjxray-tools { };
  symbiflow-yosys = pkgs.callPackage ./pkgs/symbiflow-yosys { };
  vtr = pkgs.callPackage ./pkgs/vtr { };

  yosys-symbiflow-plugins = pkgs.callPackage ./pkgs/yosys-symbiflow-plugins {
    yosys = symbiflow-yosys;
  };

  symbiflow-arch-defs = pkgs.callPackage ./pkgs/symbiflow-arch-defs {
    inherit prjxray-db vtr yosys-symbiflow-plugins;
    python3Packages = pkgs.python3Packages // python3Packages;
    yosys = symbiflow-yosys;
  };

  python3Packages = pkgs.recurseIntoAttrs rec {
    kijewski-pyjson5 = pkgs.python3Packages.callPackage ./pkgs/pyjson5 { };
    pyric = pkgs.python3Packages.callPackage ./pkgs/pyric { };
    roguehostapd = pkgs.python3Packages.callPackage ./pkgs/roguehostapd { };
    textx = pkgs.python3Packages.callPackage ./pkgs/textx { };
    ubi_reader = pkgs.python3Packages.callPackage ./pkgs/ubi_reader { };

    fasm = pkgs.python3Packages.callPackage ./pkgs/fasm {
      inherit textx;
    };

    python-prjxray = pkgs.python3Packages.callPackage ./pkgs/python-prjxray {
      inherit fasm;
      inherit kijewski-pyjson5;
      inherit prjxray-tools;
    };

    wifiphisher = pkgs.python3Packages.callPackage ./pkgs/wifiphisher {
      inherit pyric;
      inherit roguehostapd;
    };

    xc-fasm = pkgs.python3Packages.callPackage ./pkgs/xc-fasm {
      inherit fasm;
      inherit prjxray-tools;
      inherit python-prjxray;
      inherit textx;
    };
  };
}
