{ pkgs ? import <nixpkgs> { } }:

with pkgs;
mkShell {
  buildInputs = [ nixpkgs-fmt zsh ];
  shellHook = ''
    zsh
  '';
}

