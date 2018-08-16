{ pkgs ? import <nixpkgs> {} }:

{
  lab = pkgs.callPackage ./pkgs/applications/version-management/git-and-tools/lab {};
}
