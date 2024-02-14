{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  packages = [
    bash
    nix-prefetch-github
  ];
}
