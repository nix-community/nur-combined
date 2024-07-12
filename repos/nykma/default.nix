{ pkgs ? import <nixpkgs> { } }:

rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  cups-detonger = pkgs.callPackage ./pkgs/cups-detonger { };
  snipaste = pkgs.callPackage ./pkgs/snipaste { };
  safeheron-crypto-suites = pkgs.callPackage ./pkgs/safeheron-crypto-suites { };
  multi-party-sig = pkgs.callPackage ./pkgs/multi-party-sig { safeheron-crypto-suites = safeheron-crypto-suites; };
  cryptopp-cmake = pkgs.callPackage ./pkgs/cryptopp-cmake { };
  orca-slicer = pkgs.callPackage ./pkgs/orca-slicer { };
  snips-sh = pkgs.callPackage ./pkgs/snips.sh { };
  font-apple-color-emoji = pkgs.callPackage ./pkgs/font-apple-color-emoji { };
  onekey-wallet = pkgs.callPackage ./pkgs/onekey-wallet { };
  jwt-cpp = pkgs.callPackage ./pkgs/jwt-cpp { };
  rapidsnark = pkgs.callPackage ./pkgs/rapidsnark { };
}
