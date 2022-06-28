{ pkgs ? import <nixpkgs> {} }:

let
  callPackage = pkgs.newScope self;
  self = rec {

    callPackage_i686 = pkgs.lib.callPackageWith (pkgs.pkgsi686Linux // self);

    #32bit
    hl4150cdn = callPackage_i686 ./hl4150cdn { };

    #smug           = pkgs.callPackage ./smug      { };
    #hercules-src-d = pkgs.callPackage ./hercules-src-d      { };
    crelease       = pkgs.callPackage ./crelease  { };
    fred           = pkgs.callPackage ./fred      { };
    embgit         = pkgs.callPackage ./embgit    { };
    cryptobox      = pkgs.callPackage ./cryptobox { };
    #yj-go     = pkgs.callPackage ./yj-go     { };
    #dstp      = pkgs.callPackage ./dstp      { };

    #open3d    = pkgs.python38Packages.callPackage ./open3d    { };

  };
in self
