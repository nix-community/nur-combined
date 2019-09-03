{ pkgs ? import <nixpkgs> {}, ... }:

{
  # pkgs
  nixify = pkgs.callPackage ./pkgs/nixify {};

  zsh-history = pkgs.callPackage ./pkgs/zsh-history {};

  # modules
  modules = import ./modules ;
}
