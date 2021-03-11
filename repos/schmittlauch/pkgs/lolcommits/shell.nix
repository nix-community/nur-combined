{ pkgs ? import <nixpkgs> { } }:
with pkgs;
with stdenv;
mkShell {
  name = "lolcommits-shell";
  buildInputs = [ bundix ruby ];
}
