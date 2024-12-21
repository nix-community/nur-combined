{ pkgs ? import <nixpkgs> { } }:

with pkgs;
mkShell {
  name = "nur-packages";
  buildInputs = [
    nvfetcher
  ];
}
