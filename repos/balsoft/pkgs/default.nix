{ pkgs ? import <nixpkgs> {} }:
with import ./lib.nix;
{
  termNote = callPackageDouble pkgs "termNote";
  lambda-launcher = callPackageDouble pkgs.haskellPackages "lambda-launcher";
  lambda-launcher-fixed = (import "${(import ../nix/sources.nix).lambda-launcher}/default.nix" { }).lambda-launcher;
  roboto-mono-nerd = pkgs.callPackage ./roboto-mono-nerd.nix { };
}
