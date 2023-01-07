{ pkgs ? import <nixpkgs> {} }:
{
  ib-tws = pkgs.callPackage ./pkgs/ib-tws { };
  steghide = pkgs.callPackage ./pkgs/steghide { };
}
