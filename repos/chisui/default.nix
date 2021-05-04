{ pkgs ? import <nixpkgs> { } }@args:
{
  lib = import ./lib args;
} // (import ./pkgs args)

