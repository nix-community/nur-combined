{ pkgs ? import <nixpkgs> { } }:

{
  nerd-font-symbols = pkgs.callPackage ./pkgs/nerd-font-symbols { };
}
