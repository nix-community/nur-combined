{ stdenv, lib, fetchFromGitHub, crystal, libxml2, openssl, zlib, pkgconfig
, test ? false }:
let
  crystalPackages = lib.mapAttrs (name: src:
    stdenv.mkDerivation {
      name = lib.replaceStrings ["/"] ["-"] name;
      src = fetchFromGitHub src;
      phases = "installPhase";
      installPhase = ''cp -r $src $out'';
      passthru = { libName = name; };
    }
  ) (import ./shards.nix);

  crystalLib = stdenv.mkDerivation {
    name = "crystal-lib";
    src = lib.attrValues crystalPackages;
    libNames = lib.mapAttrsToList (k: v: [k v]) crystalPackages;
    phases = "buildPhase";
    buildPhase = ''
      mkdir -p $out
      linkup () {
        while [ "$#" -gt 0 ]; do
          ln -s $2 $out/$1
          shift; shift
        done
      }
      linkup $libNames
    '';
  };

  run-tests = ''
    echo run tests...
  '';
in stdenv.mkDerivation {
  name = "scylla";
  src = fetchFromGitHub {
    owner = "manveru";
    repo = "scylla";
    rev = "a3ce715b927b855c7592bc12fbfd5e1973695482";
    sha256 = "0n5kdakhvjgzlg704wzcrhskn6k4w8cm594x2bv88b15sdvkj6vs";
  };

  phases = "buildPhase";

  buildInputs = [
    libxml2
    openssl
    zlib
    pkgconfig
  ];

  buildPhase = ''
    mkdir -p $out/bin tmp
    cd tmp
    cp -r $src/* .
    chmod +w -R .
    rm -rf lib
    ln -s ${crystalLib} lib
    ${lib.optionalString test run-tests}
    ${crystal}/bin/crystal build --verbose --progress --release src/server.cr -o $out/bin/scylla
  '';
}
