# My personal NUR repo
{ pkgs ? import <nixpkgs> {} }:
{
  build-sh = pkgs.callPackage ./build.sh/package.nix {};
  lmt = pkgs.callPackage ./lmt/package.nix {};
  carapace-bin = pkgs.callPackage ./carapace/package.nix {};

  overlays = import ./overlays.nix;
}
