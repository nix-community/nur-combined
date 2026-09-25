# NUR entry point. Takes pkgs as an argument rather than importing nixpkgs, so
# the package set is the one the consumer already has.
{ pkgs ? import <nixpkgs> { } }:

{
  tapioca = pkgs.callPackage ./pkgs/tapioca { };
}
