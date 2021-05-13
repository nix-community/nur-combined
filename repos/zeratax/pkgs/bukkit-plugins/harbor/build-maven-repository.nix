{ pkgs ? import <nixpkgs> { } }:
with pkgs;
(buildMaven ./project-info.json).repo
