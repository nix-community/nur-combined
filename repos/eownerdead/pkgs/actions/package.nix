{ pkgs }:
pkgs.dockerTools.buildLayeredImage (
  pkgs.docker-nixpkgs.nix-flakes.buildArgs // { includeStorePaths = false; }
)
