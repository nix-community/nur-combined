{ pkgs ? import <nixpkgs> {} }:

{
  n2n = pkgs.callPackage ./n2n {};

  mcstatus = pkgs.python3Packages.callPackage ./mcstatus {};
}
