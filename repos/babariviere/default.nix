{ pkgs ? import <nixpkgs> { } }:

{
  nerd-font-symbols = pkgs.callPackage ./pkgs/nerd-font-symbols { };

  godot = pkgs.callPackage ./pkgs/godot { };
}
