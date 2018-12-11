{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [ (import ./tests {}) ];
}
