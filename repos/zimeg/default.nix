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
  proximity-nvim = pkgs.callPackage ./pkgs/proximity-nvim { };
  telescope-git-conflicts-nvim = pkgs.callPackage ./pkgs/telescope-git-conflicts-nvim { };
  zsh-wd = pkgs.callPackage ./pkgs/zsh-wd { };
}
