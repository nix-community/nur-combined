{ pkgs ? import <nixpkgs> { } }:
{
  ryujinx = pkgs.callPackage ./ryujinx { };

  yuzu-mainline = import ./yuzu {
    branch = "mainline";
    inherit (pkgs) libsForQt5 fetchFromGitHub gcc11Stdenv;
  };
  yuzu-ea = import ./yuzu {
    branch = "early-access";
    inherit (pkgs) libsForQt5 fetchFromGitHub gcc11Stdenv;
  };
}
