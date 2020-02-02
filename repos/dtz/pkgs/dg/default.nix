{ pkgs, lib, callPackage }:

let
  mkDg = llvmPkgs: callPackage ./generic.nix {
    inherit (llvmPkgs) stdenv llvm;
  };

in with pkgs; {}
// lib.optionalAttrs (pkgs ? llvmPackages_4) { dg_4 = mkDg llvmPackages_4;}
// lib.optionalAttrs (pkgs ? llvmPackages_5) { dg_5 = mkDg llvmPackages_5;}
// lib.optionalAttrs (pkgs ? llvmPackages_6) { dg_6 = mkDg llvmPackages_6;}
// lib.optionalAttrs (pkgs ? llvmPackages_7) { dg_7 = mkDg llvmPackages_7;}
