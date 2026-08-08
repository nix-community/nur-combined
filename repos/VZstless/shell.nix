{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nix-update
    nix
    git
    nix-prefetch-git
    curl
    jq
    cacert
  ];
}
