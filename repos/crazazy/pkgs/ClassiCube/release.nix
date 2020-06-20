{ pkgs ? import <nixpkgs> { } }:
pkgs.callPackage ./. { }
