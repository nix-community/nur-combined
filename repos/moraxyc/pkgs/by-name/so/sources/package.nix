{ pkgs, ... }:
let
  fetchrixLoader = pkgs.callPackage ./fetchrix-loader.nix { };
in
fetchrixLoader {
  dir = ../../../../_sources;
  config = ../../../../fetchrix.toml;
}
