{ pkgs ? import <nixpkgs> {} }:

let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);
  
  self = {
    emacsWithConfig = callPackage ./emacs-with-config {};
    manifest-nix    = callPackage ./manifest-nix  {};
    userEnv         = callPackage ./user-environment  {};
  };
in self
