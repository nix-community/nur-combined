{ pkgs }:

let
  inherit (pkgs) callPackage electron_13;
  inherit (pkgs.python3) override;
  perl5Packages = callPackage ./packageSets/perl-packages.nix { inherit (pkgs) lib stdenv fetchurl perlPackages shortenPerlShebang; } // pkgs.perlPackages // { recurseForDerivations = false; };
  python3 =
    let
      packageOverrides = pySelf: pyFinal: import ./packageSets/python-packages.nix { inherit (pySelf) callPackage; };
    in
    override { inherit packageOverrides; self = python3; };
  python3Packages = python3.pkgs;
  callPythonPackage = python3Packages.callPackage;

in
{
  inherit (python3Packages) aws-error-utils;
  inherit (perl5Packages) ARGVStruct ConfigAWS DataStructFlat MooseXClassAttribute NetAmazonSignatureV4 Paws TestTimer URLEncode URLEncodeXS;
  access-undenied-aws = callPythonPackage ./access-undenied-aws { };
  binance = callPackage ./binance { electron = electron_13; };
  burpsuite = callPackage ./burpsuite/ce.nix { };
  burpsuite-pro = callPackage ./burpsuite/pro.nix { };
  clair-scanner = callPackage ./clair-scanner { };
  device-flasher = callPackage ./device-flasher { };
  iptvnator = callPackage ./iptvnator { };
  mastopurge = callPackage ./mastopurge { };
  mkat = callPackage ./mkat { };
  mouseless = callPackage ./mouseless { };
  nexe = callPackage ./nexe { };
  npm-groovy-lint = callPackage ./npm-groovy-lint { };
  omnibus = callPackage ./omnibus { };
  ufbt = callPythonPackage ./ufbt { };
  upwork-wayland = callPythonPackage ./upwork-wayland { };
  xmouseless = callPackage ./xmouseless { };
}
