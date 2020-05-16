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
}

