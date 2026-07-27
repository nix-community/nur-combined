{
  pkgs ? import <nixpkgs> {
    overlays = [
      (import (fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
    ];
  },
  pkgs-protobuf320 ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/656b40c807e4c4965198a68d1f784492397fef6c.tar.gz";
    sha256 = "sha256-XalzeRAiECNU0WWxPK9U8+MmEGRVJCA2Lfs0b6gjblo=";
  }) { },
  pkgs-protobuf293 ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/3a7baab73a629847afbcca8a52765c0b5fec49ae.tar.gz";
    sha256 = "sha256:0dy58m7q7k03rcwqvq4mg33syswvf0qg7ypxzlxa1nm5yvwcilhb";
  }) { },
}:

rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  cups-detonger = pkgs.callPackage ./pkgs/cups-detonger { };
  snipaste = pkgs.callPackage ./pkgs/snipaste { };
  safeheron-crypto-suites = pkgs.callPackage ./pkgs/safeheron-crypto-suites {
    inherit (pkgs-protobuf320) protobuf3_20;
  };
  multi-party-sig = pkgs.callPackage ./pkgs/multi-party-sig {
    inherit safeheron-crypto-suites;
    inherit (pkgs-protobuf320) protobuf3_20;
  };
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
  noir = pkgs.callPackage ./pkgs/noir { inherit (pkgs) rust-bin; protobuf_29 = pkgs-protobuf293.protobuf_29; };
  mergiraf = pkgs.callPackage ./pkgs/mergiraf { inherit (pkgs) rust-bin; };
  libjportaudio = pkgs.callPackage ./pkgs/libjportaudio { };
  beatoraja = pkgs.callPackage ./pkgs/beatoraja { inherit libjportaudio; };

  font-iosvmata = pkgs.callPackage ./pkgs/font-iosvmata { };
  font-pragmasevka = pkgs.callPackage ./pkgs/font-pragmasevka { };
  font-sarasa-term-sc-nerd = pkgs.callPackage ./pkgs/font-sarasa-term-sc-nerd { };
  font-ibm-plex-sans-cjk = pkgs.callPackage ./pkgs/font-ibm-plex-sans-cjk { };

  # ZKVM
  # riscv-gnu-toolchain = pkgs.callPackage ./pkgs/zkvm/riscv-gnu-toolchain { };
}
