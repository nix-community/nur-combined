{ pkgs ? import <nixpkgs> {}, ... }:

{
  # special attributes
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  # pkgs
  go-hello-world = pkgs.callPackage ./pkgs/go-hello-world {};
  nanoc = pkgs.callPackage ./pkgs/nanoc {};
  rust-hello-world = pkgs.callPackage ./pkgs/rust-hello-world {};
}
