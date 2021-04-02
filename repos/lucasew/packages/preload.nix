{ pkgs }:
with pkgs;
symlinkJoin {
  name = "preload";
  paths = [
    # dev
    nodejs
    nodePackages.vercel
    go
    gopls
    gcc
    python3
    python3Packages.numpy
    python3Packages.scikitlearn
  ];
}
