{ pkgs ? import <nixpkgs> {} }:
{
  ninvaders-workman = pkgs.callPackage ./ninvaders-workman {};
  tetris-workman = pkgs.callPackage ./tetris-workman {};
}
