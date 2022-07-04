{pkgs ? import <nixpkgs> {}}: {
  lib = import ./lib {inherit pkgs;};
  modules = import ./modules;
  overlays = import ./overlays;

  badwolf = pkgs.callPackage ./pkgs/badwolf {};
}
