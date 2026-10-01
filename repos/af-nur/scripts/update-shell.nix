# Environment for scripts/update.sh: nvfetcher plus everything the updater
# shells out to. nvfetcher itself already brings nvchecker, nix-prefetch-git and
# nix-prefetch-docker on its PATH; nix-build / nix-prefetch-url / `nix hash` come
# from the caller's Nix (scripts/update.py points NIX_PATH at the nixpkgs that
# flake.lock pins, so those helpers agree with the built packages).
{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    nvfetcher
    curl
    jq
    yq-go
    git
    python3
    dpkg
    cacert
  ];

  # Fallback for the update helpers when scripts/update.py cannot resolve the
  # locked nixpkgs (offline first run, no flake support).
  NIX_PATH = "nixpkgs=${pkgs.path}";
}
