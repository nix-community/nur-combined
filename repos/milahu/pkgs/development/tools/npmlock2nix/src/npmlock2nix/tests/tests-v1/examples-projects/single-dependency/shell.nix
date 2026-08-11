{ pkgs ? import ../../../nix { } }:
pkgs.npmlock2nix.v1.shell {
  src = ./.;
}
