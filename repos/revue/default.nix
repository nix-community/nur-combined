# Revue's release binary, for NUR (nur.repos.revue.revue-bin) and plain Nix:
#   nix-env -if https://forgejo.cleangame.dev/thatrichan/nix-revue/archive/main.tar.gz -A revue-bin
# Made from packaging/nix in Revue's repository at each release.
{
  pkgs ? import <nixpkgs> { },
}:
{
  revue-bin = pkgs.callPackage ./pkgs/revue-bin.nix { };
}
