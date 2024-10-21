{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  etime = pkgs.callPackage ./pkgs/etime { };
  gon =
    if pkgs.system == "x86_64-darwin" || pkgs.system == "aarch64-darwin" then
      pkgs.callPackage ./pkgs/gon { }
    else
      null;
  jurigged = pkgs.callPackage ./pkgs/jurigged { };
  llrt = pkgs.callPackage ./pkgs/llrt { };
  proximity-nvim = pkgs.callPackage ./pkgs/proximity-nvim { };
  zsh-wd = pkgs.callPackage ./pkgs/zsh-wd { };
}
