{ pkgs, lib, ... }:
{
  dir,
  config ? null,
}:
(import ../../../../lib/fetchrix-lib.nix { inherit lib; }).load {
  inherit pkgs dir config;
}
