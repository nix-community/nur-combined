{ pkgs ? import <nixpkgs> {} }:
{
  ib-tws = pkgs.callPackage ./pkgs/ib-tws { };
  tradingview = pkgs.callPackage ./pkgs/tradingview { };
}
