{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  androidsdk = pkgs.callPackage ./pkgs/androidsdk {};
  csd-post = pkgs.callPackage ./pkgs/csd-post.nix {};
  dotfiles-sh = pkgs.callPackage ./pkgs/dotfiles-sh.nix {};
  rofi-menu = pkgs.callPackage ./pkgs/rofi-menu.nix {};
  slock = pkgs.callPackage ./pkgs/slock.nix {};
}
