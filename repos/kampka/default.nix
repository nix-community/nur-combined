{ pkgs ? import <nixpkgs> {}, ... }:

{
  # pkgs
  nixify = pkgs.callPackage ./pkgs/nixify {};

  zsh-history = pkgs.callPackage ./pkgs/zsh-history {};

  fzy = pkgs.callPackage ./pkgs/fzy {};

  # modules
  modules = import ./modules ;
}
