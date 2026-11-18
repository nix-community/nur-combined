{ lib }:
(import ./fetchrix-lib.nix { inherit lib; }).overlay {
  dir = ../_sources;
  config = ../fetchrix.toml;
}
