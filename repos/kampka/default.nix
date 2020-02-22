{ pkgs ? import <nixpkgs> {}, ... }:

{
  # pkgs
  nixify = pkgs.callPackage ./pkgs/nixify {};

  # modules
  modules = import ./modules;
}
