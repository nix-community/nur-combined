{ pkgs }:

with pkgs.lib; {
  ts-for-gjs = pkgs.callPackage ./ts-for-gjs/default.nix {};
}

