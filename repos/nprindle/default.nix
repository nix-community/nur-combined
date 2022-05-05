{ pkgs ? import <nixpkgs> {}
}:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  hm-modules = import ./hm-modules;
  overlays = import ./overlays;

  # tools
  carbon-now = pkgs.callPackage ./pkgs/tools/carbon-now {
    nodejs = pkgs.nodejs-14_x or pkgs.nodejs-13_x;
  };

  # games
  githug = pkgs.callPackage ./pkgs/games/githug {};
}
