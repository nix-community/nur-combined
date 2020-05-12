{ pkgs ? import <nixpkgs> {} }:

let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);
  
  self = {
    emacsWithConfig = callPackage ./emacs-with-config {};
    manifestBuilder = callPackage ./manifest-builder  {};
    userEnv         = callPackage ./user-environment  {};
  };
in self
