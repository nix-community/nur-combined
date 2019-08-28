{ pkgs ? import <nixpkgs> {} }:
with import ./lib.nix;
{
  termNote = callPackageDouble pkgs "termNote";
  lambda-launcher = callPackageDouble pkgs.haskellPackages "lambda-launcher";
  roboto-mono-nerd = pkgs.callPackage ./roboto-mono-nerd.nix { };
}
