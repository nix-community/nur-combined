{ pkgs ? import <nixpkgs> {}
}:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  hm-modules = import ./hm-modules; # Home-manager modules
  overlays = import ./overlays; # nixpkgs overlays

  # development
  riscv-gnu-toolchain = pkgs.callPackage ./pkgs/development/riscv-gnu-toolchain {};

  xs = pkgs.callPackage ./pkgs/development/xs {
    ocamlPackages = pkgs.ocamlPackages_latest;
  };

  nord-css = pkgs.callPackage ./pkgs/development/nord-css {};

  # tools
  butler = pkgs.callPackage ./pkgs/tools/butler {};

  carbon-now = pkgs.callPackage ./pkgs/tools/carbon-now {
    nodejs = pkgs.nodejs-13_x;
  };

  pridecat = pkgs.callPackage ./pkgs/tools/pridecat {};

  surfraw = pkgs.callPackage ./pkgs/tools/surfraw {};

  # applications
  rover = pkgs.callPackage ./pkgs/applications/rover {};

  # build-support
  pandocWithFilters = pkgs.callPackage ./pkgs/build-support/pandoc-with-filters {};

  # games
  githug = pkgs.callPackage ./pkgs/games/githug {};

  aurora = pkgs.callPackage ./pkgs/games/aurora {
    nodejs = pkgs.nodejs-13_x;
  };
}

