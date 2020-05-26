{ pkgs ? import <nixpkgs> {}
}:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # packages
  butler = pkgs.callPackage ./pkgs/butler {};

  riscv-gnu-toolchain = pkgs.callPackage ./pkgs/riscv-gnu-toolchain {};

  xs = pkgs.callPackage ./pkgs/xs {
    ocamlPackages = pkgs.ocamlPackages_latest;
  };

  githug = pkgs.callPackage ./pkgs/githug {};

  pandocWithFilters = pkgs.callPackage ./pkgs/pandoc-with-filters {};

  nord-css = pkgs.callPackage ./pkgs/nord-css {};

  carbon-now = pkgs.callPackage ./pkgs/carbon-now {
    nodejs = pkgs.nodejs-13_x;
  };
}

