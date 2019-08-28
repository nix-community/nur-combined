{ pkgs ? import <nixpkgs> { } }: { pkgs = import ./pkgs { inherit pkgs; }; }
