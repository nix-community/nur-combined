{
  system ? builtins.currentSystem,
  cargo2nix ? builtins.fetchGit {
    url = "https://github.com/cargo2nix/cargo2nix";
    rev = "ae19a9e1f8f0880c088ea155ab66cee1fa001f59";
  },
  pkgs ? import <nixpkgs> {
    inherit system;
    overlays = let
      cargo2nixOverlay = import "${cargo2nix}/overlay";
    in [ cargo2nixOverlay ];
  },
}:

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
}
