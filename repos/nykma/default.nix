{ pkgs ? import <nixpkgs> { } }:

rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  cups-detonger = pkgs.callPackage ./pkgs/cups-detonger { };
  snipaste = pkgs.callPackage ./pkgs/snipaste { };
  safeheron-crypto-suites = pkgs.callPackage ./pkgs/safeheron-crypto-suites { };
  multi-party-sig = pkgs.callPackage ./pkgs/multi-party-sig { inherit safeheron-crypto-suites; };
  cryptopp-cmake = pkgs.callPackage ./pkgs/cryptopp-cmake { };
  orca-slicer = pkgs.callPackage ./pkgs/orca-slicer { };
  snips-sh = pkgs.callPackage ./pkgs/snips.sh { };
  font-apple-color-emoji = pkgs.callPackage ./pkgs/font-apple-color-emoji { };
  onekey-wallet = pkgs.callPackage ./pkgs/onekey-wallet { };
  jwt-cpp = pkgs.callPackage ./pkgs/jwt-cpp { };
  rapidsnark = pkgs.callPackage ./pkgs/rapidsnark { };
  aws-lambda-ric-nodejs = pkgs.callPackage ./pkgs/aws-lambda-ric-nodejs { };
  v2dat = pkgs.callPackage ./pkgs/v2dat { };
  v2ray-rules-dat = pkgs.callPackage ./pkgs/v2ray-rules-dat { inherit v2dat; };
  zen-browser = pkgs.callPackage ./pkgs/zen-browser { };
  # reth = pkgs.callPackage ./pkgs/reth { };

  font-iosvmata = pkgs.callPackage ./pkgs/font-iosvmata { };
  font-pragmasevka = pkgs.callPackage ./pkgs/font-pragmasevka { };
  font-sarasa-term-sc-nerd = pkgs.callPackage ./pkgs/font-sarasa-term-sc-nerd { };
}
