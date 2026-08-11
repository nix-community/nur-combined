{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    jq
    gron
    yaml2json
  ];
}
