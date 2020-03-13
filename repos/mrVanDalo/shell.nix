{ pkgs ? import <nixpkgs-unstable> { } }:
let
in pkgs.mkShell {
  buildInputs = with pkgs; [
    travis
  ];
}
