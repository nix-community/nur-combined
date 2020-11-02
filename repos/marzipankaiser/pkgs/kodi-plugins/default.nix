{ pkgs ? import <nixpkgs> {} }:
{
  netflix = pkgs.callPackage ./netflix.nix { inherit pkgs; };
}
