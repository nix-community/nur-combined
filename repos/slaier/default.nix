{ pkgs ? import <nixpkgs> { } }:
{
  modules = import ./modules;
} //
(import ./pkgs { inherit pkgs; })
