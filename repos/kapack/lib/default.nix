{ pkgs }:

with pkgs.lib; {
  cppMesonDevBase = import ./cpp-meson-dev.nix;
}
