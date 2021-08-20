{ pkgs ? import <nixpkgs> {} }:

rec {
  osccopy = pkgs.callPackage ./pkgs/osccopy {};

  vlmcsd = pkgs.callPackage ./pkgs/vlmcsd {};
}
