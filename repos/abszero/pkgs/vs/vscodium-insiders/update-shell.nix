{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

mkShell {
  packages = [
    bash
    curl
    gawk
    gnused
    nix-prefetch-scripts
  ];
}
