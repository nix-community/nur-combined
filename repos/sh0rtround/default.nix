{ pkgs ? import <nixpkgs> { } }:
{
  nix-easy-search = pkgs.callPackage ./pkgs/nix-easy-search { };
}
