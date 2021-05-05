{ pkgs ? import <nixpkgs> {} }:

rec {
  osccopy = pkgs.callPackage ./pkgs/osccopy {};
}
