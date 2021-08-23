{ pkgs ? import <nixpkgs> {} }:

rec {
  modules = import ./modules;

  osccopy = pkgs.callPackage ./pkgs/osccopy {};
  vlmcsd = pkgs.callPackage ./pkgs/vlmcsd {};
}
