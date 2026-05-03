{ pkgs, nvfetcher-bin }:
pkgs.mkShellNoCC {
  preferLocalBuild = true;
  allowSubstitutes = false;
  packages = with pkgs; [
    just
    nixd
    nix-prefetch-git
    nvfetcher-bin
  ];
}
