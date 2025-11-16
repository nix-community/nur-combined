{ pkgs, ... }:
pkgs.mkShell.override { stdenv = pkgs.stdenvNoCC; } {
  packages = with pkgs; [
    just
    nixd
    nix-prefetch-git
    nixfmt
    nix-tree
    nix-output-monitor
    nvfetcher
  ];
}
