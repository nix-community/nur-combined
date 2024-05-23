{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

mkShell {
  packages = [
    bash
    curl
    gnused
    jq
    nix-prefetch-scripts
  ];
}
