{ pkgs, sources }:
pkgs.haskellPackages.callPackage "${sources.passenv}/passenv.nix" { }
