{ pkgs ? import ../../../nix { } }:
pkgs.npmlock2nix.v2.shell {
  src = ./.;
}
