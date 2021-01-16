{ pkgs ? import <nixpkgs> {}
}:

{
  # lib = import ./lib { inherit pkgs; };
  # modules = import ./modules;
  # hm-modules = import ./hm-modules;
  # overlays = import ./overlays;

  # tools
  butler = pkgs.callPackage ./pkgs/tools/butler {};

  carbon-now = pkgs.callPackage ./pkgs/tools/carbon-now {
    nodejs = pkgs.nodejs-14_x or pkgs.nodejs-13_x;
  };

  surfraw = pkgs.callPackage ./pkgs/tools/surfraw {};

  # applications
  rover = pkgs.callPackage ./pkgs/applications/rover {};

  # games
  githug = pkgs.callPackage ./pkgs/games/githug {};
}

