{ pkgs ? import <nixpkgs> {} }:

{

  overlays = import ./overlays;

  lab = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/lab {};

}
