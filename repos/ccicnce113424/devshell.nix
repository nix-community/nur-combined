{ pkgs, nvfetcher-bin }:
pkgs.mkShell.override { stdenv = pkgs.stdenvNoCC; } {
  packages = with pkgs; [
    just
    nixd
    nix-prefetch-git
    nvfetcher-bin
  ];
}
