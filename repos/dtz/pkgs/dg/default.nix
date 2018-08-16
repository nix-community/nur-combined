{ pkgs, callPackage }:

let
  mkDg = llvmPkgs: callPackage ./generic.nix {
    inherit (llvmPkgs) stdenv llvm;
  };

in with pkgs; {
  dg_4 = mkDg llvmPackages_4;
  dg_5 = mkDg llvmPackages_5;
  dg_6 = mkDg llvmPackages_6;
}
