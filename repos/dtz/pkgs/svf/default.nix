{ pkgs, lib, callPackage }:

let
  svfs = rec {
    #"4" = {
    #  path = ./4.nix;
    #  llvmPackages = pkgs.llvmPackages_4;
    #};
    "6" = {
      path = ./6.nix;
      llvmPackages = pkgs.llvmPackages_6;
    };
    master = {
      path = ./master.nix;
      llvmPackages = pkgs.llvmPackages_7;
    };
    # also make this available under "svfPkgs_7",
    # matching what we do for 4 and 6.
    # (for use when it matters LLVM7 is used, not 8 or w/e)
    "7" = master;
  };
  mkPkgs = info: lib.recurseIntoAttrs rec {
    svf = callPackage info.path { inherit (info.llvmPackages) llvm; };
    ptaben-fi = callPackage ./ptaben.nix {
      inherit (info.llvmPackages) stdenv llvm clang;
      inherit svf;
    };
    ptaben-fs = ptaben-fi.override { testFSPTA = true; };
  };

in
  lib.mapAttrs' (n: v: lib.nameValuePair "svfPkgs_${n}" (mkPkgs v)) svfs
