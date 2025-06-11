{ pkgs, ... }:
pkgs.mkShell.override { stdenv = pkgs.stdenvNoCC; } {
  packages = with pkgs; [
    just
    nixd
    nil
    nixfmt-rfc-style
    nix-tree
    nix-output-monitor
    nvfetcher
  ];
}
