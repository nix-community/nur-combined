{pkgs ? import <nixpkgs> {}}:
{
  lib = import ./lib {inherit pkgs;};
  modules = import ./modules;
  overlays = import ./overlays;
}
// import ./pkgs {inherit pkgs;}
